# zapret-discord-youtube

| | |
|---|---|
| Manifest | [`bucket/zapret-discord-youtube.json`](../../bucket/zapret-discord-youtube.json) |
| Upstream | [Flowseal/zapret-discord-youtube](https://github.com/Flowseal/zapret-discord-youtube) (MIT) |
| Install | `scoop install -g gesu/zapret-discord-youtube   # global, from an elevated shell` |

Flowseal's ready-made setup of [zapret](zapret.md) for Windows: about twenty strategies (`general.bat`, `general (ALT).bat` ... `general (FAKE TLS AUTO).bat`) that start `winws.exe` with tuned options for Discord (including voice), YouTube, Google and the sites in its lists; domain and IP lists (`lists\`); fake packets (`bin\*.bin`); and `service.bat`, a menu that installs a strategy as the Windows service `zapret`, removes it, checks the status, switches the Game Filter and IPSet Filter, updates the IP list and the `hosts` entries for Telegram's web version, runs diagnostics (Adguard, Killer, Intel Connectivity, Check Point, SmartByte, VPNs, secure DNS, conflicting bypasses) and tests every strategy against a list of sites. Flowseal's README (Russian) explains each of them.

Downloads `zapret-discord-youtube-<version>.zip` from the GitHub release; its SHA-256 matches the digest GitHub shows and the SourceForge copy (checked for 1.10.4). Flowseal also publishes `.rar` and `.tar.gz` with the same content. Flowseal says he runs no other pages, groups or channels; the release on GitHub is the source.

## Components as packages

The release's `bin` folder carries files from other projects, as upstream's README says: `winws.exe` and `cygwin1.dll` from [bol-van/zapret](https://github.com/bol-van/zapret), and `WinDivert.dll` with `WinDivert64.sys` from [WinDivert](windivert.md). Here each of them is a package of its own, installed as a dependency and updated by Scoop:

| File in `bin` | Package | In Flowseal's 1.10.4 |
|---|---|---|
| `winws.exe` | [`zapret`](zapret.md) (72.13) | 72.9 |
| `cygwin1.dll` | [`Cygwin-Runtime`](cygwin-runtime.md) (3.6.12) | 3.4.10, as in zapret's releases |
| `WinDivert.dll`, `WinDivert64.sys` | [`WinDivert`](windivert.md) (2.2.2-A) | 2.2.2-A, byte-identical |
| `WinDivert.dll`, `Monkey64.sys` | [`WinDivert-hide`](windivert-hide.md), when installed | none |

[`scripts/zapret/Sync-ZapretComponents.ps1`](../../scripts/zapret/Sync-ZapretComponents.ps1) copies them into `bin`: on install and update of this package (it stops the install if a component is missing), and from the `post_install` of each component package, so `scoop update WinDivert` (or zapret, Cygwin-Runtime) reaches `bin` too. Copies rather than links: the running service then keeps only this package's files open, and the components update freely. While `winws.exe` runs, the files in `bin` are in use and a component update cannot replace them; it warns, and `zapret-discord-youtube sync` (or `zapret-discord-youtube update`) finishes the job later.

Flowseal tests the strategies with the `winws.exe` he ships, which is older than zapret's newest. If a strategy that worked stops working after a zapret update, switch to his pair: `zapret-discord-youtube bundled on` puts the `winws.exe` and `cygwin1.dll` from the release (kept in `bundled\`) back into `bin`, restarting the service if it ran; `bundled off` returns to the packages. The choice is a file in the persisted `settings` folder, so it survives updates. The bundled `cygwin1.dll` 3.4.10 is also the one for Windows 7 and 8, which Cygwin 3.5 and later no longer support.

## Using it

Turn on secure DNS first (DNS over HTTPS in the browser, or in Windows 11's network settings), as upstream's README asks; without it, many strategies cannot help.

*Scoop Apps* gets a **zapret-discord-youtube** shortcut (with winws's padlock icon). It opens [`zapret-discord-youtube.cmd`](../../scripts/zapret-discord-youtube/zapret-discord-youtube.cmd), which runs [`ZapretDiscordYoutube.ps1`](../../scripts/zapret-discord-youtube/ZapretDiscordYoutube.ps1): it asks for administrator rights (UAC), copies the components into `bin`, and opens `service.bat` in that administrator window.

1. **12. Run Tests** → *Standard tests* → *All configs* tries every strategy against the sites in `utils\targets.txt` and saves the results in `utils\test results`.
2. **1. Install Service** → pick the strategy that worked. The service `zapret` starts now and with Windows. Its command line points at `...\apps\zapret-discord-youtube\current\bin\winws.exe`, so it keeps working across updates.

A strategy can also run by hand: right-click a `general*.bat` in the app folder (`zapret-discord-youtube folder` opens it) → *Run as administrator*; `winws.exe` then runs minimized until you close it. Not while the service runs: two bypasses fight over the same traffic.

The same script is the command `zapret-discord-youtube`:

| Command | Does |
|---|---|
| `zapret-discord-youtube` | the service manager, as the shortcut |
| `zapret-discord-youtube status` | versions of the package and its components, the service with its strategy, running `winws.exe` (no admin rights needed) |
| `zapret-discord-youtube stop` / `start` | stops the `zapret` service and every `winws.exe` started from this package / starts the service |
| `zapret-discord-youtube update` | stop, `scoop update -g` of this package and its installed components, start again if the service was running |
| `zapret-discord-youtube sync` | copies the components into `bin` again |
| `zapret-discord-youtube bundled on\|off` | Flowseal's `winws.exe` + `cygwin1.dll`, or the packages' (see above) |
| `zapret-discord-youtube folder` | opens the app folder in Explorer |

Everything except `status`, `folder` and `help` asks for administrator rights and runs in a new window that stays open until you press Enter.

## Updates

Scoop refuses to update or uninstall an app while a program runs from its folder, and the `zapret` service is such a program. So `scoop update -g zapret-discord-youtube` stops with *"The following instances of zapret-discord-youtube are still running"* until the bypass is stopped, before any hook of the manifest could stop it. `zapret-discord-youtube update` does the three steps in order. By hand: `zapret-discord-youtube stop`, `scoop update -g zapret-discord-youtube`, `zapret-discord-youtube start`.

The service manager's own update check (*Auto-Update Check*, on by default upstream) is turned off at install: it would open the release page to download a zip, which does not fit a Scoop install. *10. Check for Updates* still works if you want to look. `checkver` follows Flowseal's latest release.

## Data

`persist` keeps in `%ProgramData%\scoop\persist\zapret-discord-youtube`:

| Path | Holds |
|---|---|
| `lists\list-general-user.txt`, `lists\list-exclude-user.txt`, `lists\ipset-exclude-user.txt` | your own domains and IPs, added to Flowseal's lists by every strategy |
| `utils\game_filter.enabled` | the Game Filter setting (mode and port ranges) |
| `utils\test results` | results of *Run Tests* |
| `settings` | `use-bundled` when `bundled on` |

The install creates the three user lists and `game_filter.enabled` with the service manager's own defaults (Game Filter off) when they are not in the persist folder yet: Scoop would make folders of missing files, and `service.bat` then fails to read or write them. Persisted files are hard links: edit the lists with an editor that saves in place, such as Notepad; an editor that writes a new file and renames it over the old one breaks the link, and the change is lost on the next update.

Not kept, because they change files that come with every release: the IPSet Filter mode and the list it switches (`lists\ipset-all.txt`, *8. Update IPSet List*), and *7. Replace active fakes* (`bin\ACTIVE_*.bin`). Set them again after an update. The `hosts` entries from *9. Update Hosts File* are in Windows' own `hosts` file and stay.

## Conflicts and removal

Global install only (`scoop install -g`, from an elevated shell): the service runs `winws.exe` as SYSTEM and loads a kernel driver, so its files must be writable only by administrators, which `%ProgramData%\scoop` is and `%USERPROFILE%\scoop` is not. For the same reason the components are copied only from the global Scoop folder. x64 only: Flowseal ships no other build, and the WinDivert driver has no ARM64 build (ARM64 Windows would need test signing), so the install stops on ARM64 Windows.

A fresh install stops when a `zapret` service from another copy is installed (Flowseal's zip unpacked elsewhere): two copies would fight over the traffic, and a later `scoop uninstall` must not remove a service it did not make. Remove it with that copy's `service.bat` (*2. Remove Services*), or set `$env:GESU_ALLOW_EXISTING = '1'` in the same shell and install again; this copy's *Install Service* then replaces the other one's service (see [Programs installed outside Scoop](../conventions.md#programs-installed-outside-scoop)). Other bypasses that use WinDivert (GoodbyeDPI, other zapret builds) are not checked at install; *11. Run Diagnostics* finds and offers to remove them. A stopped install leaves the downloaded version behind; install again or run `scoop uninstall zapret-discord-youtube` to clean it up.

`scoop uninstall -g zapret-discord-youtube` first runs `zapret-discord-youtube cleanup`: it stops and deletes the `zapret` service and the `WinDivert`, `WinDivert14` and `Monkey` driver services, but only those that point into this package's folder (Scoop runs `pre_uninstall` before its own check for running programs, so this works while the service runs). Flowseal's `hosts` entries and the TCP timestamps setting the strategies turn on stay. The component packages stay installed; remove them with `scoop uninstall -g zapret WinDivert Cygwin-Runtime`.

Antivirus programs often flag WinDivert as `RiskTool` or `HackTool`; upstream explains why ([zapret-win-bundle](https://github.com/bol-van/zapret-win-bundle#антивирусы)). The files are upstream's own, signed driver included. Add an exclusion for `%ProgramData%\scoop\apps\zapret-discord-youtube` and `%ProgramData%\scoop\apps\WinDivert`, or turn off detection of potentially unwanted applications. Games whose anti-cheat refuses to run next to WinDivert: [`WinDivert-hide`](windivert-hide.md).

Not in Scoop's main or extras bucket (November 2026); other buckets could not be searched on [scoop.sh](https://scoop.sh/) from where this package was written.

## Mirrors

SourceForge copies every release automatically ([zapret-discord-youtube.mirror](https://sourceforge.net/projects/zapret-discord-youtube.mirror/), not run by Flowseal); the 1.10.4 zip there is byte-identical to GitHub's. [`mirrors.psd1`](../../mirrors.psd1) lists it: `.\bin\Use-Mirror.ps1 gesu/zapret-discord-youtube sourceforge`, then `scoop install -g gesu/zapret-discord-youtube`.

[All packages](../../README.md#packages)
