# FerrumC

| | |
|---|---|
| Manifest | [`bucket/FerrumC.json`](../../bucket/FerrumC.json) |
| Upstream | [ferrumc.com](https://www.ferrumc.com/) ([ferrumc-rs/ferrumc](https://github.com/ferrumc-rs/ferrumc), MIT) |
| Install | `scoop install gesu/FerrumC` |

A Minecraft 1.21.8 server written from the ground up in Rust: fully multithreaded, built on an entity component system, with low memory use and fast world loading. It imports vanilla worlds. Its authors do not aim at a perfect copy of the vanilla server; there is no plugin system yet. Clients must be Minecraft 1.21.8.

Downloads `ferrumc-v<version>-x86_64-pc-windows-msvc.zip` from the GitHub release, with `ferrumc.exe`. Upstream ships no Windows ARM64 build. Autoupdate takes the hash from the `.sha256` file next to the zip. Its only releases so far are release candidates (`v0.1.0-rc1`, `v0.1.0-rc2` from February 2026), while `master` moves on; `checkver` reads the latest release, so the package follows whatever upstream releases next.

Mirror: SourceForge's automatic copy of the releases, [ferrumc.mirror](https://sourceforge.net/projects/ferrumc.mirror/) (byte-identical for 0.1.0-rc2): `.\bin\Use-Mirror.ps1 gesu/FerrumC sourceforge` (see [Installing from a mirror](../mirrors.md)).

## Starting and stopping

*Scoop Apps* gets a **FerrumC (Minecraft server)** shortcut, and consoles get the `ferrumc` command. Both run `FerrumC.cmd`, a micro-launcher written at install time. The shortcut passes `/PAUSE`, which keeps the window open after the server stops; the command passes its arguments on to `ferrumc.exe` instead, so `ferrumc setup`, `ferrumc import` and `ferrumc clear` work as upstream describes.

Stop the server with Ctrl+C before `scoop update` or `scoop uninstall`: Scoop refuses to remove a running exe.

Windows Firewall asks for network access on the first start, and again after every update, because the exe moves to a new version folder. The server listens on port 25565 by default, like the other servers in this bucket: run one at a time or change the port in `configs\config.toml`.

## Data

FerrumC keeps its files next to its exe, not in the current folder ([`paths`](https://github.com/ferrumc-rs/ferrumc/blob/HEAD/src/lib/utils/general_purpose/src/paths/mod.rs)), so the manifest persists them one by one in `%USERPROFILE%\scoop\persist\FerrumC`: `configs` (`config.toml`, written on the first start), `world`, `import`, `logs` and `whitelist.txt`. Scoop would turn a missing `whitelist.txt` into a folder, so `pre_install` creates an empty file the first time; FerrumC reads it as an empty whitelist. Updates keep these files; only `scoop uninstall -p` deletes them.

A custom server icon (`icon.png`, 64x64) also goes next to the exe, in `%USERPROFILE%\scoop\apps\FerrumC\current`, but it is not persisted: copy it again after an update. Without it FerrumC uses its built-in icon.

To import a vanilla world, copy the world folder's contents (`region`, `playerdata`, ...) into `%USERPROFILE%\scoop\persist\FerrumC\import`, then run `ferrumc import --import-path import`.

`ferrumc clear` deletes the folders and files it names, which here are Scoop's links into `persist`: run `scoop reset FerrumC` afterwards, or the next start writes into the app folder, where an update loses it.

## Conflicts

No official Scoop bucket has FerrumC (November 2026). Upstream has no installer, so there is no check for copies installed without Scoop.

[All packages](../../README.md#packages)
