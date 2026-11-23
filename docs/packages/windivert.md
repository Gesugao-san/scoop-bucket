# WinDivert

| | |
|---|---|
| Manifest | [`bucket/WinDivert.json`](../../bucket/WinDivert.json) |
| Upstream | [reqrypt.org/windivert](https://reqrypt.org/windivert.html) ([basil00/WinDivert](https://github.com/basil00/WinDivert), LGPL-3.0 or GPL-2.0) |
| Install | `scoop install -g gesu/WinDivert   # driver, global, from an elevated shell` |

Windows Packet Divert: a signed kernel driver (`WinDivert64.sys`) and a user-mode library (`WinDivert.dll`) that let a program capture network packets, filter them with a small expression language, change, drop or re-inject them. It is the Windows counterpart of Linux's NFQUEUE, and what [`zapret`](zapret.md), [`zapret2`](zapret2.md), [`zapret-discord-youtube`](zapret-discord-youtube.md) and GoodbyeDPI run on.

Downloads `WinDivert-2.2.2-A.zip` from the GitHub release (2.2.2-A from September 2022 is still the newest) and keeps the files of the system's architecture in the app folder: `x64` on 64-bit Windows, `x86` (with `WinDivert32.sys`, and `WinDivert64.sys` for 32-bit programs on 64-bit Windows) on 32-bit Windows. The archive's SHA-256 was computed here; GitHub shows no digest for this older asset. The `WinDivert.dll` and `WinDivert64.sys` in it are byte-identical to the ones in zapret 72.13 and zapret-discord-youtube 1.10.4. `checkver` reads the asset name from the latest release (the `-A` suffix is part of the version).

## How programs use it

There is nothing to install beyond the files: the first program that opens WinDivert (with administrator rights) silently installs the driver as the service `WinDivert` from the folder of *its* `WinDivert.dll`. Per upstream's documentation the driver then stays loaded until the next reboot, or until `windivertctl uninstall` (or `sc stop WinDivert`) once no program has it open. So each program uses the copy next to it, and the zapret packages get theirs from this package: [`Sync-ZapretComponents.ps1`](../../scripts/zapret/Sync-ZapretComponents.ps1) copies `WinDivert.dll` and `WinDivert64.sys` to every installed zapret package when this package is installed or updated (except while that package's `winws` runs; see [zapret-discord-youtube](zapret-discord-youtube.md#components-as-packages)).

## Commands

`windivertctl` (from an elevated console): `list [filter]` shows the programs that have WinDivert open and their filters, `watch` does so live, `kill` ends them, `uninstall` unloads the driver once nothing uses it. Upstream's samples stay in the app folder without commands: `netdump`, `netfilter`, `passthru`, `socketdump`, `streamdump`, `flowtrack`, `webfilter`, `test`; the API reference is `doc\WinDivert.html`. *Scoop Apps* gets a **WinDivert** shortcut: `WinDivert.cmd`, written at install time, lists all this and waits for a key.

## Conflicts

Global install only (`scoop install -g`): a kernel driver loaded from a folder that a non-admin user can write to would let that user replace it. On ARM64 Windows the install stops: there is no ARM64 driver, and the x64 one cannot load there (zapret-win-bundle's ARM64 route needs test signing). On update and uninstall, a `WinDivert` or `WinDivert14` driver service registered from this package's own folder (by `windivertctl` or a sample) is stopped, and removed on uninstall; services of other programs are left alone.

Antivirus programs often flag WinDivert as a risk tool (`Not-a-virus:RiskTool.Multi.WinDivert` and similar) because malware can use it too. The driver is signed by its author and the files are upstream's; add an exclusion if yours quarantines them. Some games' anti-cheats refuse to start while WinDivert is loaded: [`WinDivert-hide`](windivert-hide.md).

Not in Scoop's main or extras bucket (November 2026).

## Mirrors

Upstream's README points to [reqrypt.org/download](https://reqrypt.org/download) for the originals, which [`mirrors.psd1`](../../mirrors.psd1) lists (`.\bin\Use-Mirror.ps1 gesu/WinDivert reqrypt.org`). That site could not be reached from where this package was written, so it was not compared byte for byte; Scoop checks the hash either way.

[All packages](../../README.md#packages)
