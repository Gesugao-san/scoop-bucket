# zapret

| | |
|---|---|
| Manifest | [`bucket/zapret.json`](../../bucket/zapret.json) |
| Upstream | [bol-van/zapret](https://github.com/bol-van/zapret) (MIT) |
| Install | `scoop install -g gesu/zapret   # global, from an elevated shell` |

bol-van's DPI circumvention tool. On Windows it is `winws.exe`, the Windows build of `nfqws`: through [WinDivert](windivert.md) it catches the first packets of TLS, QUIC, HTTP and other connections and splits, reorders or precedes them with fake packets, so that the provider's DPI cannot read the site name, while the site itself gets the real request. Which tricks work depends on the provider; [`zapret-discord-youtube`](zapret-discord-youtube.md) is a set of ready-made strategies for it, and bol-van's [`docs\readme.md`](https://github.com/bol-van/zapret/blob/HEAD/docs/readme.md) (Russian; `readme.en.md` in English) describes every option.

Downloads `zapret-v<version>.zip` from the GitHub release (SHA-256 checked against the digest GitHub shows and the SourceForge copy for 72.13) and keeps only what Windows uses: the x64 programs from `binaries\windows-x86_64` (`winws.exe`, `mdig.exe`, `ip2net.exe`, `killall.exe`), the fake packets in `files\fake` and the documentation in `docs`. The scripts and binaries for Linux, BSD, macOS, Android and OpenWrt are deleted. `blockcheck`, which finds working options automatically, needs a full Cygwin on Windows and is part of [zapret-win-bundle](https://github.com/bol-van/zapret-win-bundle), not of this package.

## Components

`winws.exe` loads `cygwin1.dll` and `WinDivert.dll` from its own folder, and WinDivert loads its driver from the same folder. The release ships copies of them; here they come from [`Cygwin-Runtime`](cygwin-runtime.md) and [`WinDivert`](windivert.md) (or [`WinDivert-hide`](windivert-hide.md) when installed), both dependencies. [`Sync-ZapretComponents.ps1`](../../scripts/zapret/Sync-ZapretComponents.ps1) copies them next to `winws.exe` on install and update, and whenever one of those packages is installed or updated, unless `winws.exe` runs at that moment (then it warns; `scoop update -f -g zapret` copies them later). The release's own copies (WinDivert 2.2.2-A, byte-identical to WinDivert's release, and Cygwin 3.4.10) are overwritten. On update, zapret also passes its new `winws.exe` on to `zapret-discord-youtube`.

## Commands

- `winws <options>`: runs the bypass in the console until Ctrl+C; needs an elevated console. `winws` without options prints them all.
- `mdig`: resolves many domains at once over plain DNS, for building IP lists; `ip2net`: merges IP addresses into subnets.

*Scoop Apps* gets a **zapret** shortcut with winws's icon. It opens `zapret.cmd`, a micro-launcher written at install time that says what `winws.exe` is and where the docs and fake packets are, prints `winws`'s options and waits for a key. There is no service and no list of strategies here; `zapret-discord-youtube` has both. bol-van's own service scripts (`service_create.cmd` and the rest) are in zapret-win-bundle.

## Conflicts

Global install only (`scoop install -g`, from an elevated shell): `winws.exe` runs with administrator rights and loads a kernel driver, so its files must not be writable by a non-admin user, which `%USERPROFILE%\scoop` would allow. x64 only: this package takes cygwin1.dll from Cygwin-Runtime, and Cygwin no longer builds for 32-bit Windows; on ARM64 Windows the install stops, the WinDivert driver has no ARM64 build. Scoop refuses to update or uninstall zapret while `winws.exe` from its folder runs. On uninstall, a `WinDivert`, `WinDivert14` or `Monkey` driver service registered from this package's folder is stopped and removed. Not in Scoop's main or extras bucket (November 2026).

`checkver` follows the latest GitHub release. Upstream builds the binaries in GitHub Actions; `sha256sum.txt` in each release lists the hashes of every file in the archive.

## Mirrors

SourceForge copies every release automatically ([zapret.mirror](https://sourceforge.net/projects/zapret.mirror/), not run by bol-van); the 72.13 zip there is byte-identical to GitHub's. `.\bin\Use-Mirror.ps1 gesu/zapret sourceforge`, then `scoop install -g gesu/zapret`.

[All packages](../../README.md#packages)
