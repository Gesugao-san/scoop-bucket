# Pumpkin

| | |
|---|---|
| Manifest | [`bucket/Pumpkin.json`](../../bucket/Pumpkin.json) |
| Upstream | [pumpkinmc.org](https://pumpkinmc.org/) ([Pumpkin-MC/Pumpkin](https://github.com/Pumpkin-MC/Pumpkin), GPL-3.0; plugin API MIT or Apache-2.0) |
| Install | `scoop install gesu/Pumpkin` |

A Minecraft server written from scratch in Rust, multithreaded (Tokio and Rayon) instead of one tick thread. It speaks the protocol of Java Edition 26.3 and of Bedrock clients, loads and saves vanilla worlds, and has RCON, query and a plugin API compiled to WebAssembly. Upstream calls it under heavy development: mobs, villagers and parts of redstone are incomplete, and Bukkit, Paper, Fabric or (Neo)Forge plugins and mods do not run.

Downloads the single exe from the GitHub release: `pumpkin-X64-Windows.exe` or `pumpkin-ARM64-Windows.exe`, renamed to `pumpkin.exe`. Upstream signs the Windows builds through [SignPath](https://signpath.org/projects/pumpkinmc). Releases are tagged `<version>+<Minecraft version>-<protocol date>` (`0.2.2+26.3-26.60`); the manifest keeps the version and rebuilds the tag from the `checkver` match. The `nightly` and `canary` prereleases are not tracked. Autoupdate takes the hashes from the release's `checksums.sha256`.

Upstream also builds `pumpkin-X64-v3-Windows.exe` for CPUs with AVX2 (x86-64-v3, Intel Haswell and AMD Excavator or newer). The manifest uses the plain x64 build, which runs on every 64-bit CPU.

Mirror: SourceForge's automatic copy of the releases, [pumpkin.mirror](https://sourceforge.net/projects/pumpkin.mirror/) (byte-identical for 0.2.2): `.\bin\Use-Mirror.ps1 gesu/Pumpkin sourceforge` (see [Installing from a mirror](../mirrors.md)).

## Starting and stopping

*Scoop Apps* gets a **Pumpkin (Minecraft server)** shortcut, and consoles get the `pumpkin` command. Both run `Pumpkin.cmd`, a micro-launcher written at install time: Pumpkin reads and writes its files in the current folder, so the micro-launcher changes to the persisted `server` folder first, from wherever it is started. The shortcut passes `/PAUSE`, which keeps the window open after the server stops; the command passes its arguments on to `pumpkin.exe` instead.

Stop the server with its `stop` console command. Stop it before `scoop update` or `scoop uninstall`: Scoop refuses to remove a running exe.

Windows Firewall asks for network access on the first start, and again after every update, because the exe moves to a new version folder. The server listens on port 25565 by default, like the other servers in this bucket: run one at a time or change the port in `pumpkin.toml`.

## Data

Everything Pumpkin writes (`pumpkin.toml`, the world, player data, plugins, logs) lands in `server`, which `persist` keeps in `%USERPROFILE%\scoop\persist\Pumpkin\server`. Updates keep it; only `scoop uninstall -p` deletes it. To use an existing vanilla world, copy it there as the world folder named in `pumpkin.toml`, after making a backup: the format is vanilla's, but the server is young.

## Telemetry

Pumpkin sends an anonymous heartbeat to `market.pumpkinmc.org` every 5 minutes by default ([`telemetry.rs`](https://github.com/Pumpkin-MC/Pumpkin/blob/HEAD/crates/pumpkin-config/src/telemetry.rs)); listing the server in the public community directory is a separate opt-in. On a fresh install, when `server\pumpkin.toml` does not exist yet, `post_install` writes it with just

```toml
[telemetry]
enabled = false
```

Pumpkin merges a partial `pumpkin.toml` with its defaults on start and writes the missing settings back ([`LoadConfiguration`](https://github.com/Pumpkin-MC/Pumpkin/blob/HEAD/crates/pumpkin-config/src/lib.rs)). An existing file is never touched, so updates keep your choice. Set `enabled = true` to send the heartbeat.

## Conflicts

No other bucket in Scoop's official set has Pumpkin (checked in [Main](https://github.com/ScoopInstaller/Main), [Extras](https://github.com/ScoopInstaller/Extras), [Games](https://github.com/ScoopInstaller/Games), [Java](https://github.com/ScoopInstaller/Java), [Nonportable](https://github.com/ScoopInstaller/Nonportable) and [Versions](https://github.com/ScoopInstaller/Versions), November 2026). Upstream has no installer, so there is no check for copies installed without Scoop.

[All packages](../../README.md#packages)
