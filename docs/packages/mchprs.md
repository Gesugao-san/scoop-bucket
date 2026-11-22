# MCHPRS

| | |
|---|---|
| Manifest | [`bucket/MCHPRS.json`](../../bucket/MCHPRS.json) |
| Upstream | [MCHPR/MCHPRS](https://github.com/MCHPR/MCHPRS) (MIT) |
| Install | `scoop install gesu/MCHPRS` |

Minecraft High-Performance Redstone Server: a Minecraft 1.20.4 creative server in Rust, made for computational redstone (CPUs, logic circuits). The world is split into plots, each on its own thread, and Redpiler, its redstone compiler, runs builds far faster than vanilla ticks allow. Many things a vanilla server does (survival, mobs, world generation) are deliberately missing. Clients must be Minecraft 1.20.4.

Downloads the official zips from the GitHub release: `mchprs-x86_64-pc-windows-msvc.zip` and `mchprs-aarch64-pc-windows-msvc.zip`, each with `mchprs.exe`. Upstream publishes no checksums, so autoupdate downloads the files to compute the hashes. The rolling `preview` prerelease is not tracked.

Mirror: SourceForge's automatic copy of the releases, [minecraft-high-perform.mirror](https://sourceforge.net/projects/minecraft-high-perform.mirror/): `.\bin\Use-Mirror.ps1 gesu/MCHPRS sourceforge` (see [Installing from a mirror](../mirrors.md)). It was byte-identical for 0.5.2 but lags behind GitHub: 0.5.3 was not there yet when the package was added, and `Use-Mirror.ps1` then fails to download.

## Starting and stopping

*Scoop Apps* gets a **MCHPRS (Minecraft server)** shortcut, and consoles get the `mchprs` command. Both run `MCHPRS.cmd`, a micro-launcher written at install time: MCHPRS reads and writes its files in the current folder, so the micro-launcher changes to the persisted `server` folder first. The shortcut passes `/PAUSE`, which keeps the window open after the server stops; the command passes its arguments on to `mchprs.exe` instead.

Stop the server with Ctrl+C (it saves the plots first) or with `/stop` in game, before `scoop update` or `scoop uninstall`: Scoop refuses to remove a running exe. After Ctrl+C, cmd may ask *Terminate batch job (Y/N)?*; either answer is fine, the server has already stopped.

Windows Firewall asks for network access on the first start, and again after every update, because the exe moves to a new version folder. The server listens on port 25565 by default, like the other servers in this bucket: run one at a time or change `bind_address` in `Config.toml`.

## Data

Everything MCHPRS writes (`Config.toml`, `whitelist.json`, the world with its plots and schematics, logs) lands in `server`, which `persist` keeps in `%USERPROFILE%\scoop\persist\MCHPRS\server`. Updates keep it; only `scoop uninstall -p` deletes it.

## Conflicts

No official Scoop bucket has MCHPRS (November 2026). Upstream has no installer, so there is no check for copies installed without Scoop.

[All packages](../../README.md#packages)
