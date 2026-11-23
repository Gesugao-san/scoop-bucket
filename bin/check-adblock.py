#!/usr/bin/env python3
"""
Checks that ad blockers will not hide the bucket's images.

Ad-blocking lists carry generic rules that match a piece of a URL on any site,
such as /banner.gif in RU AdList, so an image named like an ad disappears for
everyone who runs uBlock Origin, AdGuard or Adblock Plus with that list, even
on GitHub. This script downloads the common lists, finds every image that the
bucket's Markdown shows (![...](...) and <img src="...">), and tests the URLs a
browser loads for it: github.com/<owner>/<repo>/raw/main/<path> and its
raw.githubusercontent.com redirect, plus any URL given on the command line.

The matcher understands the network filter syntax (||, |, *, ^, /regex/,
@@ exceptions, domain= and from= options, resource types) well enough for
image URLs on github.com; cosmetic filters are skipped. A list that cannot be
downloaded is reported and skipped, so run it where the full lists are
reachable for the best coverage.

Only the Python standard library is used.

Exit code: 0 when nothing is blocked, 1 when a filter matches, 2 when no list
could be downloaded.

Usage:
  python bin/check-adblock.py                 # every image in the bucket's Markdown
  python bin/check-adblock.py <url> [<url>]   # these URLs as well
"""
import glob
import os
import posixpath
import re
import sys
import urllib.request

OWNER_REPO = "Gesugao-san/scoop-bucket"
BRANCH = "main"
PAGE_HOST = "github.com"

# Full compiled lists first, then the GitHub sources of the same lists as a fallback.
LISTS = {
  "EasyList": "https://easylist.to/easylist/easylist.txt",
  "EasyPrivacy": "https://easylist.to/easylist/easyprivacy.txt",
  "RU AdList": "https://easylist-downloads.adblockplus.org/advblock.txt",
  "AdGuard Base": "https://filters.adtidy.org/extension/ublock/filters/2.txt",
  "AdGuard Russian": "https://filters.adtidy.org/extension/ublock/filters/1.txt",
  "uBlock filters": "https://raw.githubusercontent.com/uBlockOrigin/uAssets/master/filters/filters.txt",
  "EasyList general (source)": "https://raw.githubusercontent.com/easylist/easylist/master/easylist/easylist_general_block.txt",
  "EasyList dimensions (source)": "https://raw.githubusercontent.com/easylist/easylist/master/easylist/easylist_general_block_dimensions.txt",
  "EasyList third-party (source)": "https://raw.githubusercontent.com/easylist/easylist/master/easylist/easylist_thirdparty.txt",
  "EasyPrivacy general (source)": "https://raw.githubusercontent.com/easylist/easylist/master/easyprivacy/easyprivacy_general.txt",
  "RU AdList general (source)": "https://raw.githubusercontent.com/easylist/ruadlist/master/advblock/general_block.txt",
  "RU AdList third-party (source)": "https://raw.githubusercontent.com/easylist/ruadlist/master/advblock/thirdparty.txt",
  "AdGuard Base ad servers (source)": "https://raw.githubusercontent.com/AdguardTeam/AdguardFilters/master/BaseFilter/sections/adservers.txt",
  "AdGuard Base general (source)": "https://raw.githubusercontent.com/AdguardTeam/AdguardFilters/master/BaseFilter/sections/general_url.txt",
}

TYPES = {"script", "image", "stylesheet", "css", "object", "xmlhttprequest", "xhr", "subdocument", "frame",
         "ping", "websocket", "webrtc", "document", "doc", "popup", "font", "media", "other"}
# Options that change a response instead of blocking the request.
NON_BLOCKING = {"csp", "removeparam", "header", "permissions", "replace", "cookie", "hls", "jsonprune",
                "urltransform", "uritransform", "generichide", "elemhide", "specifichide", "badfilter",
                "removeheader", "stealth", "content", "extension", "jsinject", "urlblock"}
COSMETIC = ("##", "#@#", "#?#", "#$#", "#%#", "#@$#", "#@%#", "$$", "$@$")


def fetch(url):
  """Text of a list, or None when it cannot be downloaded."""
  try:
    with urllib.request.urlopen(urllib.request.Request(url, headers={"User-Agent": "check-adblock"}), timeout=60) as r:
      return r.read().decode("utf-8", errors="replace")
  except Exception as e:  # noqa: BLE001 - any failure just skips the list
    print(f"skipped {url}: {e}", file=sys.stderr)
    return None


def to_regex(pattern):
  """Regex for an ABP pattern: || host anchor, | anchors, * wildcard, ^ separator."""
  if len(pattern) > 2 and pattern.startswith("/") and pattern.endswith("/"):
    return pattern[1:-1]
  rx = ""
  if pattern.startswith("||"):
    rx, pattern = r"^[a-z]+://([^/]*\.)?", pattern[2:]
  elif pattern.startswith("|"):
    rx, pattern = "^", pattern[1:]
  end = pattern.endswith("|")
  if end:
    pattern = pattern[:-1]
  for ch in pattern:
    rx += ".*" if ch == "*" else r"(?:[^\w\-.%]|$)" if ch == "^" else re.escape(ch)
  return rx + ("$" if end else "")


def host_in(host, domains):
  return any(host == d or host.endswith("." + d) for d in domains)


def applies(options):
  """Whether a filter with these options can block an image on PAGE_HOST."""
  names = {o.partition("=")[0].lstrip("~") for o in options}
  if names & NON_BLOCKING:
    return False
  for o in options:
    key, _, value = o.partition("=")
    if key not in ("domain", "from"):
      continue
    doms = value.split("|")
    if host_in(PAGE_HOST, [d[1:] for d in doms if d.startswith("~")]):
      return False
    allowed = [d for d in doms if not d.startswith("~")]
    if allowed and not host_in(PAGE_HOST, allowed):
      return False
  wanted = [o for o in options if o in TYPES]
  if wanted and not {"image", "media", "other"} & set(wanted):
    return False
  return "~image" not in options


def parse(name, text):
  """Network filters of a list as (list name, filter text, regex, is exception)."""
  rules = []
  for line in text.splitlines():
    line = line.strip()
    if not line or line[0] in "![" or any(c in line for c in COSMETIC):
      continue
    exception = line.startswith("@@")
    body = line[2:] if exception else line
    pattern, options = body, []
    if not (body.startswith("/") and body.endswith("/")) and "$" in body:
      pattern, _, opts = body.rpartition("$")
      options = [o.strip().lower() for o in opts.split(",")]
    if not pattern or not applies(options):
      continue
    try:
      rules.append((name, line, re.compile(to_regex(pattern), re.I), exception))
    except re.error:
      continue
  return rules


def markdown_images(root):
  """Browser URLs of every image the bucket's Markdown shows."""
  urls = set()
  for md in glob.glob(os.path.join(root, "**", "*.md"), recursive=True):
    rel_md = os.path.relpath(md, root).replace(os.sep, "/")
    text = open(md, encoding="utf-8", errors="replace").read()
    for m in re.finditer(r'!\[[^\]]*\]\(([^)\s]+)|<img[^>]+src="([^"]+)"', text):
      src = m.group(1) or m.group(2)
      if src.startswith(("http://", "https://")):
        urls.add(src)
        continue
      path = posixpath.normpath(posixpath.join(posixpath.dirname(rel_md), src))
      urls.add(f"https://github.com/{OWNER_REPO}/raw/{BRANCH}/{path}")
      urls.add(f"https://raw.githubusercontent.com/{OWNER_REPO}/{BRANCH}/{path}")
  return sorted(urls)


def main(extra_urls):
  root = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
  rules = []
  for name, url in LISTS.items():
    text = fetch(url)
    if text:
      rules += parse(name, text)
  if not rules:
    print("No filter list could be downloaded.", file=sys.stderr)
    return 2
  blocked = False
  for url in markdown_images(root) + list(extra_urls):
    if any(exc and rx.search(url) for _, _, rx, exc in rules):
      print(f"ok      {url} (allowed by an exception)")
      continue
    hits = [(n, line) for n, line, rx, exc in rules if not exc and rx.search(url)]
    print(("BLOCKED " if hits else "ok      ") + url)
    for n, line in hits:
      print(f"          {n}: {line}")
    blocked |= bool(hits)
  return 1 if blocked else 0


if __name__ == "__main__":
  sys.exit(main(sys.argv[1:]))
