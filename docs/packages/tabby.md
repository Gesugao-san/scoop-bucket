# Tabby

| | |
|---|---|
| Manifest | [`bucket/Tabby.json`](../../bucket/Tabby.json) |
| Upstream | [tabby.sh](https://tabby.sh) ([Eugeny/tabby](https://github.com/Eugeny/tabby), MIT) |
| Install | `scoop install gesu/Tabby` |

Modern terminal with tabs and split panes: local shells, SSH with SFTP, Telnet and serial ports, with built-in ZModem (`sz`/`rz` on the remote side), e.g. to move files over a router's serial console. Extracted from the official x64 setup (the app archive inside it); command `Tabby`, *Tabby* shortcut in Scoop Apps. It runs in portable mode from the persisted `data` folder (settings, profiles, vault); an existing `%APPDATA%\Tabby` is copied there on the first install. Its own updater should be turned off in its settings (the notes say so), updates come from Scoop. x64 only for now: the ARM64 setup is published, but its hash could not be taken here. `checkver` follows GitHub releases, autoupdate reads the hash from `latest-x64.yml`. Same manifest as Scoop Extras (`extras/tabby`), with notes; hash taken from it.

[All packages](../../README.md#packages)
