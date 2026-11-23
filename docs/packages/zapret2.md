# zapret2

| | |
|---|---|
| Manifest | [`bucket/zapret2.json`](../../bucket/zapret2.json) |
| Upstream | [bol-van/zapret2](https://github.com/bol-van/zapret2) (MIT) |
| Install | `scoop install -g gesu/zapret2   # global, from an elevated shell` |

The next generation of [zapret](zapret.md) by the same author: the packet engine (`winws2.exe` on Windows, `nfqws2` elsewhere) runs strategies written in Lua instead of a fixed set of options, so new tricks need a script rather than a new release. The library comes with it in `lua\`: `zapret-lib.lua` (helpers, packet dissection), `zapret-antidpi.lua` (the classic desync methods), `zapret-auto.lua`, `zapret-obfs.lua`, `zapret-pcap.lua` and `zapret-tests.lua`. The manual is `docs\manual.en.md` (`manual.md` in Russian). [`zapret-discord-youtube`](zapret-discord-youtube.md) does not use zapret2.

Downloads `zapret2-v<version>.zip` from the GitHub release (SHA-256 checked against the digest GitHub shows and the SourceForge copy for 1.0.6) and keeps the x64 programs from `binaries\windows-x86_64` (`winws2.exe`, `mdig.exe`, `ip2net.exe`, `killall.exe`), `lua`, `files\fake` and `docs`; the rest of the release is for other systems.

```cmd
winws2 --wf-tcp=80,443 --lua-init=@%ProgramData%\scoop\apps\zapret2\current\lua\zapret-lib.lua --lua-init=@%ProgramData%\scoop\apps\zapret2\current\lua\zapret-antidpi.lua ...
```

## Components

As for zapret: `cygwin1.dll` comes from [`Cygwin-Runtime`](cygwin-runtime.md), `WinDivert.dll` and its driver from [`WinDivert`](windivert.md) (or [`WinDivert-hide`](windivert-hide.md)), copied next to `winws2.exe` by [`Sync-ZapretComponents.ps1`](../../scripts/zapret/Sync-ZapretComponents.ps1) on install and update and whenever those packages change, unless `winws2.exe` runs then. Note: zapret2's release ships a `WinDivert.dll` that differs from upstream's 2.2.2-A by two header bytes: bol-van's build sets the `DYNAMIC_BASE` (ASLR) flag and fixes the checksum ([`docs/changes.txt`](https://github.com/bol-van/zapret2/blob/HEAD/docs/changes.txt): *remove high_entropy_va patch for windivert.dll, but leave dynamic_base*). The code is the same; this package uses the WinDivert package's unpatched file, which loads at a fixed address instead.

## Commands

`winws2` only: `mdig` and `ip2net` are left to [`zapret`](zapret.md), whose commands have the same names (the programs are the same tools). *Scoop Apps* gets a **zapret2** shortcut with winws2's icon: `zapret2.cmd`, written at install time, shows how to load the Lua library, prints `winws2`'s options and waits for a key.

## Conflicts

Global install only, x64 only, nothing for ARM64, and no update or uninstall while `winws2.exe` from its folder runs, for the same reasons as [zapret](zapret.md#conflicts). zapret and zapret2 can be installed side by side, but should not run at the same time. Not in Scoop's main or extras bucket (November 2026). `checkver` follows the latest GitHub release.

## Mirrors

SourceForge copies every release automatically ([zapret2.mirror](https://sourceforge.net/projects/zapret2.mirror/), not run by bol-van); the 1.0.6 zip there is byte-identical to GitHub's. `.\bin\Use-Mirror.ps1 gesu/zapret2 sourceforge`.

[All packages](../../README.md#packages)
