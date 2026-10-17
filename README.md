# scoop-bucket

Personal [Scoop](https://scoop.sh) bucket by [Gesugao-san](https://github.com/Gesugao-san).

## Usage

```powershell
scoop bucket add gesugao https://github.com/Gesugao-san/scoop-bucket
scoop install gesugao/NBT-Studio
```

Works in [UniGetUI](https://github.com/Devolutions/UniGetUI) too: add the bucket in UniGetUI's Scoop settings (or with the command above), then search for the package.

## Packages

| Package | Upstream | Notes |
|---|---|---|
| [`NBT-Studio`](bucket/NBT-Studio.json) | [tryashtar/nbt-studio](https://github.com/tryashtar/nbt-studio) | Needs the [.NET 6 Desktop Runtime](https://dotnet.microsoft.com/download/dotnet/6.0) x64 (`winget install Microsoft.DotNet.DesktopRuntime.6`). Upstream has no [releases](https://github.com/tryashtar/nbt-studio/releases) since v1.15.3. File associations: [see below](#file-associations). |

Manifest names keep the product's capitalisation: UniGetUI builds the display name from the file name with [`FormatAsName`](https://github.com/Devolutions/UniGetUI/blob/b85288414fea52a1283a67599da5558d4818d606/src/UniGetUI.Core.Tools/Tools.cs#L320), which turns dashes into spaces and only upper-cases the first letter of each word (`NBT-Studio` → "NBT Studio", but `nbt-studio` → "Nbt Studio"). Scoop itself is case-insensitive, so `nbt-studio` works in commands too. Folders under `scripts/` are lowercase; they do not affect the display name.

## File associations

Like the [`git` manifest](https://github.com/ScoopInstaller/Main/blob/bcff7c46a4ad0a7765b9f61260ab75440a3e69ea/bucket/git.json) in Scoop's [Main bucket](https://github.com/ScoopInstaller/Main), `NBT-Studio` ships [registry templates](scripts/nbt-studio) instead of touching the registry on its own. `post_install` fills in the install path; after install, run:

```cmd
reg import "%USERPROFILE%\scoop\apps\NBT-Studio\current\install-associations.reg"
```

This makes NBT Studio the default app for `.nbt` and adds it to "Open with" for `.snbt`, `.dat`, `.dat_old`, `.mca`, `.mcr`, `.mcc`, `.mcstructure` and `.schematic` without changing their defaults. Paths point to `current`, so they survive updates. `scoop uninstall` imports [`uninstall-associations.reg`](scripts/nbt-studio/uninstall-associations.reg) and removes the entries.

## Icons

[`icons/`](icons) holds package icons for UniGetUI's [icon database](https://github.com/Devolutions/UniGetUI/blob/main/WebBasedData/screenshot-database-v2.json):

| File | Size | Notes |
|---|---|---|
| [`nbt-studio-alt.svg`](icons/nbt-studio-alt.svg) | vector | Redrawn icon in the spirit of the upstream one: same isometric blue book and palette, new artwork |
| [`nbt-studio-alt.png`](icons/nbt-studio-alt.png) | 192×192 | PNG render of `nbt-studio-alt.svg`, used for UniGetUI |
| [`nbt-studio-256.png`](icons/nbt-studio-256.png) | 256×256 | Upstream icon, unchanged copy of [`nbt_studio_icon_256.png`](https://github.com/tryashtar/nbt-studio/blob/master/NbtStudio/Resources/nbt_studio_icon_256.png) |
| [`nbt-studio-192.png`](icons/nbt-studio-192.png) | 192×192 | Upstream [16×16 pixel art](https://github.com/tryashtar/nbt-studio/blob/master/NbtStudio/Resources/nbt_studio_icon_16.png) scaled ×12 with nearest neighbour, so it stays crisp in UniGetUI |

File names: `<package>[-<variant>][-<size>].<ext>`. Upstream-based icons carry their size; `alt` is the redrawn one.

### Icon size in UniGetUI

Checked against UniGetUI's source at commit [`b852884`](https://github.com/Devolutions/UniGetUI/tree/b85288414fea52a1283a67599da5558d4818d606):

- **Pixel size: 192 × 192 at most in practice.** After download, [`DownsizeImage`](https://github.com/Devolutions/UniGetUI/blob/b85288414fea52a1283a67599da5558d4818d606/src/UniGetUI.Core.IconStore/IconCacheEngine.cs#L318) shrinks any PNG, WebP, TIFF or AVIF icon whose side exceeds [`MAX_SIDE = 192`](https://github.com/Devolutions/UniGetUI/blob/b85288414fea52a1283a67599da5558d4818d606/src/UniGetUI.Core.IconStore/IconCacheEngine.cs#L322), keeping the aspect ratio. A non-integer downscale blurs pixel art, which is why the 192 px versions here exist: 192 = 16 × 12.
- **File size: no limit in the code.** Icons are fetched with a plain [`HttpClient`](https://github.com/Devolutions/UniGetUI/blob/b85288414fea52a1283a67599da5558d4818d606/src/UniGetUI.Core.IconStore/IconCacheEngine.cs#L236) using .NET defaults: a [100 s timeout](https://learn.microsoft.com/dotnet/api/system.net.http.httpclient.timeout) and the whole body read into memory. Keep icons small anyway; they are re-downloaded whenever the cache is cleared.
- **Formats** are chosen by the server's `Content-Type` ([mapping](https://github.com/Devolutions/UniGetUI/blob/b85288414fea52a1283a67599da5558d4818d606/src/UniGetUI.Core.IconStore/IconCacheEngine.cs#L464)): PNG, WebP, AVIF, GIF, SVG, ICO, TIFF. JPEG and BMP are commented out as non-transparent, so such icons are not loaded at all.
- **Shape:** the [contribution guide](https://www.marticliment.com/unigetui/help/icons-and-screenshots) asks for a square PNG.
- **Lookup key:** [`GenerateIconId`](https://github.com/Devolutions/UniGetUI/blob/b85288414fea52a1283a67599da5558d4818d606/src/UniGetUI.PackageEngine.PackageManagerClasses/Packages/Package.cs#L451) lower-cases the package ID and turns `_ . space / ,` into dashes, so the icon is found under `nbt-studio` whatever the case of the manifest name.
- **Adding an icon:** the old Google Sheet is closed; icons now go in through pull requests to [`screenshot-database-v2.json`](https://github.com/Devolutions/UniGetUI/blob/main/WebBasedData/screenshot-database-v2.json) (see the [file's history](https://github.com/Devolutions/UniGetUI/commits/main/WebBasedData/screenshot-database-v2.json) for examples).

Icons belong to their respective authors.

Manifests only point to upstream release files; nothing else is redistributed here.
