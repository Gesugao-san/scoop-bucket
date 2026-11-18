# EVEMon

| | |
|---|---|
| Manifest | [`bucket/EVEMon.json`](../../bucket/EVEMon.json) |
| Upstream | [mgoeppner/evemon](https://github.com/mgoeppner/evemon) |

Character monitor and skill planner for EVE Online, the maintained fork. Installed from the upstream MSI, unpacked without running it; self-contained, so no .NET runtime is needed. Settings and ESI logins stay in `%APPDATA%\EVEMon`, and EVEMon fetches game data updates itself. The version has two extra parts, the upload date and time (UTC) of the installer, e.g. `5.0.1.20261111.0905`: upstream's CI rebuilds `EVEMon-<version>.msi` on every push to `main` and replaces the asset of the existing release without changing the version (the `v5.0.1` release dates from August, its installer from 11 November). A plain version would leave the hash stale after each re-upload; `checkver` reads the version from `SharedAssemblyInfo.cs` on `main` and the upload time from the GitHub API, so Excavator picks up re-uploads too. EVEMon 5.0 is built on .NET 8, which reached end of support on 10 November 2026. Also in the [games](https://github.com/Calinou/scoop-games) bucket as `evemon`, stuck at 4.2.2: its `checkver` and URL expect the old `EVEMon-binaries-*.zip` assets, which 5.x no longer publishes.

[All packages](../../README.md#packages)
