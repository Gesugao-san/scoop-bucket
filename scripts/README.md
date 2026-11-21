# scripts

Files that manifests use at install, update or uninstall time, and helpers for the workflows. One folder per package, plus `common/` for helpers shared by several packages.

| Folder | Used by |
|---|---|
| [`common/`](common) | Several packages: `Test-AppBusy.ps1` (stops when the program is running or its files are open), `New-IconFromArchive.ps1` (builds a shortcut `.ico` from PNG images inside a zip or jar) |
| [`apple-mobile-device-support/`](apple-mobile-device-support) | `Apple-Mobile-Device-Support`: installs AMDS from the iTunes installer and finds new releases |
| [`borderless-gaming/`](borderless-gaming) | `Borderless-Gaming`: `make_icon.py` draws the redrawn [icon](../docs/icons.md) for UniGetUI and renders its PNG |
| [`eve-iph/`](eve-iph) | `EVE-IPH`: checks new upstream builds, see [Checking EVE-IPH builds](../docs/automation.md#checking-eve-iph-builds) |
| [`gale/`](gale) | `Gale`: registry templates for the `.r2z` [file association](../docs/conventions.md#file-associations) |
| [`nbt-studio/`](nbt-studio) | `NBT-Studio`: registry templates for [file associations](../docs/conventions.md#file-associations) |
| [`planetside-2/`](planetside-2) | `PlanetSide-2`: the `PlanetSide-2` command, which starts the game through Steam |
| [`realitlscanner/`](realitlscanner) | `RealiTLScanner`: the `realitlscanner` command, which runs the scanner with the [GeoIP database](../docs/packages/realitlscanner.md#geoip) from `Loyalsoldier-GeoIP`, and `realitlscanner-scan`, which scans one range once into the persisted `results` folder |

[Back to the main README](../README.md)
