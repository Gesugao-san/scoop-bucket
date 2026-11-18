# Tixati

| | |
|---|---|
| Manifest | [`bucket/Tixati.json`](../../bucket/Tixati.json) |
| Upstream | [tixati.com](https://tixati.com) (Tixati Software, freeware) |
| Install | `scoop install gesu/Tixati` |

BitTorrent client. Uses the official standalone zips (x64 and x86), so nothing is extracted from an installer. The zip leaves standalone mode off, so settings, transfers and channels stay in `%APPDATA%\tixati` and survive updates; Tixati rewrites its `.dat` files (with `.dat.old` backups) instead of writing into them, so persisting them through Scoop's hardlinks would break. `checkver` also reads the build number (`3.44-1`). The [Extras](https://github.com/ScoopInstaller/Extras) bucket has `tixati` too, built from the installer with portable mode on. Hashes checked against Tixati's GPG signatures.

[All packages](../../README.md#packages)
