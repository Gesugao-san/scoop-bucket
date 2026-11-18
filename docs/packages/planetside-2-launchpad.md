# PlanetSide-2-LaunchPad

| | |
|---|---|
| Manifest | [`bucket/PlanetSide-2-LaunchPad.json`](../../bucket/PlanetSide-2-LaunchPad.json) |
| Upstream | [planetside2.com](https://www.planetside2.com) (Daybreak Game Company) |
| Install | `scoop install gesu/PlanetSide-2-LaunchPad   # standalone, elevated shell` |

Daybreak's standalone LaunchPad, **not portable**: runs the official NSIS installer (`PS2_setup.exe`, with VC++ runtimes and the DirectX web setup) in its own wizard, where you can pick the game folder; LaunchPad then downloads and patches the game itself. Install, update and uninstall from an elevated shell. The download URL has no version, so the version is the file's `Last-Modified` date (`checkver` sends a HEAD request), and Excavator re-hashes the file when Daybreak replaces it. Stops if the game is installed in Steam (use `PlanetSide-2` then) or if a standalone copy was installed without Scoop (`GESU_ALLOW_EXISTING` override, see below).

[All packages](../../README.md#packages)
