#!/usr/bin/env python3
"""
Refreshes a host survey in notes/ (hosts.json and downloads.json) from the live servers.

hosts.json:
  The domains listed in its "domains" section are looked up in certificate transparency
  (crt.sh). Every name found there, plus every name already in the file, gets its A records
  (dns.google), the redirect chain of http://<host>/, and sampled responses to https://<host>/
  and to an unknown path. Names with two or more A records are sampled more often, because
  round-robin servers may answer differently. Hand-written fields ("role", "domains") are kept.

downloads.json:
  Every file in "files" is downloaded again: size, SHA-256, the GPG signature (<url>.asc,
  when the entry has "gpg"), the MD5 (when it has "md5"), and every mirror in "identical_on".
  An entry with "manifest" is compared with the hash in that bucket manifest.
  "listed_not_downloaded" only gets a HEAD request for the current size.

Only the Python standard library is used. GPG checks need the gpg executable on PATH
(Gpg4win, 'scoop install gpg', or the distribution's package); without it they are skipped.

Exit code: 0 when everything matches, 1 when a signature is bad, a hash differs from a
manifest, or a mirror serves different bytes.

Usage:
  python bin/update-host-notes.py                       # notes/tixati-software, everything
  python bin/update-host-notes.py --skip-downloads      # hosts.json only
  python bin/update-host-notes.py notes/other --samples 5
"""

import argparse
import collections
import datetime
import hashlib
import json
import os
import shutil
import subprocess
import sys
import tempfile
import time
import urllib.error
import urllib.parse
import urllib.request

REPO_ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
DEFAULT_NOTES = os.path.join(REPO_ROOT, 'notes', 'tixati-software')
TIMEOUT_SEC = 15
USER_AGENT = 'scoop-bucket-host-notes/1.0'
# Path that should not exist anywhere: shows whether a redirect keeps the path.
UNKNOWN_PATH = '/zz/test.zip?q=1'
# Status recorded when there was no HTTP response at all.
NO_RESPONSE = 0
# Note added to a host whose HTTPS requests all failed (no connection or invalid certificate).
NO_HTTPS_NOTE = 'Status 0: no HTTPS response (connection failed or the certificate is not valid).'
# Key order of a host record, so that a refresh produces a small diff.
HOST_KEYS = ('host', 'role', 'sld', 'ct', 'dns_a', 'http_root', 'https_root', 'https_unknown_path', 'note')


class NoRedirect(urllib.request.HTTPRedirectHandler):
  """Makes urllib report a redirect as an HTTPError instead of following it."""

  def redirect_request(self, req, fp, code, msg, headers, newurl):
    return None


NO_REDIRECT_OPENER = urllib.request.build_opener(NoRedirect)


def log(message):
  """Prints a progress line to stderr, so stdout stays clean."""
  print(message, file=sys.stderr, flush=True)


def request_once(url, method='GET'):
  """
  Sends one request without following redirects.

  Returns (status, absolute Location or None, headers or None). Status 0 means no HTTP
  response at all: DNS, TCP or TLS failed.
  """
  req = urllib.request.Request(url, method=method, headers={'User-Agent': USER_AGENT})
  try:
    with NO_REDIRECT_OPENER.open(req, timeout=TIMEOUT_SEC) as resp:
      return resp.status, None, resp.headers
  except urllib.error.HTTPError as err:
    location = err.headers.get('Location')
    err.close()
    return err.code, absolute_location(url, location) if location else None, err.headers
  except (urllib.error.URLError, OSError):
    return NO_RESPONSE, None, None


def absolute_location(base, location):
  """Resolves a Location header against the request URL; an empty path becomes '/', as curl reports it."""
  parts = urllib.parse.urlsplit(urllib.parse.urljoin(base, location))
  if parts.path:
    return parts.geturl()
  return parts._replace(path='/').geturl()


def redirect_chain(url, max_hops=6):
  """Follows redirects one hop at a time and returns every hop."""
  hops = []
  for _ in range(max_hops):
    status, location, _ = request_once(url)
    hop = {'url': url, 'status': status}
    if location:
      hop['location'] = location
    hops.append(hop)
    if not location:
      break
    url = location
  return hops


def sample(url, count):
  """Requests url count times and returns the distinct responses with counts, most common first."""
  seen = collections.Counter()
  for _ in range(count):
    status, location, _ = request_once(url)
    seen[f'{status} {location}' if location else str(status)] += 1
  return [{'response': response, 'count': n} for response, n in seen.most_common()]


def fetch_json(url, retries=4, delay_sec=8):
  """Downloads and parses JSON, retrying because crt.sh often answers 502 under load."""
  for attempt in range(1, retries + 1):
    try:
      req = urllib.request.Request(url, headers={'User-Agent': USER_AGENT})
      with urllib.request.urlopen(req, timeout=90) as resp:
        return json.load(resp)
    except (urllib.error.URLError, OSError, ValueError) as err:
      log(f'  {url}: attempt {attempt} failed ({err})')
      if attempt < retries:
        time.sleep(delay_sec)
  return None


def resolve_a(name):
  """Returns the sorted A records of name, 'NXDOMAIN', or None when the lookup itself failed."""
  answer = fetch_json(f'https://dns.google/resolve?name={urllib.parse.quote(name)}&type=A', retries=2, delay_sec=2)
  if answer is None:
    return None
  if answer.get('Status') == 3:
    return 'NXDOMAIN'
  return sorted(record['data'] for record in answer.get('Answer', []) if record.get('type') == 1)


def ct_names(sld):
  """
  Returns {name: latest not_after date} for every name crt.sh lists under sld.

  Returns None when crt.sh did not answer, so the caller can keep the old data.
  """
  certificates = fetch_json(f'https://crt.sh/?q=%25.{sld}&output=json')
  if certificates is None:
    return None
  names = {}
  for cert in certificates:
    for name in cert['name_value'].lower().split('\n'):
      name = name.strip()
      if name.startswith('*.'):
        continue
      names[name] = max(names.get(name, ''), cert['not_after'][:10])
  return names


def host_sort_key(host):
  """Sorts by registered domain, then by full name."""
  return '.'.join(host.split('.')[-2:]), host


def survey_host(name, old, ct, ct_ok, samples, round_robin_samples):
  """
  Builds the record of one host; keeps the hand-written role from the old record.

  ct holds the names crt.sh returned; ct_ok the domains for which crt.sh answered.
  """
  record = {'host': name, 'role': old.get('role', ''), 'sld': '.'.join(name.split('.')[-2:])}
  record['ct'] = {'listed': name in ct}
  if name in ct:
    record['ct']['latest_not_after'] = ct[name]
  elif record['sld'] not in ct_ok and 'ct' in old:
    # crt.sh did not answer for this domain: keep what was known.
    record['ct'] = old['ct']

  record['dns_a'] = resolve_a(name)
  if record['dns_a'] is None:
    log(f'  {name}: DNS lookup failed, keeping the old record')
    return old or record
  if record['dns_a'] == 'NXDOMAIN' or not record['dns_a']:
    return record

  count = round_robin_samples if len(record['dns_a']) > 1 else samples
  record['http_root'] = redirect_chain(f'http://{name}/')
  record['https_root'] = sample(f'https://{name}/', count)
  record['https_unknown_path'] = sample(f'https://{name}{UNKNOWN_PATH}', count)

  if all(r['response'] == str(NO_RESPONSE) for r in record['https_root']):
    record['note'] = NO_HTTPS_NOTE
  return {key: record[key] for key in HOST_KEYS if key in record}


def update_hosts(path, samples, round_robin_samples):
  """Refreshes hosts.json in place."""
  doc = load_json(path)
  old_hosts = {h['host']: h for h in doc['hosts']}

  ct = {}
  ct_ok = set()
  for domain in doc['domains']:
    log(f'crt.sh: {domain["sld"]}')
    names = ct_names(domain['sld'])
    if names is None:
      log(f'  crt.sh gave no answer for {domain["sld"]}: its CT data stays as it was')
      continue
    ct.update(names)
    ct_ok.add(domain['sld'])

  # Names from CT plus names already in the file (some were added by hand and are not in CT).
  wanted = {n for n in ct if '.'.join(n.split('.')[-2:]) in {d['sld'] for d in doc['domains']}}
  wanted |= set(old_hosts)
  hosts = []
  for name in sorted(wanted, key=host_sort_key):
    log(f'host: {name}')
    hosts.append(survey_host(name, old_hosts.get(name, {}), ct, ct_ok, samples, round_robin_samples))

  new_names = wanted - set(old_hosts)
  if new_names:
    log(f'new names (add a "role" by hand): {", ".join(sorted(new_names))}')
  doc['surveyed'] = datetime.date.today().isoformat()
  doc['hosts'] = hosts
  save_json(path, doc)


def download(url, target):
  """Downloads url to target, following redirects; returns (size, sha256, md5)."""
  sha256, md5, size = hashlib.sha256(), hashlib.md5(), 0
  req = urllib.request.Request(url, headers={'User-Agent': USER_AGENT})
  with urllib.request.urlopen(req, timeout=120) as resp, open(target, 'wb') as out:
    for chunk in iter(lambda: resp.read(1 << 20), b''):
      out.write(chunk)
      sha256.update(chunk)
      md5.update(chunk)
      size += len(chunk)
  return size, sha256.hexdigest(), md5.hexdigest()


def gpg_keyring(key_url, workdir):
  """Imports the signing key into a throwaway keyring; returns GNUPGHOME, or None without gpg."""
  if not shutil.which('gpg'):
    log('gpg not found: signatures are not checked')
    return None
  home = os.path.join(workdir, 'gnupg')
  os.makedirs(home, mode=0o700)
  key_file = os.path.join(workdir, 'signing.key')
  download(key_url, key_file)
  subprocess.run(['gpg', '--batch', '-q', '--import', key_file],
                 env={**os.environ, 'GNUPGHOME': home}, capture_output=True, check=False)
  return home


def gpg_verify(gnupg_home, fingerprint, data_file, signature_file):
  """Returns 'good' when the signature is valid and made by the expected key, else 'bad'."""
  result = subprocess.run(['gpg', '--batch', '--status-fd', '1', '--verify', signature_file, data_file],
                          env={**os.environ, 'GNUPGHOME': gnupg_home}, capture_output=True, text=True, check=False)
  return 'good' if f'VALIDSIG {fingerprint}' in result.stdout else 'bad'


def manifest_hash(manifest_path, url):
  """Returns the hash a bucket manifest gives for url, or None when the URL is not in it."""
  manifest = load_json(os.path.join(REPO_ROOT, manifest_path))
  entries = [manifest] + list(manifest.get('architecture', {}).values())
  for entry in entries:
    urls = entry.get('url', [])
    hashes = entry.get('hash', [])
    urls, hashes = ([urls], [hashes]) if isinstance(urls, str) else (urls, hashes)
    for candidate, value in zip(urls, hashes):
      if candidate.split('#')[0] == url:
        return value.lower()
  return None


def check_file(entry, workdir, gnupg_home, fingerprint):
  """Re-checks one downloads.json entry in place; returns a list of problems."""
  problems = []
  target = os.path.join(workdir, 'file')
  try:
    entry['size'], entry['sha256'], md5 = download(entry['url'], target)
  except (urllib.error.URLError, OSError) as err:
    return [f'{entry["url"]}: download failed ({err})']

  if 'md5' in entry:
    entry['md5'] = md5
  if 'gpg' in entry and gnupg_home:
    signature = target + '.asc'
    download(entry['url'] + '.asc', signature)
    entry['gpg'] = gpg_verify(gnupg_home, fingerprint, target, signature)
    if entry['gpg'] != 'good':
      problems.append(f'{entry["url"]}: bad GPG signature')

  if 'manifest' in entry:
    expected = manifest_hash(entry['manifest'], entry['url'])
    if expected != entry['sha256']:
      problems.append(f'{entry["url"]}: {entry["manifest"]} has {expected}, the file is {entry["sha256"]}')

  for mirror in entry.get('identical_on', []):
    if mirror == entry['url']:
      continue
    try:
      _, mirror_sha, _ = download(mirror, target)
    except (urllib.error.URLError, OSError) as err:
      problems.append(f'{mirror}: download failed ({err})')
      continue
    if mirror_sha != entry['sha256']:
      problems.append(f'{mirror}: differs from {entry["url"]}')
  return problems


def update_downloads(path):
  """Refreshes downloads.json in place; returns a list of problems."""
  doc = load_json(path)
  key = doc['signing_key']
  problems = []
  with tempfile.TemporaryDirectory() as workdir:
    gnupg_home = gpg_keyring(key['url'], workdir)
    for entry in doc['files']:
      log(f'file: {entry["url"]}')
      problems += check_file(entry, workdir, gnupg_home, key['fingerprint'])

  for entry in doc.get('listed_not_downloaded', {}).get('files', []):
    status, _, headers = request_once(entry['url'], method='HEAD')
    if status != 200 or headers is None or not headers.get('Content-Length'):
      problems.append(f'{entry["url"]}: HEAD answered {status}')
      continue
    entry['size'] = int(headers['Content-Length'])

  doc['checked'] = datetime.date.today().isoformat()
  save_json(path, doc)
  return problems


def load_json(path):
  """Reads a UTF-8 JSON file, keeping the key order."""
  with open(path, encoding='utf-8') as f:
    return json.load(f)


def save_json(path, doc):
  """Writes JSON in the repository's style: 4-space indent, CRLF, final newline (.editorconfig)."""
  with open(path, 'w', encoding='utf-8', newline='\r\n') as f:
    f.write(json.dumps(doc, indent=4, ensure_ascii=False) + '\n')


def main():
  parser = argparse.ArgumentParser(description=__doc__.strip().splitlines()[0])
  parser.add_argument('notes', nargs='?', default=DEFAULT_NOTES, help='folder with hosts.json and downloads.json')
  parser.add_argument('--samples', type=int, default=3, help='requests per URL for single-address hosts')
  parser.add_argument('--round-robin-samples', type=int, default=12, help='requests per URL for hosts with several addresses')
  parser.add_argument('--skip-hosts', action='store_true', help='do not refresh hosts.json')
  parser.add_argument('--skip-downloads', action='store_true', help='do not refresh downloads.json')
  args = parser.parse_args()

  if not os.path.isdir(args.notes):
    parser.error(f'{args.notes} is not a folder')

  if not args.skip_hosts:
    update_hosts(os.path.join(args.notes, 'hosts.json'), args.samples, args.round_robin_samples)

  problems = [] if args.skip_downloads else update_downloads(os.path.join(args.notes, 'downloads.json'))
  for problem in problems:
    log(f'PROBLEM: {problem}')
  return 1 if problems else 0


if __name__ == '__main__':
  sys.exit(main())
