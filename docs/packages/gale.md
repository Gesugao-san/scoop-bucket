# Gale

| | |
|---|---|
| Manifest | [`bucket/Gale.json`](../../bucket/Gale.json) |
| Upstream | [Kesomannen/gale](https://github.com/Kesomannen/gale) (GPL-3.0) |
| Install | `scoop install gesu/Gale` |

A lightweight mod manager for games on [Thunderstore](https://thunderstore.io) (150+ games), an alternative to r2modman: profiles, one-click installs from the website, a mod config editor, profile sharing. Mod loaders such as BepInEx come in as ordinary dependencies of the mods.

No mirror: upstream's other official sources are [Thunderstore](https://thunderstore.io/c/lethal-company/p/Kesomannen/GaleModManager/) and [Hexium](https://hexium.gg/mod-manager). The Thunderstore package is a zip with the MSI inside, not a byte-identical copy that [`Use-Mirror.ps1`](../mirrors.md) could check against the manifest's hash.

## Portable, not the MSI

Upstream ships Gale for Windows only as an MSI ([Tauri](https://tauri.app) bundle, `ALLUSERS=1`) with a single file, `gale.exe`. Scoop unpacks it and does not run it, so there is no copy in Program Files, no Desktop shortcut and no entry in Settings > Apps. What the MSI would otherwise do:

- **`ror2mm://` and `gale://` links** ("Install with Mod Manager" on thunderstore.io): Gale registers them for the current user itself on every start, pointing to the copy that was started last. They work after the first start. r2modman registers `ror2mm://` too, so whichever of the two started last gets the links. `scoop uninstall` removes them only if they still point to this copy.
- **`.r2z` files:** run `reg import "%USERPROFILE%\scoop\apps\Gale\current\install-associations.reg"` (see [File associations](../conventions.md#file-associations)). `scoop uninstall` undoes it.
- **WebView2:** Gale needs the [Microsoft Edge WebView2 Runtime](https://developer.microsoft.com/microsoft-edge/webview2/). Windows 10 and 11 normally have it; the MSI would install it if missing.

## Updates

Update with `scoop update Gale`. Gale's own updater (the button in its toolbar) downloads and runs the upstream MSI, which installs a second copy for all users in Program Files. If that happens, `scoop update Gale` warns; uninstall the MSI copy in Settings > Apps.

## Copies installed without Scoop

A fresh install stops if Gale is already installed from upstream's MSI (an uninstall entry named `Gale` from `kesomannen`), so that two copies do not fight over the `ror2mm://` links. Uninstall that copy first in Settings > Apps; your profiles stay. There is no [override](../conventions.md#programs-installed-outside-scoop): Scoop cannot take over an MSI install.

The [Games](https://github.com/ScoopInstaller/Games) bucket's [`gale`](https://github.com/ScoopInstaller/Games/blob/master/bucket/gale.json) (1.24.0 as of November 2026) unpacks the MSI **and** runs it silently, so it leaves both a Scoop copy and an MSI copy in `C:\Program Files\Gale` with a Desktop shortcut. Because Scoop is case-insensitive, `games/gale` and `gesu/Gale` share the app folder: run `scoop uninstall gale` first (its uninstaller also removes the MSI copy, from an elevated shell), then `scoop install gesu/Gale`.

## Data

Settings and profiles live in `%APPDATA%\com.kesomannen.gale`, the download cache and WebView2 data in `%LOCALAPPDATA%\com.kesomannen.gale`. They are outside the app folder, so `persist` does not cover them and `scoop uninstall -p` does not delete them. Gale can move its data folder in its settings.

[All packages](../../README.md#packages)
