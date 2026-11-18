# King-Arthurs-Gold

| | |
|---|---|
| Manifest | [`bucket/King-Arthurs-Gold.json`](../../bucket/King-Arthurs-Gold.json) |
| Upstream | [kag2d.com](https://kag2d.com) (Transhuman Design, free to play; [Steam app 219830](https://store.steampowered.com/app/219830/King_Arthurs_Gold/)) |
| Install | `scoop install gesu/King-Arthurs-Gold        # asks: Steam or standalone` |

One package for both copies of the game. If Steam is installed, `scoop install` asks (one key, 30 seconds, default Steam) whether to install **through Steam** (`steam://install/219830`; Steam updates it and launches it with `steam noautoupdate`, per [SteamDB](https://steamdb.info/app/219830/config/)) or the **standalone** client; without Steam it installs the standalone client. `$env:GESU_KAG_SOURCE = 'steam'` or `'standalone'` skips the question (for UniGetUI, which has no console to answer in); the choice is kept in `source.txt` for `scoop update`, and a new install asks again. The standalone client is portable: Scoop unpacks THD's MSI (no admin; the VC90 runtime the MSI would put in WinSxS is only used by an unused `libssl32.dll`), and `KAG.exe` itself needs the 32-bit VC++ 2015–2022 runtime, so the manifest suggests `extras/vcredist2022`. The client updates itself from `update.kag2d.com` on start and keeps settings (`*.cfg`, per [PCGamingWiki](https://www.pcgamingwiki.com/wiki/King_Arthur%27s_Gold)) and screenshots in its own folder, so the whole `KAG` folder is persisted. The MSI URL has no version, so the version is its `Last-Modified` date, like `PlanetSide-2-LaunchPad`. The `King-Arthurs-Gold` command and the *King Arthur's Gold* shortcut in Scoop Apps are written at install time for the chosen copy. Stops if the game was installed with THD's MSI outside Scoop: its uninstaller deletes its whole folder (`WixRemoveFolderEx`), so back up `*.cfg` first.

[All packages](../../README.md#packages)
