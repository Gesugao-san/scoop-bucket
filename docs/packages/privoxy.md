# Privoxy

| | |
|---|---|
| Manifest | [`bucket/Privoxy.json`](../../bucket/Privoxy.json) |
| Upstream | [privoxy.org](https://www.privoxy.org) ([SourceForge](https://sourceforge.net/projects/ijbswa/files/Win32/)) |
| Install | `scoop install gesu/Privoxy` |

Filtering proxy on `127.0.0.1:8118`. Portable: unpacked from the upstream NSIS installer, without the Windows service. `config.txt`, `trust.txt`, `user.action` and `user.filter` are persisted. Windows builds lag behind: 4.2.0 is out for other systems, but the newest Windows build is 4.1.0. The [Extras](https://github.com/ScoopInstaller/Extras) bucket also has `privoxy`, stuck at 4.0.0: its autoupdate expects a `<version> (stable)` folder on SourceForge, and the 4.1.0 folder has no such suffix. This manifest reads the folder name in `checkver`, so either naming works.

[All packages](../../README.md#packages)
