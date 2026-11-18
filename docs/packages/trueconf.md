# TrueConf

| | |
|---|---|
| Manifest | [`bucket/TrueConf.json`](../../bucket/TrueConf.json) |
| Upstream | [trueconf.com](https://trueconf.com/downloads/windows.html) (TrueConf, proprietary) |
| Install | `scoop install gesu/TrueConf` |

Video conferencing client for TrueConf Server and TrueConf Online. Portable: the files are unpacked from the official MSI (x64 and x86) with `msiexec /a`, which runs none of its custom actions. The MSI installs no drivers or services; what it does besides copying files, and this manifest skips, is Windows Firewall rules for `TrueConf.exe` and `ExecutorServer.exe` (Windows asks on the first call instead), an autostart entry and a desktop shortcut. It also registers `trueconf://` links, which the manifest does in `post_install` for the current user (all users with `-g`), pointing to `current`; `scoop uninstall` removes them if they still point there. Accounts, chats and settings live in `%LOCALAPPDATA%\TrueConf\Client`, outside Scoop. The download URL has no version, but the [downloads page](https://trueconf.com/downloads/windows.html) links it as `...x64.msi?v=<version>`, which `checkver` reads; the manifest keeps the `?v=` so each version gets its own cache entry. The x64 hash matches [winget](https://github.com/microsoft/winget-pkgs/tree/master/manifests/t/TrueConf/TrueConf); winget has no x86 build to compare with. Decline client updates offered by a TrueConf Server: they would install a second copy into Program Files. The same files (identical hashes and signatures) are on `download.trueconf.ru`, listed in [`mirrors.psd1`](../../mirrors.psd1) as `trueconf.ru` for [`Use-Mirror.ps1`](../mirrors.md#installing-from-a-mirror) if `trueconf.com` is unreachable (`.\bin\Use-Mirror.ps1 gesu/TrueConf mirror1`).

[All packages](../../README.md#packages)
