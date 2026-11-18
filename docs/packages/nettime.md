# NetTime

| | |
|---|---|
| Manifest | [`bucket/NetTime.json`](../../bucket/NetTime.json) |
| Upstream | [timesynctool.com](https://www.timesynctool.com) ([SourceForge](https://sourceforge.net/projects/nettime/)) |
| Install | `scoop install -g gesu/NetTime   # global, from an elevated shell` |

SNTP client that runs as the Windows service `NetTimeSvc` (as SYSTEM). **Global install only** (`scoop install -g`, elevated shell): a SYSTEM service must not run files that a non-admin program could replace, so the manifest refuses a per-user install. `post_install` also restricts the app folder to Administrators and SYSTEM (`icacls`, by SID so it works on localized Windows); new version folders inherit that. Updates and uninstall need admin too. Before `scoop update -g NetTime`, run `Stop-Service NetTimeSvc`: Scoop refuses to update an app with a running process and checks that before any manifest script runs ([#2952](https://github.com/ScoopInstaller/Scoop/issues/2952)); `scoop uninstall` stops the service by itself in `pre_uninstall`. Portable: the files are unpacked from the upstream Inno Setup installer, and `post_install` creates the service pointing to `current`, so it survives updates. Updates only stop the service; `scoop uninstall` also deletes it. Settings stay in `HKLM\Software\Wow6432Node\Subjective Software\NetTime`. Refuses to install if `NetTimeSvc` already exists from the regular installer. Tracks the stable version (3.14); the 3.20 alphas are not packaged. License: a short custom attribution notice, not BSD despite what some catalogs say; see [`licenses/NetTime.txt`](../../licenses/NetTime.txt).

[All packages](../../README.md#packages)
