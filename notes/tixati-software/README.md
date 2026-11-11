# Tixati Software and WinMX: hosts, redirects and release files

Survey of 2026-11-11. It covers the hosts that `bucket/Tixati.json`, `bucket/Fopnu.json`, `bucket/DarkMX.json` and `bucket/WinMX.json` download from, the rest of their domains, and Super Simple Server (also by Tixati Software, not packaged here).

| File | Contents |
|---|---|
| [`hosts.json`](hosts.json) | Every hostname found: certificate transparency names, A records, redirect chains for `http://`, `https://` and an unknown path. Also a per-domain summary (`domains`). |
| [`downloads.json`](downloads.json) | Release files that were downloaded and checked: size, SHA-256, GPG signature, mirrors that serve the same bytes. |

The JSON files are outside `bucket/`, so Scoop's manifest tests and the pull request handler (which only looks at `bucket/*.json`) do not check them.

## Summary

### Hosting

- Tixati Software runs all four domains (`tixati.com`, `fopnu.com`, `darkmx.app`, `supersimpleserver.com`) on two addresses, `91.219.238.244` and `91.219.237.221`. Most names point only to `.244`. Both addresses are used only by `download`, `download1` and `download2.tixati.com` and by `download1`, `download2` and `download3.fopnu.com`; `download3.tixati.com` points only to `.237.221`. So the "mirrors" are the same two machines, not independent servers.
- The WinMX community domains (`winmxconex.com`, `winmxworld.com`) share one address, `84.19.186.186`.

### Where the files are

| App | Live file host | Other hosts |
|---|---|---|
| Tixati | `download.tixati.com/<file>` | `download1`–`3.tixati.com` redirect every path to `https://tixati.com/`; `download4`–`6` no longer resolve. |
| Fopnu | `download1`–`6.fopnu.com/download/<file>`, byte-identical | `download.fopnu.com` does not exist. |
| DarkMX | `download.darkmx.app/<file>` | none |
| Super Simple Server | `download.supersimpleserver.com/<file>` (`/` answers 403) | none |
| WinMX | `download.winmxconex.com/Winmx%203.54.exe` (HTTPS only) | the HTTP fallback leads to `archive.winmxworld.com`, which answers 410 Gone |

All Tixati Software files are signed with one GPG key, fingerprint `9DEA 5E35 0F9D 285E 46D3 B7E3 CE73 7F19 1AF5 DCFB`. Every hash in the four manifests matched the downloaded files, and every signature was good. The WinMX setup has no signature; its MD5 matches the one on `patch.winmxconex.com`.

### Redirects

- **HTTP to HTTPS**: everywhere on the Tixati Software domains. `tixati.com` answers 301; `fopnu.com`, `darkmx.app` and `supersimpleserver.com` answer 302. The exception is `errortracker.*`: it redirects `http://` to `http://…/?history` (still HTTP), which answers 403.
- **www**: `www.tixati.com` (301) and `www.darkmx.app` (302) go to the apex and keep the path. `www.supersimpleserver.com` goes to the apex root and drops the path. `fopnu.com` and `www.fopnu.com` both answer 200, so Fopnu has no canonical name, and its download hosts redirect to `www`.
- **Path dropped**: `download1`–`3.tixati.com` go to `https://tixati.com/`, and `online-help.*` go to `support.*/`.
- **WinMX**: every `http://` request on `winmxconex.com` answers 308 to `https://archive.winmxworld.com` with the path kept. `winmxworld.com` answers 301 to `www`. `winmxconex.com` itself has no A record (mail only, MX `mail.winmxconex.net`).

### The two servers behind round-robin answer differently

`https://download1.fopnu.com/` (and `download2`, `download3`) answered `200` on some requests and `302 → https://www.fopnu.com/` on others, about half and half over 12 requests each. Unknown paths behave the same way: on one server they answer 404, on the other they redirect to `www.fopnu.com`. The real files under `/download/` answered 200 every time, so Scoop is not affected, but a check of these roots gives a random result.

### Broken or gone

| Name | State |
|---|---|
| `download4`–`6.tixati.com` | no DNS; last certificate expired 2025-01-19 |
| `testforum.*`, `testsupport.*` (tixati, fopnu) | no DNS; last certificate expired 2019-05-12 |
| `download.fopnu.com`, `mail.winmxconex.com` | no DNS |
| `winmxworld.com`, `www.winmxconex.com` | HTTPS without a valid certificate |
| `archive.winmxworld.com/Winmx%203.54.exe` | 410 Gone |

### Super Simple Server

Version 1.25 of 2022-12-07 is the latest; the news page shows no release since. Windows (zip with one `supersimpleserver.exe`), Linux GTK and Linux CLI, each 64- and 32-bit, all signed with the key above. A web server without updates for years should not face the internet without a reason.

## Method

Run from a cloud workspace outside Russia, through an HTTPS-inspecting proxy, on 2026-11-11.

- **Names**: `https://crt.sh/?q=%25.<domain>&output=json` for each domain, all certificates including expired ones, plus a few names guessed from the patterns (`download.fopnu.com`, `www.winmxconex.com`).
- **DNS**: `https://dns.google/resolve?name=<host>&type=A`.
- **Redirects**: `curl -s -o /dev/null -w '%{http_code}|%{redirect_url}'`, one hop at a time, without following redirects.
- **Files**: downloaded with curl, hashed with `sha256sum`, signatures checked with `gpg --verify <file>.asc <file>` against `https://tixati.com/tixati.key`.

### Refreshing

[`bin/update-host-notes.py`](../../bin/update-host-notes.py) repeats all of the above and rewrites both JSON files in place. It needs Python 3 (standard library only) and, for the signatures, `gpg` on PATH (`scoop install gpg`); without `gpg` the signatures are skipped.

```sh
python bin/update-host-notes.py                    # hosts.json and downloads.json
python bin/update-host-notes.py --skip-downloads   # hosts.json only, no ~400 MB of downloads
```

It keeps the hand-written parts (`domains`, each host's `role`) and lists any new name from crt.sh so a role can be added. It exits with 1 when a signature is bad, a file no longer matches its manifest, or a Fopnu mirror serves different bytes. Run from Russia, it shows what is blocked or filtered on the way, compared with these results from outside.

## Limits

- The proxy re-signs every certificate, so the real certificates were not seen. It does reject invalid upstream certificates ("self-signed certificate" on `winmxworld.com` and `www.winmxconex.com`), so a host that answered over HTTPS had a valid certificate at that moment. In `hosts.json` a request without any HTTP response (no connection or an invalid certificate) shows as status `0`.
- crt.sh can lag: for some names that work fine (`*.winmxconex.com`, `forum`, `help` and `update-check.supersimpleserver.com`) the latest certificate it lists has already expired. Treat `ct.latest_not_after` as a lower bound, not as the live certificate.
- The GPG key comes from the same site as the files. A good signature proves the files are intact and signed by that key, not who owns the key.
- Results from Russia can differ: a host that works here may be blocked or filtered there.
