# Icons

[`icons/`](../icons) holds package icons for UniGetUI's [icon database](https://github.com/Devolutions/UniGetUI/blob/main/WebBasedData/screenshot-database-v2.json):

| File | Size | Notes |
|---|---|---|
| [`nbt-studio-alt.svg`](../icons/nbt-studio-alt.svg) | vector | Redrawn icon in the spirit of the upstream one: same isometric blue book and palette, new artwork |
| [`nbt-studio-alt.png`](../icons/nbt-studio-alt.png) | 192×192 | PNG render of `nbt-studio-alt.svg`, used for UniGetUI |
| [`nbt-studio-256.png`](../icons/nbt-studio-256.png) | 256×256 | Upstream icon, unchanged copy of [`nbt_studio_icon_256.png`](https://github.com/tryashtar/nbt-studio/blob/master/NbtStudio/Resources/nbt_studio_icon_256.png) |
| [`nbt-studio-192.png`](../icons/nbt-studio-192.png) | 192×192 | Upstream [16×16 pixel art](https://github.com/tryashtar/nbt-studio/blob/master/NbtStudio/Resources/nbt_studio_icon_16.png) scaled ×12 with nearest neighbour, so it stays crisp in UniGetUI |
| [`iloader-192.png`](../icons/iloader-192.png) | 192×192 | Upstream icon, [`icon.png`](https://github.com/nab138/iloader/blob/902597564315442f00ab299dcc758ee0e13b8fa8/src-tauri/icons/icon.png) scaled down from 512×512. iloader's branding is not MIT: its [branding notice](https://github.com/nab138/iloader/blob/902597564315442f00ab299dcc758ee0e13b8fa8/LICENSE-BRANDING) allows use with a link to [iloader.app](https://iloader.app) and without implying endorsement. This bucket is not affiliated with iloader. |
| [`impactor-192.png`](../icons/impactor-192.png) | 192×192 | Upstream icon, [`dev.khcrysalis.PlumeImpactor.png`](https://github.com/claration/impactor/blob/2ba32ea43246bd4db0265eb3120d3c72e39f5b22/package/linux/icons/hicolor/512x512/apps/dev.khcrysalis.PlumeImpactor.png) scaled down from 512×512 with Lanczos (by Paige, part of Impactor, MIT). |
| [`freesm-launcher-192.png`](../icons/freesm-launcher-192.png) | 192×192 | Upstream logo, [`org.freesmlauncher.FreesmLauncher.svg`](https://github.com/FreesmTeam/FreesmLauncher/blob/660a9e4c64daeb414a3db8f17c046dc2552e28af/program_info/org.freesmlauncher.FreesmLauncher.svg) rendered at 192×192. Licensed [CC BY-SA 4.0](https://github.com/FreesmTeam/FreesmLauncher/blob/660a9e4c64daeb414a3db8f17c046dc2552e28af/program_info/LICENSE) by the Freesm Launcher authors; this render is under the same license. |
| [`apple-mobile-drivers-installer-alt.svg`](../icons/apple-mobile-drivers-installer-alt.svg) | vector | Original icon (upstream has none): a phone with a download arrow and a USB cable. No Apple logo or other trademark. |
| [`apple-mobile-drivers-installer-alt.png`](../icons/apple-mobile-drivers-installer-alt.png) | 192×192 | PNG render of `apple-mobile-drivers-installer-alt.svg`, used for UniGetUI |
| [`radmin-vpn-192.png`](../icons/radmin-vpn-192.png) | 192×192 | Upstream icon: the 256×256 frame of `ProductIcon` from the Radmin VPN 2.1.4951.1 installer's MSI, scaled down. Trademark of Famatech Corp. |
| [`jkdefrag-192.png`](../icons/jkdefrag-192.png) | 192×192 | Upstream icon: the 64×64 frame of `JkDefrag.ico` from the JkDefrag 3.36 sources (GPL v2 or later), scaled up with Lanczos. |
| [`jeveassets-192.png`](../icons/jeveassets-192.png) | 192×192 | Upstream icon: `misc_assets_64.png` from `jeveassets.jar` 8.2.2, the window icon of the app, scaled up with Lanczos. Part of jEveAssets (GPL v2 or later); the credits name no other source for it. |
| [`evemon-192.png`](../icons/evemon-192.png) | 192×192 | Upstream icon: the 128×128 frame of [`EVEMon.ico`](https://github.com/mgoeppner/evemon/blob/HEAD/src/EVEMon.Common/Resources/Icons/EVEMon.ico), scaled up with Lanczos (GPL v2). |
| [`eve-iph-192.png`](../icons/eve-iph-192.png) | 192×192 | Upstream [16×16 icon](https://github.com/EVEIPH/EVE-IPH/blob/HEAD/icon07_02.ico), the only size it has, scaled ×12 with nearest neighbour |
| [`borderless-gaming-192.png`](../icons/borderless-gaming-192.png) | 192×192 | Upstream icon: the 64×64 frame of [`BorderlessGaming_new.ico`](https://github.com/andrewmd5/Borderless-Gaming/blob/9.6.0/BorderlessGaming_new.ico) (part of Borderless Gaming, GPL-2.0), scaled up with Lanczos. The square dark tile is part of the design, so it has no transparent background. UniGetUI already has an icon under `borderlessgaming` (Chocolatey's ID), but this package's ID is `borderless-gaming`. |
| [`borderless-gaming-alt.svg`](../icons/borderless-gaming-alt.svg) | vector | Redrawn icon in the spirit of the upstream one: same "BG" between four corner brackets and the same palette, new artwork. The letters are outlines of [Carlito](https://github.com/googlefonts/carlito) Bold (SIL OFL 1.1; a free font metrically compatible with Calibri, which the upstream icon appears to use), thickened slightly to match the upstream weight and stored as paths, so the SVG needs no font. Written by [`scripts/borderless-gaming/make_icon.py`](../scripts/borderless-gaming/make_icon.py) |
| [`borderless-gaming-alt.png`](../icons/borderless-gaming-alt.png) | 192×192 | PNG render of `borderless-gaming-alt.svg` (same script, rsvg-convert), used for UniGetUI: sharper than the upscaled 64×64 original |
| [`realitlscanner.svg`](../icons/realitlscanner.svg) | vector | No icon upstream, so the logo of its authors: the Project X star from [`logo-light.svg`](https://github.com/XTLS/Xray-docs-next/blob/HEAD/docs/public/logo-light.svg) in XTLS/Xray-docs-next (CC-BY-SA-4.0), polygons unchanged. Adapted: an outline in `#dfdfd6` (the colour of the same repository's `logo-dark.svg`) so one icon works on light and dark themes; the adaptation is under the same license. Written by [`scripts/realitlscanner/make_icon.py`](../scripts/realitlscanner/make_icon.py) |
| [`realitlscanner-192.png`](../icons/realitlscanner-192.png) | 192×192 | PNG render of `realitlscanner.svg` (same script, rsvg-convert), used for UniGetUI |
| [`realitlscanner-gui-192.png`](../icons/realitlscanner-gui-192.png) | 192×192 | Upstream icon, [`icon.png`](https://github.com/EikeiDev/RealiTLScanner-GUI/blob/5210aec165bfad2042bc60ae46e899469fa4a3c7/icon.png) (640×640, the window icon of the GUI; MPL-2.0 per its README): the light grey background around the rounded tile replaced with transparency by a rounded-rectangle mask, cropped to the tile and scaled down with Lanczos |
| [`halloy-192.png`](../icons/halloy-192.png) | 192×192 | Upstream logo, [`logo.png`](https://github.com/squidowl/halloy/blob/2026.10/assets/logo.png) (882×882, icon by Rune Seir per upstream's README; part of Halloy, GPL-3.0), scaled down with Lanczos |
| [`loyalsoldier-geoip-alt.svg`](../icons/loyalsoldier-geoip-alt.svg) | vector | Original icon (upstream has no logo; the tile in its README banner is too small to use): a gridded globe with a map pin on two stacked data layers. Written by [`scripts/loyalsoldier-geoip/make_icon.py`](../scripts/loyalsoldier-geoip/make_icon.py) |
| [`loyalsoldier-geoip-alt.png`](../icons/loyalsoldier-geoip-alt.png) | 192×192 | PNG render of `loyalsoldier-geoip-alt.svg`, used for UniGetUI |
| [`ckan-192.png`](../icons/ckan-192.png) | 192×192 | Upstream logo, [`ckan-256.png`](https://github.com/KSP-CKAN/CKAN/blob/975c4d7799ecaf2fb74ef5b1bbe6a182da3984d5/assets/ckan-256.png) (one of the PNGs that CKAN's `ckan.ico` is built from), scaled down with Lanczos. Per upstream's [`assets/README.md`](https://github.com/KSP-CKAN/CKAN/blob/975c4d7799ecaf2fb74ef5b1bbe6a182da3984d5/assets/README.md), the CKAN logo is MIT licensed by Felger, and the KSP rocket in it is used with permission from Squad. Used for both `ckan` and `ckan-netfx`. UniGetUI already has an icon under `ksp-ckan` (Chocolatey's ID), not under these IDs. |

File names: `<package>[-<variant>][-<size>].<ext>`. Upstream-based icons carry their size; `alt` is the redrawn one.

Icons already in UniGetUI's database, so nothing is hosted here for them: `nbt-explorer`, `privoxy`, `nettime`, `samsung-magician`, `ghidra`, `x64dbg`, `dnspyex`, `bulk-crap-uninstaller`, `ultradefrag` and `victoria`.

## Icon size in UniGetUI

Checked against UniGetUI's source at commit [`b852884`](https://github.com/Devolutions/UniGetUI/tree/b85288414fea52a1283a67599da5558d4818d606):

- **Pixel size: 192 × 192 at most in practice.** After download, [`DownsizeImage`](https://github.com/Devolutions/UniGetUI/blob/b85288414fea52a1283a67599da5558d4818d606/src/UniGetUI.Core.IconStore/IconCacheEngine.cs#L318) shrinks any PNG, WebP, TIFF or AVIF icon whose side exceeds [`MAX_SIDE = 192`](https://github.com/Devolutions/UniGetUI/blob/b85288414fea52a1283a67599da5558d4818d606/src/UniGetUI.Core.IconStore/IconCacheEngine.cs#L322), keeping the aspect ratio. A non-integer downscale blurs pixel art, which is why the 192 px versions here exist: 192 = 16 × 12.
- **File size: no limit in the code.** Icons are fetched with a plain [`HttpClient`](https://github.com/Devolutions/UniGetUI/blob/b85288414fea52a1283a67599da5558d4818d606/src/UniGetUI.Core.IconStore/IconCacheEngine.cs#L236) using .NET defaults: a [100 s timeout](https://learn.microsoft.com/dotnet/api/system.net.http.httpclient.timeout) and the whole body read into memory. Keep icons small anyway; they are re-downloaded whenever the cache is cleared.
- **Formats** are chosen by the server's `Content-Type` ([mapping](https://github.com/Devolutions/UniGetUI/blob/b85288414fea52a1283a67599da5558d4818d606/src/UniGetUI.Core.IconStore/IconCacheEngine.cs#L464)): PNG, WebP, AVIF, GIF, SVG, ICO, TIFF. JPEG and BMP are commented out as non-transparent, so such icons are not loaded at all.
- **Shape:** the [contribution guide](https://www.marticliment.com/unigetui/help/icons-and-screenshots) asks for a square PNG.
- **Lookup key:** [`GenerateIconId`](https://github.com/Devolutions/UniGetUI/blob/b85288414fea52a1283a67599da5558d4818d606/src/UniGetUI.PackageEngine.PackageManagerClasses/Packages/Package.cs#L451) lower-cases the package ID and turns `_ . space / ,` into dashes, so the icon is found under `nbt-studio` whatever the case of the manifest name.
- **Adding an icon:** the old Google Sheet is closed; icons now go in through pull requests to [`screenshot-database-v2.json`](https://github.com/Devolutions/UniGetUI/blob/main/WebBasedData/screenshot-database-v2.json) (see the [file's history](https://github.com/Devolutions/UniGetUI/commits/main/WebBasedData/screenshot-database-v2.json) for examples).

## Screenshots

[`screenshots/`](../screenshots) holds screenshots for UniGetUI's package details page (the `images` list in the [icon database](https://github.com/Devolutions/UniGetUI/blob/main/WebBasedData/screenshot-database-v2.json)). Taken by Gesugao-san on Windows 11, NBT Studio v1.15.3, a sample world:

| File | Shows |
|---|---|
| [`nbt-studio-1.png`](../screenshots/nbt-studio-1.png) | `level.dat` tag tree |
| [`nbt-studio-2.png`](../screenshots/nbt-studio-2.png) | Find dialog |
| [`nbt-studio-3.png`](../screenshots/nbt-studio-3.png) | Edit menu: Edit Value, Edit as SNBT, undo history |
| [`nbt-studio-4.png`](../screenshots/nbt-studio-4.png) | File menu: new region file, import from clipboard |
| [`nbt-studio-5.png`](../screenshots/nbt-studio-5.png) | Icon set picker |
| [`nbt-studio-6.png`](../screenshots/nbt-studio-6.png) | About and update check dialogs |

Icons belong to their respective authors.
