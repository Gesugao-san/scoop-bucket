# Freesm-Launcher

| | |
|---|---|
| Manifest | [`bucket/Freesm-Launcher.json`](../../bucket/Freesm-Launcher.json) |
| Upstream | [FreesmTeam/FreesmLauncher](https://github.com/FreesmTeam/FreesmLauncher) |
| Install | `scoop install gesu/Freesm-Launcher` |

Prism Launcher fork. Portable build (MSVC, x64 and arm64), modelled on the [games](https://github.com/Calinou/scoop-games) bucket's `prismlauncher`: data folders are persisted, and `accounts.json`, `metacache` and `freesmlauncher.cfg` are copied in and out because the launcher replaces them instead of writing into them. Data from an installed copy in `%APPDATA%\FreesmLauncher` is copied on the first install. The built-in updater is removed; use `scoop update`. Suggests `extras/vcredist2022`.

[All packages](../../README.md#packages)
