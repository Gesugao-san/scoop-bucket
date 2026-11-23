# runetfreedom-russia-v2ray-rules-dat

| | |
|---|---|
| Manifest | [`bucket/runetfreedom-russia-v2ray-rules-dat.json`](../../bucket/runetfreedom-russia-v2ray-rules-dat.json) |
| Upstream | [runetfreedom/russia-v2ray-rules-dat](https://github.com/runetfreedom/russia-v2ray-rules-dat) (GPL-3.0) |
| Install | `scoop install gesu/runetfreedom-russia-v2ray-rules-dat` |

`geoip.dat` and `geosite.dat` for Xray and V2Ray with the IP ranges and domains blocked in Russia, built from [antifilter.download](https://antifilter.download/), its community list and [re:filter](https://github.com/1andrevich/Re-filter-lists), plus the Russian mobile-internet whitelist. Upstream's README calls it the official source of the Russian geo files for v2rayN. Rebuilt by upstream's [workflow](https://github.com/runetfreedom/russia-v2ray-rules-dat/blob/HEAD/.github/workflows/build.yml) four times a day (03:30, 09:30, 15:30 and 21:30 UTC). [`3X-UI`](3x-ui.md) uses the files as `geoip_RU.dat` and `geosite_RU.dat`.

Data only: no program, no command.

## Files

The two `.dat` files of the GitHub release, each with its hash from the release's `.sha256sum` file (checked against the files on upstream's `release` branch for 202611230154):

| File | Size | Categories |
|---|---|---|
| `geoip.dat` | ~18 MB | `ru-blocked`, `ru-blocked-community`, `re-filter`, `ru-whitelist`, plus `cloudflare`, `cloudfront`, `facebook`, `fastly`, `google`, `netflix`, `telegram`, `twitter`, `ddos-guard`, `yandex` |
| `geosite.dat` | ~89 MB | All [v2fly](https://github.com/v2fly/domain-list-community) lists plus `ru-blocked`, `ru-blocked-all` (every known blocked domain, over 700 000; upstream advises care), `ru-available-only-inside`, `antifilter-download`, `antifilter-download-community`, `refilter`, `category-ads-all`, `win-spy`, `win-update`, `win-extra` |

The release also has `sing-box.zip` (rule sets for sing-box); it is not in this package.

*Scoop Apps* gets a **runetfreedom russia-v2ray-rules-dat** shortcut. It opens `runetfreedom-russia-v2ray-rules-dat.cmd`, a micro-launcher written at install time that shows the release, the folder and the main categories, and waits for a key.

## Using the files

- **3X-UI:** nothing to do once this package is installed; it copies both files into its `bin` folder as `geoip_RU.dat` and `geosite_RU.dat` each time it starts, so rules such as `ext:geosite_RU.dat:ru-blocked` route by them. Without this package 3X-UI uses the copies from its own release archive, which are as old as that release.
- **Xray / V2Ray:** point `XRAY_LOCATION_ASSET` at `%USERPROFILE%\scoop\apps\runetfreedom-russia-v2ray-rules-dat\current` and use `geosite:ru-blocked`, `geoip:ru-blocked` and so on.

## Updates

The version is upstream's release tag (UTC date and time of the build). `checkver` reads the latest release; autoupdate takes every hash from `<file>.sha256sum`. With four builds a day and Excavator checking every 4 hours, `scoop update *` downloads the 107 MB set up to four times a day. To update less often, hold the package and release it when you want new lists:

```powershell
scoop hold runetfreedom-russia-v2ray-rules-dat     # 'scoop update *' skips it
scoop unhold runetfreedom-russia-v2ray-rules-dat   # then 'scoop update runetfreedom-russia-v2ray-rules-dat'
```

## Mirrors

Upstream pushes every build to its [`release`](https://github.com/runetfreedom/russia-v2ray-rules-dat/tree/release) branch and links it as the download location. Those links always give the newest build, so they match the manifest's hashes only until the next build, a few hours at most. [`mirrors.psd1`](../../mirrors.psd1) lists the `raw.githubusercontent.com` copy: `0..1 | ForEach-Object { .\bin\Use-Mirror.ps1 gesu/runetfreedom-russia-v2ray-rules-dat raw -Index $_ }`.

## Conflicts

Not in Scoop's main or extras bucket. Data only, written to its own folder: nothing to conflict with.

[All packages](../../README.md#packages)
