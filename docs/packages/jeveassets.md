# jEveAssets

| | |
|---|---|
| Manifest | [`bucket/jEveAssets.json`](../../bucket/jEveAssets.json) |
| Upstream | [GoldenGnu/jeveassets](https://github.com/GoldenGnu/jeveassets) |

Asset, wealth, market order and transaction manager for EVE Online. Needs Java 8 or newer with `javaw` on the PATH: the manifest [suggests](https://github.com/ScoopInstaller/Scoop/wiki/App-Manifests#optional-properties) `java/temurin-jre`. Runs in jEveAssets' own package manager mode (`packagemanager.properties`), so its built-in updater, which downloads and runs `jupdate.jar` from eve.nikr.net, stays off; use `scoop update jEveAssets`. Upstream also publishes static data (items, locations) between releases; with the updater off, that data arrives with the next release. Accounts and history stay in `%USERPROFILE%\.jeveassets`. The shortcut starts `jmemory.jar` through `javaw` (a small `jEveAssets.cmd` written at install time); its heap size lives in the persisted `jmemory.properties`. The shortcut icon is built at install time from the PNGs inside the jar ([`scripts/common/New-IconFromArchive.ps1`](../../scripts/common/New-IconFromArchive.ps1)). Install, update and uninstall stop while jEveAssets runs: it is detected by its single-instance port 127.0.0.1:2222, because it runs in `javaw.exe` from the Java folder, which Scoop's own check does not see. Also in the [games](https://github.com/Calinou/scoop-games) bucket as `jeveassets`, stuck at 8.1.2, most likely because its `checkver` regex `tag/(...)` cannot match the bare tag name (`jeveassets-8.2.2`) that Scoop reads from the GitHub API when it has a token, as Excavator does; and it persists `data`, which is upstream's static data, not the user's.

[All packages](../../README.md#packages)
