# doggo

| | |
|---|---|
| Manifest | [`bucket/doggo.json`](../../bucket/doggo.json) |
| Upstream | [mr-karan/doggo](https://github.com/mr-karan/doggo) (Karan Sharma, GPL-3.0) |
| Install | `scoop install gesu/doggo` |

Command-line DNS client in the spirit of `dig`, with readable, coloured output. It queries over plain UDP and TCP, DNS-over-TLS, DNS-over-HTTPS (HTTP/2 and HTTP/3), DNS-over-QUIC and DNSCrypt, prints JSON for scripts, does reverse lookups (`--reverse`) and follows the delegation from the root servers (`--trace`). Written in Go as a rewrite of [dog](https://github.com/ogham/dog), hence the name.

Downloads the official zips from the GitHub release: `doggo-windows-x86_64.zip` and `doggo-windows-i386.zip`. Upstream ships no Windows ARM64 build; on ARM64 Windows Scoop falls back to the x64 one, which runs emulated. Autoupdate takes the hashes from the release's `doggo_<version>_checksums.txt`. No mirror: upstream publishes only on GitHub.

## Commands and shortcuts

- `doggo`: the client. The server and protocol come from the `@` argument: `@9.9.9.9` (UDP), `@tcp://1.1.1.1`, `@tls://1.1.1.1` (DoT), `@https://cloudflare-dns.com/dns-query` (DoH), `@quic://dns.quad9.net` (DoQ), `@sdns://...` (DNSCrypt or DoH from a DNS stamp).
- Without `@`, doggo asks the DNS servers configured on the network adapters (it reads them from Windows, [`config_windows.go`](https://github.com/mr-karan/doggo/blob/v1.4.2/pkg/config/config_windows.go)); on a home network that is usually the router.

*Scoop Apps* gets a **doggo** shortcut. `doggo.exe` prints its help and exits at once, so the shortcut opens `doggo.cmd`, a micro-launcher written at install time that explains the command, shows examples (one per protocol) and waits for a key.

## Settings

Defaults for any long flag can come from a TOML file or from `DOGGO_*` environment variables ([reference](https://github.com/mr-karan/doggo/blob/v1.4.2/docs/src/content/docs/guide/reference.md)). On Windows the file is `%APPDATA%\doggo\config.toml`, or `%USERPROFILE%\.doggo.toml`, or any path given with `--config` or `DOGGO_CONFIG`. Both default locations are outside the Scoop folder, so the settings survive updates without `persist`, and `scoop uninstall --purge` does not delete them. doggo writes nothing next to its exe.

## Conflicts

Scoop's [Main](https://github.com/ScoopInstaller/Main) bucket has [`doggo`](https://github.com/ScoopInstaller/Main/blob/master/bucket/doggo.json) too (1.4.2 as of November 2026, same files and hashes). Scoop treats `main/doggo` and `gesu/doggo` as the same app: while one is installed, installing the other says it is already installed. Run `scoop uninstall doggo` first, then install the other one; the settings stay.

There is no check for copies installed without Scoop: doggo is portable and registers nothing, so another copy does not interfere.

[All packages](../../README.md#packages)
