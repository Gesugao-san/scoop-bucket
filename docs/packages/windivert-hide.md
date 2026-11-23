# WinDivert-hide

| | |
|---|---|
| Manifest | [`bucket/WinDivert-hide.json`](../../bucket/WinDivert-hide.json) |
| Upstream | [bol-van/zapret-win-bundle, `windivert-hide`](https://github.com/bol-van/zapret-win-bundle/tree/master/windivert-hide) (WinDivert: LGPL-3.0 or GPL-2.0) |
| Install | `scoop install -g gesu/WinDivert-hide   # global, from an elevated shell` |

[WinDivert](windivert.md) under another name, for games and anti-cheats that refuse to run while WinDivert is loaded: zapret-discord-youtube's FAQ sends people here. bol-van's build renames the driver service to `Monkey` and the driver file to `Monkey64.sys`. Per its `README.txt` (in the app folder), `Monkey64.sys` is an exact copy of `WinDivert64.sys` 2.2.2 (the same SHA-256 as WinDivert's release, so the author's signature is intact) and `WinDivert.dll` is rebuilt with small patches. It only helps against checks for the service name `WinDivert` or the file name `WinDivert64.sys`; a check for the driver's device or anything else still finds it.

Downloads `WinDivert.dll`, `Monkey64.sys` and `README.txt` from raw.githubusercontent.com at a fixed commit of zapret-win-bundle; `monkey_delete.cmd` is left out (it calls a helper from elsewhere in the bundle; `scoop uninstall` does its job). zapret-win-bundle has no releases and its history is one commit that bol-van replaces on every change, so the version is WinDivert's (2.2.2) plus the UTC time of that commit, which `checkver` reads from the GitHub API and the URLs are pinned to. A new bundle commit therefore always means a new version here, even when these three files did not change.

## How it is used

Installing it is the switch. While it is installed, [`Sync-ZapretComponents.ps1`](../../scripts/zapret/Sync-ZapretComponents.ps1) gives [`zapret`](zapret.md), [`zapret2`](zapret2.md) and [`zapret-discord-youtube`](zapret-discord-youtube.md) this `WinDivert.dll` and `Monkey64.sys` and deletes their `WinDivert64.sys`; after `scoop uninstall WinDivert-hide` it puts [WinDivert](windivert.md)'s files back. Both happen when this package is installed, updated or uninstalled, so stop the bypass first (`zapret-discord-youtube stop`), and start it again afterwards; a running `winws` keeps its files, with a warning, until `zapret-discord-youtube sync`. Flowseal's service manager checks only that some `.sys` file is in `bin`, so it is happy with `Monkey64.sys`.

The original `WinDivert` service must not be loaded at the same time: `zapret-discord-youtube stop` stops it (or `sc stop WinDivert` from an elevated console).

*Scoop Apps* gets a **WinDivert hide** shortcut: `WinDivert-hide.cmd`, written at install time, says what the package is for, shows `README.txt` and waits for a key.

## Conflicts

Global install only and x64 only, as [WinDivert](windivert.md#conflicts). On update and uninstall, a `Monkey` driver service registered from this package's own folder is stopped, and removed on uninstall. Not in any Scoop bucket known to this one.

[All packages](../../README.md#packages)
