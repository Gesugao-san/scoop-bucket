# Borderless-Gaming

| | |
|---|---|
| Manifest | [`bucket/Borderless-Gaming.json`](../../bucket/Borderless-Gaming.json) |
| Upstream | [legacy.borderlessgam.ing](https://legacy.borderlessgam.ing) ([andrewmd5/Borderless-Gaming](https://github.com/andrewmd5/Borderless-Gaming), GPL-2.0) |
| Install | `scoop install gesu/Borderless-Gaming` |

Turns windowed games into borderless fullscreen windows, so Alt-Tab is instant. This is the free **legacy** edition: [9.6.0](https://github.com/andrewmd5/Borderless-Gaming/releases/tag/9.6.0) is its final, code-signed "sunset" release, with the built-in updater and Steam integration removed. The maintained rewrite (10.x) is paid and sold only on [Steam (app 388080)](https://store.steampowered.com/app/388080/Borderless_Gaming/); it is not packaged here. GitHub has no binaries for 9.6.0 (only source archives), and upstream asks users to download from the legacy site rather than mirrors, so the manifest uses that site. [`mirrors.psd1`](../../mirrors.psd1) lists one fallback, the Dropbox copy from the [gaming](https://github.com/starise/scoop-gaming) bucket, byte-identical to the official file (checked for 9.6.0, same SHA-256 `f8026c1b…a6a`; Inno Setup 6.5.0, code-signed); it is pinned to 9.6.0.

Portable: Scoop unpacks upstream's Inno Setup installer (`BorderlessGaming9.6_admin_setup.exe`) with innounp, so no admin rights are needed. Needs .NET Framework 4.8, which ships with Windows 10 1903 and newer. Settings (`config.bin`), the language files and logs live in `%APPDATA%\Andrew Sampson\Borderless Gaming` (the [code](https://github.com/andrewmd5/Borderless-Gaming/blob/9.6.0/BorderlessGaming.Logic/System/AppEnvironment.cs) builds it from the exe's company and product name), so there is nothing to `persist`; the folder survives updates and uninstall. A copy installed with upstream's setup uses the same folder, so moving to Scoop keeps the window list. *Run on startup* registers the scheduled task `BorderlessGaming` with highest privileges, pointing at the exe the app was started from (`current`, through the shortcut), so it survives updates; `scoop uninstall` removes it if it points into this package's folder, and asks for an elevated shell if Windows refuses.

Stops if Borderless Gaming is installed outside Scoop (uninstall key `Borderless Gaming_is1`, written by upstream's setup and by Chocolatey's `borderlessgaming`): remove that copy in *Settings > Apps* first. There is no `GESU_ALLOW_EXISTING` override: Scoop cannot take over a copy in Program Files, it would only add a second one sharing the same settings and startup task. Install, update and uninstall also stop while `BorderlessGaming.exe` runs from anywhere ([`Test-AppBusy.ps1`](../../scripts/common/Test-AppBusy.ps1)).

`checkver` reads the setup link from the legacy site and pads its short version (`9.6`) to the tag format (`9.6.0`); upstream publishes no hash, so Excavator computes it. As this is a final release, no update is expected; the check is there in case the legacy build is re-signed or patched. Also in the [gaming](https://github.com/starise/scoop-gaming) bucket as `borderless-gaming`, which downloads 9.6.0 from that Dropbox copy rather than the official site and has no `checkver`.

[All packages](../../README.md#packages)
