# RealiTLScanner

| | |
|---|---|
| Manifest | [`bucket/RealiTLScanner.json`](../../bucket/RealiTLScanner.json) |
| Upstream | [XTLS/RealiTLScanner](https://github.com/XTLS/RealiTLScanner) (Project X / XTLS, MPL-2.0) |
| Install | `scoop install gesu/RealiTLScanner` |

Scanner from the authors of [Xray](https://github.com/XTLS/Xray-core) that looks for TLS servers suitable as the camouflage target of a REALITY inbound (its `dest` and `serverNames`). It connects to each target on port 443 (or `-port`), offers X25519 and X25519MLKEM768 key exchange, and counts a server as feasible when it answers with TLS 1.3, negotiates HTTP/2 (`h2`) and has a certificate with a common name and an issuer organisation ([`scanner.go`](https://github.com/XTLS/RealiTLScanner/blob/v0.2.3/scanner.go)). Feasible servers go to a CSV file with the IP, the name scanned, TLS version, ALPN, key exchange, certificate chain size, signature and key algorithms, certificate domain, issuer and, optionally, country code. Upstream recommends running it from home rather than from a VPS, as scanning from a server may get that server flagged.

Downloads the official `RealiTLScanner-windows-64.exe` from the GitHub release, renamed to `RealiTLScanner.exe`. It is the only Windows build: upstream ships none for 32-bit or ARM64 Windows (on ARM64 Windows Scoop falls back to the x64 one, which runs emulated). The hash matches the SHA-256 digest GitHub shows for the asset, and the binary's embedded build information points to the `v0.2.3` tag commit (`e5e1147`, Go 1.26.0, unmodified tree). Upstream publishes no checksum file, so autoupdate lets Scoop compute the hash from the download. No mirror: upstream publishes only on GitHub.

[VirusTotal](https://www.virustotal.com/gui/file/03d4b8fa92cbc23e92d1af70ca74f90f650f1f51d19a5d769016dd71964559e4) (0.2.3, November 2026): 1 of 71 engines, Bkav Pro with the generic `W32.Malware.ACEA2513`; every other engine finds nothing. A lone generic detection from Bkav is a common false positive, and the build information above matches the tagged source.

For a window instead of the console, see [`RealiTLScanner-GUI`](realitlscanner-gui.md), which uses this package's scanner.

## Commands and shortcuts

- `realitlscanner -addr <IP, CIDR or domain>`: a CIDR range is scanned once. A single IP or domain starts **infinite mode**: the scanner resolves it, then walks to the neighbouring addresses in both directions until you press Ctrl+C.
- `realitlscanner -in <file>`: IPs, ranges or domains from a file, one per line. Domains from a file are scanned with their name as SNI.
- `realitlscanner -url <URL>`: downloads a page, takes every domain linked from it and scans those (upstream's example is the list of Ubuntu mirrors).
- Options: `-port` (443), `-thread` (2 concurrent scans; the upstream README still says 1), `-timeout` (10 seconds), `-out` (`out.csv`), `-46` (also IPv6), `-v` (also log failed and unsuitable targets). `realitlscanner -h` lists them.

*Scoop Apps* gets a **RealiTLScanner** shortcut. `RealiTLScanner.exe` without arguments only prints an error and its flags and exits at once, so the shortcut opens `RealiTLScanner.cmd`, a micro-launcher written at install time that explains the command, shows examples and waits for a key.

## Scanning one range: `realitlscanner-scan`

[`RealiTLScanner-Scan.cmd`](../../scripts/realitlscanner/RealiTLScanner-Scan.cmd), copied into the app folder at install time, is the command `realitlscanner-scan` and the **RealiTLScanner scan** shortcut in *Scoop Apps*. It scans one IPv4 range **once** and stops by itself, never in infinite mode:

- `realitlscanner-scan 203.0.113.0/24` scans that range; `realitlscanner-scan 203.0.113.10` scans the /24 around the address (`203.0.113.0/24`). Domains are refused, since a domain or a single IP would start infinite mode; run `realitlscanner` directly for those.
- Without an argument (the shortcut) it asks. Enter takes the last range it scanned, or on the first run the /24 around your public IPv4 address, which it asks [Cloudflare](https://1.1.1.1/cdn-cgi/trace) for (then [ipify](https://api.ipify.org)). Behind a VPN, or a proxy on the router, that is the exit's address rather than your provider's. The pause at the end is only there when it asked.
- Settings at the top of the script: 10 threads, port 443, 10-second timeout, `-v` (also log failed and unsuitable targets).
- It runs the scanner through `RealiTLScanner.ps1`, so `GEO_CODE` comes from `Loyalsoldier-GeoIP` as described below.
- Results go to `results\<yyyy-MM-dd_HH-mm-ss>_<range>.csv`, for example `2026-11-21_17-07-45_203.0.113.0-24.csv`. The time stamp comes from PowerShell, so it does not depend on the Windows date format (`DATE /T` gives day and month in locale order). `results` is the manifest's `persist` folder: it lives in `~\scoop\persist\RealiTLScanner\results` (under `C:\ProgramData\scoop` for a global install), survives updates and `scoop uninstall`, and only `scoop uninstall -p` deletes it. The last range scanned is kept there too, in `last-target.txt`. At the end the script prints how many suitable servers it found and the file name.

## Results and GeoIP

The scanner opens both of its files relative to its **working folder**, not to the Scoop app folder ([`main.go`](https://github.com/XTLS/RealiTLScanner/blob/v0.2.3/main.go), [`geo.go`](https://github.com/XTLS/RealiTLScanner/blob/v0.2.3/geo.go)): the results file `out.csv` (overwritten on every run; another name with `-out`, no file with `-out ""`) and the GeoIP database, which must be named exactly `Country.mmdb`. Without the database every `GEO_CODE` is `N/A`.

### GeoIP

The `realitlscanner` command is not the exe itself but [`RealiTLScanner.ps1`](../../scripts/realitlscanner/RealiTLScanner.ps1), a wrapper the installer copies from this bucket. It picks the database like this:

1. **A `Country.mmdb` in the current folder** wins: the scanner runs there unchanged, as upstream documents it.
2. Otherwise, **[`Loyalsoldier-GeoIP`](loyalsoldier-geoip.md)** (suggested on install: `scoop install gesu/Loyalsoldier-GeoIP`). The wrapper looks for it in the same Scoop apps folder first, then in the user and global Scoop folders, copies the file to `%TEMP%\RealiTLScanner-GeoIP\<name>\Country.mmdb` (again only after the package updates it) and starts the scanner in that folder. The copy keeps the package folder free, so `scoop update Loyalsoldier-GeoIP` works during a long scan; while one scan runs, another one that finds a newer database keeps using the old copy and says so.
3. **No database:** the scanner runs unchanged and logs that GeoIP is off.

Because the scanner then runs in another folder, the wrapper makes the paths of `-in` and `-out` absolute against the current folder and passes the default `-out` explicitly: `out.csv` still lands where you started the scan. It prints the database it uses to stderr (`GeoIP database: ...`).

`Country.mmdb` from Loyalsoldier gives the ranges of Cloudflare, CloudFront, Fastly, Google, Facebook, Netflix, Telegram, Twitter and Tor their list name instead of a country (`CLOUDFLARE`, `GOOGLE`, ...), which marks CDN addresses in the results at a glance. Choose another database with `GESU_GEOIP_MMDB`, for the current shell (`$env:GESU_GEOIP_MMDB = '...'` in PowerShell, `SET GESU_GEOIP_MMDB=...` in cmd) or permanently in the user environment:

| Value | Effect |
|---|---|
| (not set) | `Country.mmdb` from `Loyalsoldier-GeoIP` |
| `Country-without-asn.mmdb` | Plain country codes (`1.1.1.1` → `AU` instead of `CLOUDFLARE`); any file name from the package works |
| A full path, e.g. `D:\geo\GeoLite2-Country.mmdb` | Any MaxMind Country database, under any name |
| `none` | No GeoIP |

The scanner itself writes nothing into the app folder; only `realitlscanner-scan` keeps its results, in the persisted `results` folder.

## Proxies

On start the scanner clears `HTTP_PROXY`, `HTTPS_PROXY`, `ALL_PROXY` and `NO_PROXY` for itself, so both the scans and the `-url` download always go direct, even if a proxy is set in the environment. Routing on the router (for example a proxy or VPN on OpenWrt) still applies, so the results show what your connection reaches through it.

## Conflicts

Not in Scoop's official buckets. A search of all buckets on [scoop.sh](https://scoop.sh/) (November 2026) finds it only in [okibcn/ScoopMaster](https://github.com/okibcn/ScoopMaster) ([`RealiTLScanner.json`](https://github.com/okibcn/ScoopMaster/blob/HEAD/bucket/RealiTLScanner.json)), an aggregate of other buckets, which is **stuck at 0.2.1** (February 2024) even though its `autoupdate` would work, and has no shortcut. With both buckets added, Scoop treats `ScoopMaster/RealiTLScanner` and `gesu/RealiTLScanner` as the same app: uninstall one before installing the other. There is no check for copies installed without Scoop: the scanner is a single portable exe that registers nothing, so another copy does not interfere.

[All packages](../../README.md#packages)
