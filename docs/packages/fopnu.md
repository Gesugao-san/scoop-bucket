# Fopnu

| | |
|---|---|
| Manifest | [`bucket/Fopnu.json`](../../bucket/Fopnu.json) |
| Upstream | [fopnu.com](https://www.fopnu.com) (Tixati Software, freeware) |
| Install | `scoop install gesu/Fopnu` |

Decentralized file sharing from Tixati's author. There is no standalone zip: the installer is a small stub that carries `fopnu.exe` as a bzip2 resource, which 7-Zip unpacks and the manifest renames (the same binary as in the official portable zip, checked by hash). Settings stay in `%APPDATA%\fopnu`. Hashes checked against the GPG signatures. License: the agreement from the installer, see [`licenses/Fopnu.txt`](../../licenses/Fopnu.txt).

[All packages](../../README.md#packages)
