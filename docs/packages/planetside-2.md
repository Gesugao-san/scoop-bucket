# PlanetSide-2

| | |
|---|---|
| Manifest | [`bucket/PlanetSide-2.json`](../../bucket/PlanetSide-2.json) |
| Upstream | [Steam app 218230](https://store.steampowered.com/app/218230/PlanetSide_2/) |
| Install | `scoop install gesu/PlanetSide-2             # through Steam` |

Installs and removes the game **through Steam** (`steam://install/218230`, `steam://uninstall/218230`); Steam downloads and updates it, so the version is just `steam` and there is no `checkver`. Needs Steam installed and signed in. If the game is already installed in Steam, Scoop only starts tracking it. Adds the `PlanetSide-2` command ([`scripts/planetside-2/PlanetSide-2.cmd`](../../scripts/planetside-2/PlanetSide-2.cmd), downloaded from a pinned commit) that starts the game through Steam, and a *PlanetSide 2* shortcut in Scoop Apps that runs it. Stops if the standalone copy is installed.

[All packages](../../README.md#packages)
