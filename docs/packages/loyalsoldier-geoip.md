# Loyalsoldier-GeoIP

| | |
|---|---|
| Manifest | [`bucket/Loyalsoldier-GeoIP.json`](../../bucket/Loyalsoldier-GeoIP.json) |
| Upstream | [Loyalsoldier/geoip](https://github.com/Loyalsoldier/geoip) (data CC-BY-SA-4.0, tool GPL-3.0; includes MaxMind GeoLite2 data) |
| Install | `scoop install gesu/Loyalsoldier-GeoIP` |

IP-to-country databases, rebuilt by upstream's [workflow](https://github.com/Loyalsoldier/geoip/blob/HEAD/.github/workflows/build.yml) every Thursday (00:00 UTC) from [MaxMind GeoLite2 Country](https://dev.maxmind.com/geoip/geolite2-free-geolocation-data). Upstream replaces mainland China's ranges with those from [gaoyifan/china-operator-ip](https://github.com/gaoyifan/china-operator-ip) and adds lists for services and CDNs: `CLOUDFLARE`, `CLOUDFRONT`, `FACEBOOK`, `FASTLY`, `GOOGLE`, `NETFLIX`, `TELEGRAM`, `TWITTER`, `TOR`, plus `PRIVATE` for local and reserved ranges.

Data only: no program, no command. Added for [`RealiTLScanner`](realitlscanner.md), which finds `Country.mmdb` here by itself, and useful for Xray and V2Ray (`geoip:` routing rules).

## Files

All nine files of the GitHub release, each with its hash from the release's `.sha256sum` file:

| File | Format | Contents |
|---|---|---|
| `Country.mmdb` | MaxMind | Every country; the service and CDN ranges carry their list name instead of a country (`1.1.1.1` → `CLOUDFLARE`, `8.8.8.8` → `GOOGLE`) |
| `Country-without-asn.mmdb` | MaxMind | Plain country codes only (`1.1.1.1` → `AU`, `8.8.8.8` → `US`) |
| `Country-only-cn-private.mmdb` | MaxMind | Only `CN` and `PRIVATE` |
| `Country-asn.mmdb` | MaxMind | Only the service and CDN lists |
| `geoip.dat` | V2Ray / Xray | Every country plus the service and CDN lists (`geoip:us`, `geoip:cloudflare`, ...) |
| `geoip-only-cn-private.dat` | V2Ray / Xray | Only `cn` and `private` |
| `geoip-asn.dat` | V2Ray / Xray | Only the service and CDN lists |
| `cn.dat`, `private.dat` | V2Ray / Xray | One list each, for `ext:cn.dat:cn` and `ext:private.dat:private` |

The examples are lookups in the 202611190019 release. The `.mmdb` files work with any reader of MaxMind's GeoIP2/GeoLite2 Country format (`database_type` is `GeoLite2-Country`). Upstream's `release` branch also has rule sets for sing-box, mihomo, Clash, Surge and nginx, and the unchanged GeoLite2 databases; they are not in the GitHub release and not in this package.

*Scoop Apps* gets a **Loyalsoldier GeoIP** shortcut. It opens `Loyalsoldier-GeoIP.cmd`, a micro-launcher written at install time that shows the release, the folder and what each file is for, and waits for a key.

## Updates

The version is upstream's release tag, the UTC date and time of the build (`202611190019` is 19 November 2026, 00:19). `checkver` reads the latest release; autoupdate takes every hash from `<file>.sha256sum` next to it, so Excavator moves the package to the new release within a few hours of upstream's Thursday build. Run `scoop update Loyalsoldier-GeoIP` to get it; with `scoop update *` it comes along with everything else.

## Using the files

- **RealiTLScanner:** nothing to do; the `realitlscanner` command copies `Country.mmdb` to a folder under `%TEMP%` and runs the scanner there (see [its page](realitlscanner.md#geoip)). `$env:GESU_GEOIP_MMDB = 'Country-without-asn.mmdb'` picks another file from this package.
- **Xray / V2Ray:** they read `geoip.dat` from their own folder or from the folder in `XRAY_LOCATION_ASSET` (`V2RAY_LOCATION_ASSET` for V2Ray). The package sets neither and copies nothing into another app: that folder must also hold `geosite.dat`, which this project does not build (it comes with Xray, or from [`Loyalsoldier-v2ray-rules-dat`](loyalsoldier-v2ray-rules-dat.md), whose `geoip.dat` is built by this project too and holds both). Copy `geoip.dat` (or the subsets for `ext:` rules) next to the other asset files, or point `XRAY_LOCATION_ASSET` at a folder that has both.
- **Anything else:** the folder is `~\scoop\apps\Loyalsoldier-GeoIP\current`, which always holds the installed release.

## Mirrors

Upstream also pushes every build to its [`release`](https://github.com/Loyalsoldier/geoip/tree/release) branch, which `raw.githubusercontent.com` and jsDelivr serve. Those links have no version: they always give the newest build, so they match the manifest's hashes only until the next Thursday build and Excavator's update after it. [`mirrors.psd1`](../../mirrors.psd1) lists the `raw.githubusercontent.com` copy (same files and hashes, checked for 202611190019). [`Use-Mirror.ps1`](../../bin/Use-Mirror.ps1) fetches one file per run, so for all nine: `0..8 | ForEach-Object { .\bin\Use-Mirror.ps1 gesu/Loyalsoldier-GeoIP raw -Index $_ }`, then `scoop install gesu/Loyalsoldier-GeoIP`. jsDelivr (`cdn.jsdelivr.net/gh/Loyalsoldier/geoip@release/`, or `fastly.jsdelivr.net`) is not listed yet: it could not be checked from where the package was written.

## License

Upstream licenses the data under [CC-BY-SA-4.0](https://github.com/Loyalsoldier/geoip/blob/HEAD/LICENSE) and its tool under [GPL-3.0](https://github.com/Loyalsoldier/geoip/blob/HEAD/LICENSE-GPL); the package installs only data, so the manifest names CC-BY-SA-4.0. The files include GeoLite2 data created by MaxMind, available from [maxmind.com](https://www.maxmind.com); MaxMind's own terms for GeoLite2 apply to that part.

## Conflicts

Not in Scoop's official buckets, and no bucket found on [scoop.sh](https://scoop.sh/) packages this project (November 2026). Several unofficial buckets have `v2ray-rules-dat`, a different Loyalsoldier project with `geoip.dat` and `geosite.dat`; some of those manifests put hardlinks into V2Ray's folder. This package writes nothing outside its own folder, so both can be installed side by side.

[All packages](../../README.md#packages)
