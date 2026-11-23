# Chocolate4U-Iran-v2ray-rules

| | |
|---|---|
| Manifest | [`bucket/Chocolate4U-Iran-v2ray-rules.json`](../../bucket/Chocolate4U-Iran-v2ray-rules.json) |
| Upstream | [Chocolate4U/Iran-v2ray-rules](https://github.com/Chocolate4U/Iran-v2ray-rules) (GPL-3.0; built from MaxMind GeoLite2 and IP2Location LITE data, CC BY-SA 4.0) |
| Install | `scoop install gesu/Chocolate4U-Iran-v2ray-rules` |

Geo files for Xray and V2Ray tuned for users in Iran: `geoip:ir` with the ranges of Iranian CDNs (ArvanCloud, Derak, IranServer, ParsPack) and messengers, `geosite:ir` with Iranian domains outside `.ir`, Persian ad lists, and block lists for malware, phishing and cryptominers. Rebuilt by upstream's [workflow](https://github.com/Chocolate4U/Iran-v2ray-rules/blob/HEAD/.github/workflows/release.yml) every day at 04:40 UTC. [`3X-UI`](3x-ui.md) uses `geoip.dat` and `geosite.dat` from here as `geoip_IR.dat` and `geosite_IR.dat`.

Data only: no program, no command.

## Files

All eleven `.dat` and `.mmdb` files of the GitHub release, each with its hash from the release's `.sha256sum` file (checked against the files on upstream's `release` branch for 202611221249):

| File | Format | Contents |
|---|---|---|
| `geoip.dat` | V2Ray / Xray | Every country; `ir` with the Iranian CDNs and messengers, `private`, `cloudflare`, `cloudfront`, `fastly`, `gcore`, `google`, `amazon`, `microsoft`, `netflix`, `bing`, `malware`, `phishing` and more |
| `geosite.dat` | V2Ray / Xray | [v2fly](https://github.com/v2fly/domain-list-community) lists plus `ir`, `category-ir`, `ads`, `category-ads-all`, `malware`, `phishing`, `cryptominers`, `sanctioned` and others |
| `geoip-lite.dat` | V2Ray / Xray | Only `ir` and `private` |
| `geosite-lite.dat` | V2Ray / Xray | Only `ir`, `category-ir` and `ads` |
| `geoip-services.dat` | V2Ray / Xray | Only the CDN and service ranges |
| `security.dat` | V2Ray / Xray | `geosite:` `category-ads-all`, `malware`, `phishing`, `cryptominers` |
| `security-ip.dat` | V2Ray / Xray | `geoip:` `malware`, `phishing` |
| `Country.mmdb`, `Country-lite.mmdb`, `Services.mmdb`, `Security-ip.mmdb` | MaxMind | The same lists as `geoip`, `geoip-lite`, `geoip-services` and `security-ip` |

The release branch also has plain-text lists; upstream publishes rules for sing-box and Clash in separate projects. Neither is in this package.

*Scoop Apps* gets a **Chocolate4U Iran-v2ray-rules** shortcut. It opens `Chocolate4U-Iran-v2ray-rules.cmd`, a micro-launcher written at install time that shows the release, the folder and what each file is for, and waits for a key.

## Using the files

- **3X-UI:** nothing to do once this package is installed; it copies `geoip.dat` and `geosite.dat` into its `bin` folder as `geoip_IR.dat` and `geosite_IR.dat` each time it starts. Without this package 3X-UI uses the copies from its own release archive.
- **Xray / V2Ray:** point `XRAY_LOCATION_ASSET` at `%USERPROFILE%\scoop\apps\Chocolate4U-Iran-v2ray-rules\current` and use `geosite:ir`, or the smaller files with `ext:geosite-lite.dat:ir` and the like. Upstream's README has a ready routing example.

## Updates

The version is upstream's release tag (UTC date and time of the build). `checkver` reads the latest release; autoupdate takes every hash from `<file>.sha256sum`. A new set (about 38 MB) comes about once a day.

## Mirrors

Upstream pushes every build to its [`release`](https://github.com/Chocolate4U/Iran-v2ray-rules/tree/release) branch and documents it, together with jsDelivr, as a download location. Those links always give the newest build, so they match the manifest's hashes only until the next build. [`mirrors.psd1`](../../mirrors.psd1) lists the `raw.githubusercontent.com` copy: `0..10 | ForEach-Object { .\bin\Use-Mirror.ps1 gesu/Chocolate4U-Iran-v2ray-rules raw -Index $_ }`. jsDelivr could not be checked from where the package was written.

## Conflicts

Not in Scoop's main or extras bucket. Data only, written to its own folder: nothing to conflict with.

[All packages](../../README.md#packages)
