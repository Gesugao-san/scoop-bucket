# mtg-multi

| | |
|---|---|
| Manifest | [`bucket/mtg-multi.json`](../../bucket/mtg-multi.json) |
| Upstream | [mhsanaei/mtg-multi](https://github.com/mhsanaei/mtg-multi) (MIT; fork of [9seconds/mtg](https://github.com/9seconds/mtg)) |
| Install | `scoop install gesu/mtg-multi` |

Telegram MTProto proxy with FakeTLS and domain fronting, by the author of [`3X-UI`](3x-ui.md), which runs it for its MTProto inbounds. Upstream mtg serves one secret; this fork serves many: a named secret per user (each with its own fronting host), live per-user traffic stats, per-user quotas, expiry and an on/off switch, a management API with token authentication, hot reload of the secrets, connection throttling, a public IP override and the sponsored-channel ad-tag that mtg 2 dropped.

Downloads upstream's `mtg-multi-<version>-windows-amd64.zip`, `-windows-386.zip` and `-windows-arm64.zip` from the GitHub release. The hashes are the SHA-256 digests GitHub shows for the assets; autoupdate reads them from the release's `mtg-multi-<version>-checksums.txt`. The archives could not be downloaded where this package was written: run `.\bin\checkhashes.ps1 mtg-multi` on Windows. Each archive has one folder with `mtg-multi.exe`, `example.config.toml`, `README.md` and `LICENSE`; the manifest unpacks that folder. No mirror: upstream publishes only on GitHub.

## Commands and shortcut

| Command | Does |
|---|---|
| `mtg-multi generate-secret --hex <host>` | New secret fronted by `<host>` (a real HTTPS site the traffic imitates) |
| `mtg-multi run <config.toml>` | Runs the proxy from a config file: every feature, hot reload |
| `mtg-multi simple-run <bind-to> <secret>` | One secret, no config file |
| `mtg-multi access <config.toml>` | `tg://` and `t.me` links and QR-code URLs for the configured secrets |

*Scoop Apps* gets an **mtg-multi** shortcut. `mtg-multi.exe` without arguments only prints an error, so the shortcut opens `mtg-multi.cmd`, a micro-launcher written at install time that explains the commands, prints `mtg-multi --help` and waits for a key.

## Configuration

`example.config.toml` in the app folder is upstream's annotated sample. The app folder is replaced on every update, so copy the sample somewhere of your own before editing it and pass that path to `run`. Set `usage-state-file` in it to keep the per-user quota counters across restarts. Nothing is persisted by Scoop: the package writes no settings of its own.

[`3X-UI`](3x-ui.md) writes its own config files for each MTProto inbound and copies `mtg-multi.exe` into its `bin` folder as `mtg-windows-amd64.exe` each time it starts.

## Conflicts

Not in Scoop's main or extras bucket (November 2026); other buckets could not be searched on [scoop.sh](https://scoop.sh/) from where this package was written. It is a single portable exe that registers nothing.

[All packages](../../README.md#packages)
