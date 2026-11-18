# DriverStore-Explorer

| | |
|---|---|
| Manifest | [`bucket/DriverStore-Explorer.json`](../../bucket/DriverStore-Explorer.json) |
| Upstream | [lostindark/DriverStoreExplorer](https://github.com/lostindark/DriverStoreExplorer) |
| Install | `scoop install gesu/DriverStore-Explorer     # runs elevated (UAC prompt)` |

Driver Store Explorer [RAPR]: lists, adds, installs and deletes third-party driver packages in the Windows driver store, also in offline images, and finds old unused ones. The command is `rapr`. Asks for admin rights (UAC) on every start; needs .NET Framework 4.7.2, built into Windows 10 1803+ and 11. Settings go to `Rapr.user.config` next to the exe, so the manifest persists it; the file is rewritten in place, so Scoop's hardlink holds. Do not use the update check in the About box, it replaces `Rapr.exe` inside the version folder; use `scoop update`. `checkver` reads the latest GitHub release, not tags: upstream tags every push to `master` (v1.0.76 exists without a release). Hash checked against [winget](https://github.com/microsoft/winget-pkgs/tree/master/manifests/l/lostindark/DriverStoreExplorer); `Rapr.exe` is signed by SignPath Foundation. The [Extras](https://github.com/ScoopInstaller/Extras) bucket has it too as `driverstoreexplorer`, without persisting the settings, so they reset on every update. License: the repository ships the plain GPL v2 text without an "or later" clause, hence `GPL-2.0-only` (Extras says `GPL-2.0-or-later`).

[All packages](../../README.md#packages)
