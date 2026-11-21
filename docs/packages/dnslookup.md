# dnslookup

| | |
|---|---|
| Manifest | [`bucket/dnslookup.json`](../../bucket/dnslookup.json) |
| Upstream | [ameshkov/dnslookup](https://github.com/ameshkov/dnslookup) (Andrey Meshkov, MIT) |
| Install | `scoop install gesu/dnslookup` |

Simple command-line tool that sends one DNS query and prints the answer, over any DNS protocol: plain DNS over UDP and TCP, DNS-over-TLS, DNS-over-HTTPS (HTTP/2 and HTTP/3), DNS-over-QUIC and DNSCrypt. Handy for checking whether an encrypted resolver is reachable and whether its answer differs from the one plain DNS gives.

Downloads the official zips from the GitHub release: `dnslookup-windows-amd64-v<version>.zip` and `dnslookup-windows-386-v<version>.zip`, each with the exe in a `windows-amd64` or `windows-386` folder (`extract_dir`). Upstream ships no Windows ARM64 build; on ARM64 Windows Scoop falls back to the x64 one, which runs emulated. Upstream publishes no checksums file, so autoupdate lets Scoop compute the hash of each new version. No mirror: upstream publishes only on GitHub.

## Usage

`dnslookup <name> [server]`. The protocol comes from the server address:

| Server | Protocol |
|---|---|
| (none) | The system resolver |
| `9.9.9.9` | Plain DNS over UDP |
| `tcp://9.9.9.9` | Plain DNS over TCP |
| `tls://one.one.one.one` | DNS-over-TLS (TCP port 853) |
| `https://cloudflare-dns.com/dns-query` | DNS-over-HTTPS, HTTP/2 |
| `h3://dns.google/dns-query` | DNS-over-HTTPS, HTTP/3 only |
| `quic://dns.quad9.net` | DNS-over-QUIC (UDP port 853) |
| `sdns://...` | DNSCrypt (or another protocol) from a DNS stamp |

A third argument gives the server's IP address, so dnslookup connects to it without resolving the server's name first: `dnslookup example.org https://cloudflare-dns.com/dns-query 1.1.1.1`. That avoids depending on plain DNS when plain DNS is the thing being tested. An IP address as the name makes a reverse (PTR) query.

Options are **environment variables**, not flags ([README](https://github.com/ameshkov/dnslookup/blob/v1.12.0/README.md)): `RRTYPE=AAAA`, `CLASS=CH`, `JSON=1`, `VERBOSE=1`, `DNSSEC=1`, `SUBNET=1.2.3.4/24`, `PAD=1`, `VERIFY=0`, `HTTP3=1` and others. Upstream's examples use the Unix form `RRTYPE=AAAA dnslookup ...`, which neither cmd nor PowerShell understands:

```cmd
SET RRTYPE=AAAA
dnslookup example.org 9.9.9.9
SET RRTYPE=
```

```powershell
$env:RRTYPE = 'AAAA'
dnslookup example.org 9.9.9.9
Remove-Item Env:RRTYPE
```

The variable stays set in that window until cleared, and applies to every later `dnslookup` there.

## Shortcut

*Scoop Apps* gets a **dnslookup** shortcut. `dnslookup.exe` prints its usage and exits at once, so the shortcut opens `dnslookup.cmd`, a micro-launcher written at install time that shows the examples above, the cmd and PowerShell form of the options, and waits for a key. dnslookup keeps no settings.

## Conflicts

Scoop's [Main](https://github.com/ScoopInstaller/Main) bucket has [`dnslookup`](https://github.com/ScoopInstaller/Main/blob/master/bucket/dnslookup.json) too (1.12.0 as of November 2026, same files and hashes). Scoop treats `main/dnslookup` and `gesu/dnslookup` as the same app: while one is installed, installing the other says it is already installed. Run `scoop uninstall dnslookup` first, then install the other one.

There is no check for copies installed without Scoop: dnslookup is portable and registers nothing.

[All packages](../../README.md#packages)
