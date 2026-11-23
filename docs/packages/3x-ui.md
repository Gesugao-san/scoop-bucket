# 3X-UI

| | |
|---|---|
| Manifest | [`bucket/3X-UI.json`](../../bucket/3X-UI.json) |
| Upstream | [MHSanaei/3x-ui](https://github.com/MHSanaei/3x-ui) (GPL-3.0) |
| Install | `scoop install gesu/3X-UI` |

Web panel for [Xray-core](xray-core.md): inbounds for VLESS, VMess, Trojan, Shadowsocks, WireGuard, Hysteria, TUIC, MASQUE, MTProto and AmneziaWG with many clients each, traffic and expiry limits per client, subscription links (raw, JSON, Clash), a Telegram bot, routing and outbound settings, and master/node management of several servers. Upstream builds it mainly for Linux servers; the Windows build is the same panel without the Linux-only parts (fail2ban for the IP limit, the `x-ui` bash menu, the self-update script, the AmneziaWG kernel module).

Downloads upstream's `x-ui-windows-amd64.zip` from the GitHub release (the only Windows build; on ARM64 Windows Scoop falls back to it, emulated). The hash is the SHA-256 digest GitHub shows for the asset; autoupdate reads `x-ui-windows-amd64.zip.sha256` next to it. The archive could not be downloaded where this package was written, so nothing in it was checked beyond its layout in upstream's [release workflow](https://github.com/MHSanaei/3x-ui/blob/v3.11.0/.github/workflows/release.yml): run `.\bin\checkhashes.ps1 3X-UI` on Windows. No mirror: upstream publishes only on GitHub.

## Components as packages

The release archive bundles everything the panel runs besides itself in `bin`: Xray (`xray-windows-amd64.exe` with `wintun.dll`), the MTProto proxy (`mtg-windows-amd64.exe`, from [mtg-multi](mtg-multi.md)), and six geo files, all as they were when upstream built the release. Here each of them is a package of its own, updated by Scoop:

| File in the panel's `bin` | Package | Install |
|---|---|---|
| `xray-windows-amd64.exe`, `wintun.dll` | [`Xray-core`](xray-core.md) (`xray.exe`, `wintun.dll`) | dependency |
| `mtg-windows-amd64.exe` | [`mtg-multi`](mtg-multi.md) (`mtg-multi.exe`) | dependency |
| `geoip.dat`, `geosite.dat` | [`Loyalsoldier-v2ray-rules-dat`](loyalsoldier-v2ray-rules-dat.md) | dependency |
| `geoip_IR.dat`, `geosite_IR.dat` | [`Chocolate4U-Iran-v2ray-rules`](chocolate4u-iran-v2ray-rules.md) (`geoip.dat`, `geosite.dat`) | suggested |
| `geoip_RU.dat`, `geosite_RU.dat` | [`runetfreedom-russia-v2ray-rules-dat`](runetfreedom-russia-v2ray-rules-dat.md) (`geoip.dat`, `geosite.dat`) | suggested |

The Iran and Russia files are only suggested: they matter only for routing rules that name them (`ext:geosite_RU.dat:ru-blocked` and the like), and the Russian `geosite.dat` alone is about 90 MB, rebuilt every 6 hours. Without them the panel uses the copies from its own release archive, which the install keeps in `bundled` (the same fallback applies to any component whose package is missing).

The panel finds all of these by fixed names in one folder. [`Start-3XUI.ps1`](../../scripts/3x-ui/Start-3XUI.ps1), which the install copies from this bucket, fills that folder each time the panel starts:

1. It sets `XUI_DB_FOLDER`, `XUI_LOG_FOLDER` and `XUI_BIN_FOLDER` (unless they are already set) to `data`, `log` and `bin` in the app folder. Without them the Windows build keeps its database next to `3x-ui.exe` (which Scoop replaces on update) and `log` and `bin` in whatever folder it was started from.
2. For `3x-ui run` (or `3x-ui` alone), it copies each file in the table from its package into `bin`, only when the package's copy differs (size or modification time), and prints where each file came from. Packages are looked up in the same Scoop apps folder as 3X-UI first, then in the user and global Scoop folders.
3. It starts `3x-ui.exe` with the given arguments.

Copies rather than links: the panel and its Xray then keep no file of the other packages open, so `scoop update Xray-core` (or any geo package) works while the panel runs, and the panel picks the new version up at its next start. The flip side: when you update Xray or the geo files from the panel itself (Panel Settings), the next start puts the packages' versions back. Update them with Scoop instead, or uninstall the package in question to let the panel manage that file.

## Starting the panel

*Scoop Apps* gets a **3X-UI** shortcut (with the panel's own icon). It opens [`3X-UI.cmd`](../../scripts/3x-ui/3X-UI.cmd), which shows the address and where the data lives, runs `Start-3XUI.ps1 run` and, after the panel stops, waits for a key so the log stays readable. The panel runs as long as that window is open (Ctrl+C stops it), as upstream's [`readme.txt`](https://github.com/MHSanaei/3x-ui/blob/v3.11.0/windows_files/readme.txt) says; there is no service. A second start from the same installation is refused while the first one runs.

- **Address:** `http://localhost:2053/` (port `2053`, base path `/`) until you change them in Panel Settings. `3x-ui setting -show` prints the current values.
- **Login:** on the very first start the panel creates a user with a random name and password and prints them **once** in the log (`No panel user existed, so one was generated. Username: ...  Password: ...`). The `admin`/`admin` in upstream's `readme.txt` is outdated. If you lose them, stop the panel and run `3x-ui setting -username NAME -password PASS`.
- **Firewall:** Windows asks on the first start whether `3x-ui.exe` (and later Xray) may accept connections; allow them for the networks your clients come from.

The `3x-ui` command is `Start-3XUI.ps1` too, so the other commands of the panel work on the persisted database: `3x-ui setting -show`, `3x-ui setting -port 8443`, `3x-ui setting -webBasePath /mypanel/`, `3x-ui setting -webCert C:\certs\panel.crt -webCertKey C:\certs\panel.key`, `3x-ui migrate-db --dump ...`. `3x-ui -h` lists them.

## Data

`persist` keeps three folders in `%USERPROFILE%\scoop\persist\3X-UI` across updates and `scoop uninstall` (only `scoop uninstall -p` deletes them):

| Folder | Holds |
|---|---|
| `data` | `x-ui.db` (settings, users, inbounds, clients, traffic), metrics history, TUIC traffic journal |
| `log` | the panel's logs, Xray crash reports, IP-limit logs |
| `bin` | the components above, plus what the panel writes there: Xray's `config.json` (rebuilt from the database on every start) and the MTProto configs in `mtproto` |

To use PostgreSQL instead of SQLite, set `XUI_DB_TYPE=postgres` and `XUI_DB_DSN` before starting; `Start-3XUI.ps1` leaves variables that are already set alone, so `XUI_DB_FOLDER` and the others can point elsewhere too. [DB Browser for SQLite](https://sqlitebrowser.org/) (`scoop install extras/sqlitebrowser`, suggested) opens `x-ui.db`; close it before starting the panel.

## Certificates

The release archive also carries an OpenSSL installer (`SSL\Win64OpenSSL_Light-4_0_3.msi`) for making a self-signed certificate. The install deletes it; [`OpenSSL-Light`](openssl-light.md) (suggested) is the same tool from the same publisher, unpacked instead of installed:

```cmd
openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout localhost.key -out localhost.crt -subj /CN=localhost
3x-ui setting -webCert "%CD%\localhost.crt" -webCertKey "%CD%\localhost.key"
```

## Updates

`checkver` follows upstream's latest release (not the rolling `dev-latest` pre-release); autoupdate takes the hash from the `.sha256` file. `scoop update 3X-UI` stops while the panel runs (see below). The components update on their own schedules, each through its package.

## Conflicts

Not in Scoop's main or extras bucket (November 2026); other buckets could not be searched on [scoop.sh](https://scoop.sh/) from where this package was written. It is a portable archive without an installer, so there is no copy installed outside Scoop to detect. Instead, installing stops while any 3X-UI panel, its `xray-windows-amd64` or its `mtg-windows-amd64` runs anywhere (two panels would fight over port 2053), and `scoop update` and `scoop uninstall` stop while the panel runs or its database is open, before anything is removed ([`Test-AppBusy.ps1`](../../scripts/common/Test-AppBusy.ps1), see [Programs that are running or have files open](../conventions.md#programs-that-are-running-or-have-files-open)). A stopped install leaves the downloaded version behind; install again or run `scoop uninstall 3X-UI` to clean it up.

[All packages](../../README.md#packages)
