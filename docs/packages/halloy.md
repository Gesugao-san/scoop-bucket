# Halloy

| | |
|---|---|
| Manifest | [`bucket/Halloy.json`](../../bucket/Halloy.json) |
| Upstream | [halloy.chat](https://halloy.chat) ([squidowl/halloy](https://github.com/squidowl/halloy), GPL-3.0) |
| Install | `scoop install gesu/Halloy` |

Open-source IRC client written in Rust with the [iced](https://iced.rs) GUI library: several servers at once, IRCv3 (chathistory, typing notifications, reactions), SASL PLAIN and EXTERNAL, themes, split panes. Extracted from the official x64 Inno Setup installer (`halloy-installer.exe`, signed through SignPath), which holds a single `halloy.exe`; upstream ships no ARM64 or portable Windows build. *Halloy* shortcut in Scoop Apps. `checkver` follows GitHub releases. Upstream publishes `checksums.txt` only when its maintainers run the checksum workflow by hand (not for 2026.10), so autoupdate computes the hash from the download.

## Data in persist

Halloy runs in [portable mode](https://halloy.chat/guides/portable-mode) when the environment variable `HALLOY_PORTABLE_DIR` points to an existing folder (or when `config.toml` lies next to `halloy.exe`), and then keeps everything in that one folder: `config.toml`, the history database `history.sqlite3` (with its `-wal` and `-shm` files while Halloy runs), `msdb`, `logs`, `themes`, `sounds`, `drafts.json`, `window.json`, `dashboard.json.gz` and `known_filehosts`. Relative paths in the config (`password_file`, SASL EXTERNAL certificates) are resolved against that folder too.

The manifest sets `HALLOY_PORTABLE_DIR` (a user variable, system-wide for `-g`) to the app's persist folder, `~\scoop\persist\Halloy`, instead of listing the files in `persist`: Scoop links persisted files into the app folder as hard links, and the list would have to follow every file Halloy adds. Scoop announces the variable to running programs; if Halloy still starts with an empty config right after the first install, sign out and back in once. `scoop uninstall` removes the variable, `scoop uninstall -p` also deletes the folder.

There is no default config in the manifest: on its first start Halloy writes its own `config.toml` from upstream's template, with a random `halloyNNNN` nick.

On install, data is copied (not moved) into the persist folder when it does not have it yet:

- from the previous version folder, which is where `extras/halloy` and other manifests without the variable leave `history.sqlite3` and the rest;
- from `%APPDATA%\halloy`, Halloy's folder without portable mode (upstream's installer, a copy run by hand), if the persist folder has no `config.toml`.

## Compared with extras/halloy

The [Extras](https://github.com/ScoopInstaller/Extras) bucket's [`halloy`](https://github.com/ScoopInstaller/Extras/blob/master/bucket/halloy.json) (2026.10 as of November 2026) also runs Halloy in portable mode, but from the app folder: it persists only `themes` and `history`, and its installer and uninstaller scripts move `*.toml`, `*.log` and `*.gz` in and out of the persist folder. Since 2026.10 Halloy stores history in `history.sqlite3` (older `history` folders are migrated into it), so on every `scoop update` that manifest leaves the history database, `msdb`, `logs`, `sounds`, `drafts.json`, `window.json` and `known_filehosts` behind in the old version folder, and `scoop cleanup` deletes them. Its default config also sets the same nick, `halloy8765`, for every user; on Libera.Chat that nick is registered, so NickServ asks every new Scoop user for its password.

### Switching from extras/halloy

`scoop uninstall halloy` deletes the app folder with the history in it, so copy the data into the persist folder first. Close Halloy, then:

```powershell
$cur = scoop prefix halloy
$persist = Join-Path (Split-Path (Split-Path (Split-Path $cur))) 'persist\halloy'
$keep = 'history.sqlite3*', 'msdb', 'logs', 'irc_protocol_logs', 'sounds', 'drafts.json', 'window.json', 'known_filehosts', '*.gz', '*.log', '*.toml'
Get-ChildItem -LiteralPath $cur |
  Where-Object { $name = $_.Name; @($keep | Where-Object { $name -like $_ }).Count -gt 0 } |
  ForEach-Object { Copy-Item -LiteralPath $_.FullName -Destination (Join-Path $persist $_.Name) -Recurse -Force }
scoop uninstall halloy
scoop install gesu/Halloy
```

Scoop is case-insensitive, so `extras/halloy` and `gesu/Halloy` share the app and persist folders and cannot be installed side by side.

## Passwords

Instead of writing passwords into `config.toml`, Halloy (2026.8 and later) can keep them in Windows Credential Manager: set `password_keyring = true` (for SASL under `[servers.<name>.sasl.plain]`) and Halloy asks for the password on the next start. See upstream's [keyring guide](https://halloy.chat/guides/keyring). Credential Manager is outside the persist folder: `scoop uninstall -p` does not delete those entries.

## Links

Upstream's installer registers Halloy for `irc://`, `ircs://` and `halloy://` links (theme links on [themes.halloy.chat](https://themes.halloy.chat) use the last one). Scoop does not run the installer, so these links are not registered.

## Copies installed without Scoop

A fresh install stops if Halloy is installed with upstream's installer (uninstall entry `{3ED18662-FB43-4803-A4F9-89BBBC0B6D01}_is1`, per user by default): with `HALLOY_PORTABLE_DIR` set, that copy would also use the persist folder, and both copies would write to the same history. Uninstall it first in Settings > Apps; its data in `%APPDATA%\halloy` stays and is copied into the persist folder on install. There is no [override](../conventions.md#programs-installed-outside-scoop).

A fresh install, `scoop update` and `scoop uninstall` also stop while Halloy is running or its files are open (see [Programs that are running or have files open](../conventions.md#programs-that-are-running-or-have-files-open)).

## Mirror

SourceForge's [`halloy-irc-client.mirror`](https://sourceforge.net/projects/halloy-irc-client.mirror/) copies the GitHub releases automatically (not run by the developers); its `2026.10/halloy-installer.exe` has the same SHA-256 as the GitHub file. See [Installing from a mirror](../mirrors.md).

[All packages](../../README.md#packages)
