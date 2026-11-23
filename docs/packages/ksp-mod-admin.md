# KSP-Mod-Admin

| | |
|---|---|
| Manifest | [`bucket/KSP-Mod-Admin.json`](../../bucket/KSP-Mod-Admin.json) |
| Upstream | [MacTee/KSP-Mod-Admin-aOS](https://github.com/MacTee/KSP-Mod-Admin-aOS) (CC BY-NC-SA 3.0 DE), [forum thread](https://forum.kerbalspaceprogram.com/topic/24011-anyos-ksp-mod-admin-v2-mod-install-with-a-few-clicks/) |
| Install | `scoop install gesu/KSP-Mod-Admin   # KSP mod manager, abandoned` |

KSP Mod Admin aOS (KMA², by Bastian Heinrich, "MacTee") manages Kerbal Space Program mods without a central index: you add a mod archive (ZIP, RAR, 7z) by drag and drop, file or URL (KSP forum, CurseForge, SpaceDock, GitHub, BitBucket), tick the parts of it to install, and KMA² copies them into the game, finds the destination folder, detects files shared by several mods and checks the mods' pages for updates. Plugins add tabs for backups, flags, and parts and crafts. It grew out of MacTee's *KSP Mod Manager* from 2013 (0.9.0, the same author and the same readme), renamed KSP Mod Admin later.

**Upstream is abandoned**: the last release, 2.3.0.9, is from 2019-04-27, and CurseForge marks the project *Abandoned*. Its site parsers (for the URL feature and mod update checks) depend on those sites' HTML and may have broken since. For a maintained mod manager, use [`CKAN`](ckan.md).

## Download

GitHub releases carry only source archives. The Windows build comes from the author's own server, the link in the [release notes](https://github.com/MacTee/KSP-Mod-Admin-aOS/releases/tag/2.3.0.9) (`build=win`; `build=mono` is the Linux and macOS build). The server still answers in 2026, but only over plain HTTP: HTTPS on `www.services.mactee.de` fails the TLS handshake. The download is therefore protected only by the manifest's hash, and the bucket's [TLS check](../automation.md#checking-tls) reports the host as `WARN plain HTTP`. The link carries no version (the server always sends the latest build), so the URL keeps a `#/KSPModAdmin-v<version>_Win.zip` file name for Scoop's cache. No mirror is known.

The archive holds `v2.3.0.9\KSPModAdmin\` (the program, which the manifest installs), a copy of the sources (`KSP-Mod-Admin-aOS.zip`) and Microsoft's .NET Framework 4.5 web installer (`NeededInstallations\`), which the manifest leaves out.

KMA² targets .NET Framework 4.5.1, part of Windows 8.1 and later; elsewhere install [`NetFx-4`](netfx-4.md) (suggested by the manifest). The shortcut in Scoop Apps is *KSP Mod Admin*.

## Updates

`checkver` follows the GitHub release tags (`2.3.0.9`, no `v`), and autoupdate takes the new hash from the author's server. The package is listed as EOL in [`update-tiers.json`](../../update-tiers.json), so it is checked once a month and returns to the regular schedule if upstream ever releases again.

KMA² has its own update check and updater (`KSPModAdmin.Updater.exe`), which replaces the files in its folder. Leave *Check for new version on startup* (Options tab) off and update with `scoop update KSP-Mod-Admin`, so Scoop's record of the installed version stays right.

## Data

KMA² does not keep its settings next to the exe:

| What | Where |
|---|---|
| Settings and the list of KSP installs | `%ProgramData%\KSPModAdmin\KSPModAdmin\KSPModAdmin_aOS.cfg` (Windows Forms' common app data folder with the version part removed; the company name is empty in the exe, so .NET uses the namespace `KSPModAdmin`) |
| Each install's mod selection | `KSPModAdmin_aOS.cfg` in the KSP folder |
| Downloaded mod archives | `%USERPROFILE%\Downloads` by default (Options) |
| Log | `KSPMA.log` next to the exe |

Only the log lives in the app folder, so the manifest persists `KSPMA.log` (created empty in `pre_install`, so that Scoop does not make it a folder). Nothing else is touched by `scoop uninstall -p`. The settings path is worked out from the source; check it on your machine.

KMA² writes mods into the game folder, so a game under `%ProgramFiles(x86)%` (a Steam library in its default place) needs KMA² started as administrator, like any other tool that changes files there.

## Other buckets

At the time of writing, Scoop's Main, Extras and Games buckets and the DEV-tools bucket have no KSP Mod Admin package.

[All packages](../../README.md#packages)
