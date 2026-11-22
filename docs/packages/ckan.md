# CKAN

| | |
|---|---|
| Manifest | [`bucket/CKAN.json`](../../bucket/CKAN.json) |
| Upstream | [KSP-CKAN/CKAN](https://github.com/KSP-CKAN/CKAN) (MIT) |
| Install | `scoop install gesu/CKAN                     # KSP mod manager, .NET 10 build` |

The Comprehensive Kerbal Archive Network: the community mod manager for Kerbal Space Program (and KSP 2). It knows which mods fit the game version, installs them with their dependencies, warns about conflicts, updates and removes them. It has a GUI, a console UI (`ckan consoleui`) and a command line (`ckan install`, `ckan upgrade --all`, `ckan help`). Mods themselves come from SpaceDock, GitHub and other hosts that CKAN's metadata points to; CKAN itself only reads that metadata.

This package is `ckan-windows.exe`, the build upstream recommends for Windows since 1.36.4: self-contained .NET 10, x64, about 130 MB, so it needs no framework, and it follows the Windows dark theme. [`CKAN-NetFx`](ckan-netfx.md) is the small `ckan.exe` for .NET Framework 4.8.1. Both run the same code and use the same data, but add the same command `ckan`, so only one of the two can be installed: each manifest's `pre_install` stops if the other one, or `ksp-ckan` from another bucket, is installed (Scoop runs it after the download).

The file keeps its upstream name, `ckan-windows.exe`; the command is `ckan` and the shortcut in Scoop Apps is *CKAN*. The name matters: the .NET 10 build's self-updater downloads the release asset whose name matches the running file, so renamed to `ckan.exe` it would replace itself with the .NET Framework build. Started without arguments (or from the shortcut), CKAN opens its GUI and closes its console window; a console window flashes briefly.

Releases are signed through [SignPath](https://signpath.org/projects/ksp-ckan) (SignPath Foundation, GlobalSign certificate). Upstream publishes no hashes, so autoupdate computes them from the download. `checkver` follows GitHub releases. `ckan-windows.exe` first appeared in 1.36.4 (1.36.2 had only `ckan.exe`); if upstream renames it again, autoupdate fails and the manifest needs a fix. No mirror: upstream's S3 bucket (`ksp-ckan.s3-us-west-2.amazonaws.com`) holds only development builds, and no copy on SourceForge was found.

## Updates

Update with `scoop update CKAN`. On its first start in each game instance CKAN asks whether to check for its own updates on launch: answer *No*. Its updater (also `ckan upgrade ckan` on the command line) downloads the new exe and `AutoUpdater.exe` and overwrites the file in the app folder, so Scoop's version and the real one drift apart until the next `scoop update CKAN`.

## ckan:// links

Links such as `ckan://ModName` open CKAN and select that mod. On its first start CKAN offers to register them: it writes `HKEY_CLASSES_ROOT\ckan`, which Windows stores in `HKLM\Software\Classes` (for all users), so it asks for admin rights (UAC) once. It registers the path it was started from, unquoted. If you decline, it does not ask again for that game instance. After `scoop update CKAN` it cannot update the path without admin rights; if the links stop working, run `ckan gui --asroot registerUrl` from an elevated shell.

`scoop uninstall CKAN` deletes the `ckan` key under `HKCU\Software\Classes` and `HKLM\Software\Classes` if its command points into this package's folder. Deleting the `HKLM` key needs an elevated shell; otherwise the uninstall warns and prints the `reg delete` command.

## Data

| What | Where |
|---|---|
| Settings, the list of game instances, repositories, labels | `%LOCALAPPDATA%\CKAN` (`config.json` and others) |
| Download cache | `%LOCALAPPDATA%\CKAN\downloads` by default; it can grow to gigabytes. The folder and a size limit are in CKAN's settings |
| Installed mods and GUI settings of a game | the `CKAN` folder inside that game's folder (`registry.json`, `GUIConfig.json`, ...) |

None of it is in the app folder, so `persist` does not cover it and `scoop uninstall -p` deletes nothing. `CKAN_CONFIG_FILE` points CKAN to another `config.json`.

CKAN changes the game folder. Upstream's advice holds: mod a copy of the game outside `steamapps`, so that Steam's *Verify integrity of game files* cannot break the mod set; close KSP before changing mods, because Windows locks the DLLs of loaded mods.

## Other buckets

The [DEV-tools](https://github.com/anderlli0053/DEV-tools) bucket has two CKAN manifests, both for `ckan.exe`, not `ckan-windows.exe` (checked November 2026):

- [`ckan`](https://github.com/anderlli0053/DEV-tools/blob/master/bucket/ckan.json) (1.36.4, copied from okibcn/ScoopMaster) downloads through `ghproxy.com`, a third-party GitHub proxy, and its hash (`94176d68…`) does not match upstream's `ckan.exe` for 1.36.4 (`7748082c…`), so its install fails or installs something other than upstream's file. Its license field (`Software`) is not an SPDX identifier. Because Scoop is case-insensitive, it shares the app folder with this `CKAN`: run `scoop uninstall ckan` first.
- [`ksp-ckan`](https://github.com/anderlli0053/DEV-tools/blob/master/bucket/ksp-ckan.json) was at 1.36.2 and also adds the command `ckan`, so installing this package (or `CKAN-NetFx`) while it is installed stops, as with the other of the two: run `scoop uninstall ksp-ckan` first.

Neither is in Scoop's official buckets.

[All packages](../../README.md#packages)
