# q-DNS

| | |
|---|---|
| Manifest | [`bucket/q-DNS.json`](../../bucket/q-DNS.json) |
| Upstream | [natesales/q](https://github.com/natesales/q) (Nate Sales, GPL-3.0) |
| Install | `scoop install gesu/q-DNS` |

Small command-line DNS client with the widest protocol support of the common ones: plain UDP and TCP, DNS-over-TLS, DNS-over-HTTPS (HTTP/2 and HTTP/3), DNS-over-QUIC, Oblivious DoH (ODoH) and DNSCrypt. It queries several record types at once (by default A, AAAA, NS, MX, TXT and CNAME), prints `dig`-style, JSON, YAML or column output, and can show the ASN of returned addresses (`-w`).

Downloads the official zips from the GitHub release: `q_<version>_windows_amd64.zip` and `q_<version>_windows_arm64.zip`. Upstream ships no 32-bit Windows build. Autoupdate takes the hashes from the release's `q_<version>_checksums.txt`. No mirror: upstream publishes only on GitHub.

## Name and command

The program is called `q`, but Scoop's [Main](https://github.com/ScoopInstaller/Main) bucket already has a [`q`](https://github.com/ScoopInstaller/Main/blob/master/bucket/q.json): [harelba/q](https://github.com/harelba/q), an unrelated tool that runs SQL on CSV files and also adds a `q` command. So this package is named `q-DNS` (shown as "Q DNS" in UniGetUI) and adds the command **`qdns`**, never `q`. Both packages can be installed at once without clashing.

## Default server

Without an `@server` argument, q uses `Q_DEFAULT_SERVER`, then the first server in `/etc/resolv.conf` ([`main.go`](https://github.com/natesales/q/blob/v0.19.12/main.go)). Windows has no `/etc/resolv.conf`, so **`qdns example.com` asks Cloudflare over DNS-over-HTTPS** (`https://cloudflare-dns.com/dns-query`), not the network's DNS server. To ask the router, name it (`qdns example.com @192.168.1.1`), or set a default for the session:

```cmd
SET Q_DEFAULT_SERVER=192.168.1.1
```

```powershell
$env:Q_DEFAULT_SERVER = '192.168.1.1'
```

Use `setx Q_DEFAULT_SERVER 192.168.1.1` to keep it for new windows.

## Usage

`qdns [options] [@server] [type...] [name]`; long flags can also be written dig-style as `+[no]flag`. The server's scheme picks the protocol: `@9.9.9.9` (UDP), `@tcp://9.9.9.9`, `@tls://1.1.1.1`, `@https://cloudflare-dns.com/dns-query` (add `--http3` for HTTP/3), `@quic://dns.quad9.net`, `@sdns://...` (a DNS stamp). `-x` makes a reverse lookup, `--format=raw` prints like `dig`.

## Shortcut

*Scoop Apps* gets a **q (DNS client)** shortcut. `q.exe` prints its help and exits at once, so the shortcut opens `q-DNS.cmd`, a micro-launcher written at install time that explains the `qdns` name and the default server, shows examples (one per protocol) and waits for a key. q keeps no settings.

## Conflicts

Neither Main nor Extras packages natesales/q (checked November 2026), and nothing there adds a `qdns` command. There is no check for copies installed without Scoop: q is portable and registers nothing.

[All packages](../../README.md#packages)
