# DarkMX

| | |
|---|---|
| Manifest | [`bucket/DarkMX.json`](../../bucket/DarkMX.json) |
| Upstream | [darkmx.app](https://darkmx.app) (Tixati Software, freeware) |
| Install | `scoop install gesu/DarkMX` |

Anonymous file sharing and chat over Tor hidden services. Runs its own built-in Tor client, so Tor Browser is not required; the manifest [suggests](https://github.com/ScoopInstaller/Scoop/wiki/App-Manifests#optional-properties) `extras/tor-browser` for opening `.onion` sites, including the one DarkMX can host. The official zips (x64 and x86) ship with `darkmx_standalone_mode.txt`, which keeps config next to the exe; the manifest deletes it so the config goes to `%APPDATA%` and survives updates. Hashes checked against the GPG signatures.

[All packages](../../README.md#packages)
