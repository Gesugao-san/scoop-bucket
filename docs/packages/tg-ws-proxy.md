# TG-WS-Proxy

| | |
|---|---|
| Manifest | [`bucket/TG-WS-Proxy.json`](../../bucket/TG-WS-Proxy.json) |
| Upstream | [Flowseal/tg-ws-proxy](https://github.com/Flowseal/tg-ws-proxy) (MIT) |
| Install | `scoop install gesu/TG-WS-Proxy` |

TG WS Proxy, by the author of [zapret-discord-youtube](zapret-discord-youtube.md): a local MTProto proxy for Telegram Desktop. Telegram connects to it on `127.0.0.1:1443`, and it carries the traffic to Telegram's data centres over WebSocket (optionally through Cloudflare), which helps where Telegram is slowed down or blocked. It is a tray app with a settings window; Flowseal's README describes the options (Cloudflare proxy and workers, fake TLS, test DCs).

Downloads the single-file build from the GitHub release and saves it as `TgWsProxy.exe`: `TgWsProxy_windows.exe` (Windows 10+ x64), `TgWsProxy_windows_arm64.exe` (Windows 10+ ARM64), and on 32-bit Windows upstream's `TgWsProxy_windows_7_32bit.exe`. The `TgWsProxy_windows_7_64bit.exe` build for Windows 7 x64 is not used. Hashes match the SHA-256 digests GitHub shows and the SourceForge copies (checked for 1.11.4). The exe is not Authenticode-signed (upstream's release workflow has a SignPath step, but the 1.11.4 file carries no signature), so SmartScreen may warn on the first start. It is a PyInstaller build: it unpacks itself into `%TEMP%` on every start.

## Using it

*Scoop Apps* gets a **TG WS Proxy** shortcut. On the first start the proxy opens a window with instructions; then it lives in the tray. Right-click the tray icon → **Open in Telegram** sets Telegram Desktop up through a `tg://proxy` link; or add an MTProto proxy `127.0.0.1`, port `1443`, with the secret from **Settings**, by hand.

**Start with Windows** (in Settings) writes a `TgWsProxy` entry under `HKCU\...\Run` pointing at the exe it was started from, which is `...\apps\TG-WS-Proxy\current\TgWsProxy.exe` when started from the shortcut, so it survives updates. `scoop uninstall` removes that entry when it points into this package.

## Data

`TgWsProxy_data` next to the exe switches the app to portable mode, so `persist` keeps it in `%USERPROFILE%\scoop\persist\TG-WS-Proxy\TgWsProxy_data`: `config.json` (port, secret, Cloudflare settings...), the log and the lock files. On a first install the folder is created with a `config.json` that only turns off `check_updates`: the app would otherwise offer to replace its own exe from GitHub, which a Scoop install does not want; it fills in everything else and saves it on its first start. If `%APPDATA%\TgWsProxy` exists from an earlier non-portable copy, the app moves its files into the empty portable folder on its first start (upstream's own migration), so the secret and settings carry over.

## Conflicts

A fresh install stops while a TG WS Proxy runs anywhere (it would hold port 1443 and its data), and `scoop update` and `scoop uninstall` stop while it runs or its data files are open ([`Test-AppBusy.ps1`](../../scripts/common/Test-AppBusy.ps1)). Exit it from its tray menu first. Not in Scoop's main or extras bucket (November 2026). `checkver` follows the latest GitHub release.

## Mirrors

Upstream's release notes offer the SourceForge copy to those who cannot reach GitHub ([tg-ws-proxy.mirror](https://sourceforge.net/projects/tg-ws-proxy.mirror/)); all three builds there are byte-identical to GitHub's for 1.11.4. `.\bin\Use-Mirror.ps1 gesu/TG-WS-Proxy sourceforge`.

[All packages](../../README.md#packages)
