# SteelMC

| | |
|---|---|
| Manifest | [`bucket/SteelMC.json`](../../bucket/SteelMC.json) |
| Upstream | [steelmc.dev](https://steelmc.dev/) ([Steel-Foundation/SteelMC](https://github.com/Steel-Foundation/SteelMC), AGPL-3.0-or-later) |
| Install | `scoop install gesu/SteelMC` |

Steel, a Minecraft: Java Edition server written in Rust that tracks the latest Java release (26.3 as of November 2026). It aims at vanilla behaviour and uses lock-free data structures to spread the work over all cores. Upstream calls it pre-alpha: survival mechanics and mobs are incomplete, there is no plugin system, and Bukkit, Paper, Fabric or (Neo)Forge plugins and mods do not run. [Pomme](pomme.md) embeds the same server for its singleplayer worlds.

Downloads `steel-windows.exe` from the GitHub release, renamed to `steel.exe`. Upstream ships no Windows ARM64 build and publishes no checksums, so autoupdate downloads the file to compute the hash. Releases are tagged `v<version>+mc<Minecraft version>` (`v0.17.1+mc26.3`); the manifest keeps the version and rebuilds the tag from the `checkver` match.

Mirror: SourceForge's automatic copy of the releases, [steelmc.mirror](https://sourceforge.net/projects/steelmc.mirror/): `.\bin\Use-Mirror.ps1 gesu/SteelMC sourceforge` (see [Installing from a mirror](../mirrors.md)). It was byte-identical for 0.17.0 but lags behind GitHub: 0.17.1 was not there yet when the package was added, and `Use-Mirror.ps1` then fails to download.

## Starting and stopping

*Scoop Apps* gets a **SteelMC (Minecraft server)** shortcut, and consoles get the `steel` command. Both run `SteelMC.cmd`, a micro-launcher written at install time: Steel reads and writes its files in the current folder, so the micro-launcher changes to the persisted `server` folder first. The shortcut passes `/PAUSE`, which keeps the window open after the server stops; the command passes its arguments on to `steel.exe` instead.

Stop the server with its `stop` console command, before `scoop update` or `scoop uninstall`: Scoop refuses to remove a running exe.

Windows Firewall asks for network access on the first start, and again after every update, because the exe moves to a new version folder. The server listens on port 25565 by default, like the other servers in this bucket: run one at a time or change the port in `config\config.toml`.

## Data

Everything Steel writes (`config\config.toml`, `config\worlds.toml`, the worlds, logs) lands in `server`, which `persist` keeps in `%USERPROFILE%\scoop\persist\SteelMC\server`. Updates keep it; only `scoop uninstall -p` deletes it. Older docs name the config `steel_config.json5`; 0.17 uses TOML.

## Conflicts

No official Scoop bucket has SteelMC (November 2026). Upstream has no installer, so there is no check for copies installed without Scoop.

[All packages](../../README.md#packages)
