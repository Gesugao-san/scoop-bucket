# Loyalsoldier-v2ray-rules-dat

| | |
|---|---|
| Manifest | [`bucket/Loyalsoldier-v2ray-rules-dat.json`](../../bucket/Loyalsoldier-v2ray-rules-dat.json) |
| Upstream | [Loyalsoldier/v2ray-rules-dat](https://github.com/Loyalsoldier/v2ray-rules-dat) (GPL-3.0; `geoip.dat` includes MaxMind GeoLite2 data) |
| Install | `scoop install gesu/Loyalsoldier-v2ray-rules-dat` |

Enhanced routing rules for Xray and V2Ray, rebuilt by upstream's [workflow](https://github.com/Loyalsoldier/v2ray-rules-dat/blob/HEAD/.github/workflows/run.yml) every day at 22:00 UTC. These are the default `geoip.dat` and `geosite.dat` of [`3X-UI`](3x-ui.md), which is why that package depends on this one.

Data only: no program, no command.

## Files

The two `.dat` files of the GitHub release, each with its hash from the release's `.sha256sum` file (checked against the files on upstream's `release` branch for 202611222203):

| File | Contents |
|---|---|
| `geoip.dat` | Every country plus `private`, `cloudflare`, `cloudfront`, `facebook`, `fastly`, `google`, `netflix`, `telegram`, `twitter`, `tor`. It is the `geoip.dat` of [Loyalsoldier/geoip](https://github.com/Loyalsoldier/geoip) (byte-identical to the one in [`Loyalsoldier-GeoIP`](loyalsoldier-geoip.md) of the same week) |
| `geosite.dat` | [v2fly/domain-list-community](https://github.com/v2fly/domain-list-community) plus `category-ads-all`, `cn` and `geolocation-!cn` with more domains, `gfw`, `china-list`, `apple-cn`, `google-cn`, `tld-cn`, `win-spy`, `win-update`, `win-extra` |

The release also has `rules.zip` and plain-text lists for Shadowrocket, Clash and the like; they are not in this package.

*Scoop Apps* gets a **Loyalsoldier v2ray-rules-dat** shortcut. It opens `Loyalsoldier-v2ray-rules-dat.cmd`, a micro-launcher written at install time that shows the release, the folder and the main categories, and waits for a key.

## Using the files

- **3X-UI:** nothing to do; it copies both files into its `bin` folder each time it starts.
- **Xray / V2Ray:** point `XRAY_LOCATION_ASSET` (`V2RAY_LOCATION_ASSET`) at `%USERPROFILE%\scoop\apps\Loyalsoldier-v2ray-rules-dat\current`, which always holds the installed release (see [`Xray-core`](xray-core.md#geo-files)).

## Updates

The version is upstream's release tag, the UTC date and time of the build (`202611222203` is 22 November 2026, 22:03). `checkver` reads the latest release; autoupdate takes every hash from `<file>.sha256sum`. Excavator follows within a few hours, so `scoop update *` brings a new set about once a day (some 28 MB).

## Mirrors

Upstream also pushes every build to its [`release`](https://github.com/Loyalsoldier/v2ray-rules-dat/tree/release) branch, which `raw.githubusercontent.com` and jsDelivr serve. Those links always give the newest build, so they match the manifest's hashes only until the next build. [`mirrors.psd1`](../../mirrors.psd1) lists the `raw.githubusercontent.com` copy: `0..1 | ForEach-Object { .\bin\Use-Mirror.ps1 gesu/Loyalsoldier-v2ray-rules-dat raw -Index $_ }`, then `scoop install gesu/Loyalsoldier-v2ray-rules-dat`. jsDelivr (`cdn.jsdelivr.net/gh/Loyalsoldier/v2ray-rules-dat@release/`) could not be checked from where the package was written.

## Conflicts

Not in Scoop's main or extras bucket. Several unofficial buckets have a `v2ray-rules-dat` manifest, some of which hard-link the files into V2Ray's folder; this package writes nothing outside its own folder, so both can be installed side by side.

[All packages](../../README.md#packages)
