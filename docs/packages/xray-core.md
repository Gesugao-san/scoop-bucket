# Xray-core

| | |
|---|---|
| Manifest | [`bucket/Xray-core.json`](../../bucket/Xray-core.json) |
| Upstream | [XTLS/Xray-core](https://github.com/XTLS/Xray-core) (Project X / XTLS, MPL-2.0) |
| Install | `scoop install gesu/Xray-core` |

The proxy core of Project X: VLESS (with XTLS Vision and REALITY), VMess, Trojan, Shadowsocks, WireGuard, Hysteria and more, with routing by `geoip:`/`geosite:` rules. It is the engine behind [`3X-UI`](3x-ui.md) and most V2Ray-style clients; on its own it runs from a JSON (or TOML/YAML) config.

Downloads the official Windows builds from the GitHub release: `Xray-windows-64.zip`, `Xray-windows-32.zip` and `Xray-windows-arm64-v8a.zip`. Their hashes match the SHA-256 digests GitHub shows, the `.dgst` files upstream publishes next to them, and the copies on SourceForge (downloaded and checked for 26.11.9). Autoupdate reads the `SHA2-256=` line of the `.dgst` file. Upstream also publishes `Xray-win7-*` builds for Windows 7; this package does not use them.

Each archive holds `xray.exe`, `wintun.dll` (for TUN), `geoip.dat` and `geosite.dat` (the small "lite" sets from [XTLS/Xray-rules-dat](https://github.com/XTLS/Xray-rules-dat)), upstream's `xray_no_window` scripts, `README.md` and the licenses.

## Commands and shortcut

- `xray run -c config.json` starts Xray with that config; `xray run` without `-c` reads `config.json` (or `.jsonc`, `.toml`, `.yaml`) from the current folder, otherwise `config.json` next to `xray.exe`.
- `xray x25519` (REALITY key pair), `xray uuid`, `xray tls ping <host>` (checks a REALITY target), `xray version`; `xray help` lists everything.

*Scoop Apps* gets an **Xray-core** shortcut. `xray.exe` without arguments would try to run a config, so the shortcut opens `Xray-core.cmd`, a micro-launcher written at install time that explains the main commands, prints `xray version` and `xray help`, and waits for a key.

The `config.json` next to `xray.exe` is persisted (`%USERPROFILE%\scoop\persist\Xray-core\config.json`): created as `{}` on the first install, then kept across updates, as in Scoop's [`main/xray`](https://github.com/ScoopInstaller/Main/blob/HEAD/bucket/xray.json).

## Geo files

Xray reads `geoip.dat`, `geosite.dat` and any `ext:` file from its own folder, or from the folder in `XRAY_LOCATION_ASSET`. The lite sets in the archive have only the most common categories; for others, point `XRAY_LOCATION_ASSET` at one of the geo packages of this bucket, which hold both files:

| Package | For |
|---|---|
| [`Loyalsoldier-v2ray-rules-dat`](loyalsoldier-v2ray-rules-dat.md) | full v2fly lists, ads, China direct and GFW lists |
| [`Chocolate4U-Iran-v2ray-rules`](chocolate4u-iran-v2ray-rules.md) | Iran |
| [`runetfreedom-russia-v2ray-rules-dat`](runetfreedom-russia-v2ray-rules-dat.md) | Russia |

```cmd
SET XRAY_LOCATION_ASSET=%USERPROFILE%\scoop\apps\Loyalsoldier-v2ray-rules-dat\current
```

```powershell
$env:XRAY_LOCATION_ASSET = "$env:USERPROFILE\scoop\apps\Loyalsoldier-v2ray-rules-dat\current"
```

`3X-UI` does not use the files in this package's folder: it copies `xray.exe` and `wintun.dll` into its own `bin` folder (as `xray-windows-amd64.exe`) together with the geo files of those packages.

## Conflicts

Scoop's main bucket has [`xray`](https://github.com/ScoopInstaller/Main/blob/HEAD/bucket/xray.json), the same program with the same `xray` command but no shortcut and no autoupdate hash. Only one of the two can be installed: installing this one stops while `xray` is installed. It is a portable archive that registers nothing, so copies outside Scoop (for example the one inside v2rayN) do not interfere.

## Mirrors

SourceForge copies every release automatically ([xray-core.mirror](https://sourceforge.net/projects/xray-core.mirror/), not run by the developers); the 26.11.9 archives there are byte-identical to GitHub's. [`mirrors.psd1`](../../mirrors.psd1) lists it: `.\bin\Use-Mirror.ps1 gesu/Xray-core sourceforge`, then `scoop install gesu/Xray-core`.

[All packages](../../README.md#packages)
