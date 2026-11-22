# Horizon-Launcher

| | |
|---|---|
| Manifest | [`bucket/Horizon-Launcher.json`](../../bucket/Horizon-Launcher.json) |
| Upstream | [horizon-rust/horizon](https://github.com/horizon-rust/horizon) (Ludovic Marie and the Horizon Team, LGPL-3.0-or-later) |
| Install | `scoop install gesu/Horizon-Launcher` |

The launcher of Horizon, a rewrite of Minecraft: Java Edition 26.3 in Rust that aims at one-to-one vanilla behaviour. Upstream measures that with differential tests against the real game; its own caveat is that the score covers only what those tests compare. Horizon contains no Mojang code or assets: the launcher builds its files from your own copy of Minecraft 26.3, which must have been started once in the official launcher. It installs and updates game builds, runs singleplayer (vanilla world generation, mobs, redstone, commands) and a dedicated server. It cannot sign in to Microsoft accounts, so multiplayer works only on offline-mode servers; Java mods do not run, mods use Horizon's own WebAssembly system. A GPU with Vulkan is required.

Horizon was MIT-licensed before it moved to the LGPL; code merged before the move stays available under MIT ([README](https://github.com/horizon-rust/horizon#readme)). The repository moved from `ludovic111/horizon` to `horizon-rust/horizon`; GitHub redirects the old address.

Downloads the launcher zips from the GitHub release: `horizon-launcher-windows-x64.zip` and `horizon-launcher-windows-arm64.zip`, each with the single `horizon-launcher.exe` that upstream's per-user installer (`horizon-launcher-setup.exe`) copies, and that the launcher updates itself from. Launcher releases are tagged `launcher@<version>` and are never marked *latest* (game builds are), so `checkver` reads the release list instead of the latest release. Autoupdate takes the hashes from the release's `SHA256SUMS`. No mirror: upstream publishes only on GitHub.

## Environment variables

The manifest sets two user environment variables with `env_set`; `scoop uninstall` removes them. Explorer picks up new variables only after it is told or restarted: if the launcher still behaves as before right after the install, sign out and back in once.

- `HORIZON_LAUNCHER_NO_SELF_UPDATE=1`: the launcher does not replace its own exe ([`backend.rs`](https://github.com/horizon-rust/horizon/blob/HEAD/launcher/src/backend.rs)); update it with `scoop update Horizon-Launcher`. The game builds it installs in its data folder keep updating through the launcher, which is how Horizon ships them.
- `HORIZON_TELEMETRY_URL=off`: nothing is sent to `telemetry.playhorizon.dev` ([telemetry.md](https://github.com/horizon-rust/horizon/blob/HEAD/docs/telemetry.md)). Horizon's telemetry is opt-in, except for an anonymous "I'm playing" ping that the game sends once a minute to count players, which only this variable turns off. With it, bug reports cannot be sent from the launcher either; report bugs on GitHub. The *Show me as Horizon* setting of the cosmetics service (on by default for signed-in accounts, it tells other Horizon players that you play Horizon) is separate and not covered by the variable: turn it off in Extras > Cosmetics if you do not want it.

Both variables apply to every copy of Horizon run by your user, including one from upstream's installer.

## Data

The launcher keeps its data in `%APPDATA%\horizon-launcher` (game builds, prepared Minecraft files, settings, accounts) and the game its saves and `options.txt` in `%APPDATA%\horizon`; the launcher's settings can move them. They are outside the Scoop folder, so `persist` does not cover them, updates keep them, and `scoop uninstall -p` does not delete them. The game builds take several gigabytes.

## Copies installed without Scoop

A fresh install stops if the launcher is already installed with upstream's installer (uninstall entry `HorizonLauncher` under `HKCU`, files in `%LOCALAPPDATA%\Programs\Horizon Launcher`). Uninstall it in Settings > Apps first, without removing its data; or run `$env:GESU_ALLOW_EXISTING = '1'` and install again to keep both copies (see [Programs installed outside Scoop](../conventions.md#programs-installed-outside-scoop)): Scoop does not take that copy over, the two share the data folders. When the install stops, Scoop has already downloaded and unpacked the package: `scoop uninstall Horizon-Launcher`, or simply installing again, cleans that up.

[All packages](../../README.md#packages)
