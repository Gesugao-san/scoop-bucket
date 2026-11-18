# x64dbg

| | |
|---|---|
| Manifest | [`bucket/x64dbg.json`](../../bucket/x64dbg.json) |
| Upstream | [x64dbg/x64dbg](https://github.com/x64dbg/x64dbg) |
| Install | `scoop install gesu/x64dbg` |

x64/x32 debugger: `x96dbg`, `x64dbg` and `x32dbg` commands and shortcuts (32-bit Windows gets only `x96dbg` and `x32dbg`). Downloads the snapshot zip from the GitHub release; the version is the release tag (`2026.05.27`), and `checkver` reads the snapshot file name from the latest release's assets, skipping `symbols-snapshot_*`. The `.ini` settings, `db`, `plugins`, `symbols`, `memdumps` and `garbage` folders of both builds are persisted, as in the [Extras](https://github.com/ScoopInstaller/Extras) bucket's `x64dbg`, which takes the same snapshots from SourceForge with a SHA-1 hash; this one checks SHA-256. License: GPL v3 with an [added section](https://github.com/x64dbg/x64dbg/blob/HEAD/LICENSE) that lets closed-source plugins use the plugin interface.

[All packages](../../README.md#packages)
