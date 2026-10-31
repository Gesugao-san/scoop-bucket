# scoop-bucket

[![CI](https://github.com/Gesugao-san/scoop-bucket/actions/workflows/ci.yml/badge.svg)](https://github.com/Gesugao-san/scoop-bucket/actions/workflows/ci.yml) [![Excavator](https://github.com/Gesugao-san/scoop-bucket/actions/workflows/excavator.yml/badge.svg)](https://github.com/Gesugao-san/scoop-bucket/actions/workflows/excavator.yml)

Personal [Scoop](https://scoop.sh) bucket by [Gesugao-san](https://github.com/Gesugao-san).

## Usage

```powershell
scoop bucket add gesu https://github.com/Gesugao-san/scoop-bucket
scoop install gesu/NBT-Studio
scoop install gesu/NBT-Explorer
scoop install gesu/iloader
scoop install gesu/Apple-Mobile-Drivers-Installer
scoop install gesu/Privoxy
scoop install -g gesu/NetTime   # global, from an elevated shell
scoop install gesu/Freesm-Launcher
scoop install gesu/Radmin-VPN
scoop install gesu/Samsung-Magician
```

`gesu` is only a local name for the bucket; any other name works too.

Works in [UniGetUI](https://github.com/Devolutions/UniGetUI) too: add the bucket in UniGetUI's Scoop settings (or with the command above), then search for the package.

## Packages

| Package | Upstream | Notes |
|---|---|---|
| [`NBT-Studio`](bucket/NBT-Studio.json) | [tryashtar/nbt-studio](https://github.com/tryashtar/nbt-studio) | Needs the [.NET 6 Desktop Runtime](https://dotnet.microsoft.com/download/dotnet/6.0) x64: the manifest [suggests](https://github.com/ScoopInstaller/Scoop/wiki/App-Manifests#optional-properties) `versions/windowsdesktop-runtime-6.0` from Scoop's [Versions](https://github.com/ScoopInstaller/Versions) bucket (needs admin), or use `winget install Microsoft.DotNet.DesktopRuntime.6`. Upstream has no [releases](https://github.com/tryashtar/nbt-studio/releases) since v1.15.3. File associations: [see below](#file-associations). |
| [`NBT-Explorer`](bucket/NBT-Explorer.json) | [jaquadro/NBTExplorer](https://github.com/jaquadro/NBTExplorer) | Runs on the .NET Framework 4 that ships with Windows. The bundled command-line `NBTUtil` needs .NET Framework 3.5: Windows offers to download it on first run, or enable it with `DISM /Online /Enable-Feature /FeatureName:NetFx3 /All` (admin). Also available in the [games](https://github.com/Calinou/scoop-games) bucket as `nbtexplorer`. |
| [`iloader`](bucket/iloader.json) | [nab138/iloader](https://github.com/nab138/iloader) | Installs SideStore, LiveContainer or any IPA on an iPhone/iPad. Needs Apple's usbmuxd from iTunes or the Apple Devices app (`winget install 9NP83LWLPZ9K`). Portable: the binary is unpacked from the upstream NSIS installer. Decline the in-app update, it would install a second copy outside Scoop; use `scoop update iloader`. Upstream warns that only its GitHub releases and [iloader.app](https://iloader.app) are official sources. |
| [`Apple-Mobile-Drivers-Installer`](bucket/Apple-Mobile-Drivers-Installer.json) | [NelloKudo/Apple-Mobile-Drivers-Installer](https://github.com/NelloKudo/Apple-Mobile-Drivers-Installer) | Installs only the script; run `AppleDrivInstaller` from an elevated PowerShell to install the drivers. It downloads iTunes from apple.com for Apple Mobile Device Support and the USB and tethering drivers from the [Microsoft Update Catalog](https://www.catalog.update.microsoft.com/), then installs them with `pnputil`. Needed when Windows only sees the device as a media/MTP device, e.g. for `iloader`: the iTunes 12.13.11.1 installer (Apple Mobile Device Support 20.0.0.35) contains no USB driver (`usbaapl64.inf`). Upstream has no releases, so the version is the date of the script's last commit and the URL is pinned to that commit. `scoop uninstall` removes the script, not the drivers. |
| [`Privoxy`](bucket/Privoxy.json) | [privoxy.org](https://www.privoxy.org) ([SourceForge](https://sourceforge.net/projects/ijbswa/files/Win32/)) | Filtering proxy on `127.0.0.1:8118`. Portable: unpacked from the upstream NSIS installer, without the Windows service. `config.txt`, `trust.txt`, `user.action` and `user.filter` are persisted. Windows builds lag behind: 4.2.0 is out for other systems, but the newest Windows build is 4.1.0. The [Extras](https://github.com/ScoopInstaller/Extras) bucket also has `privoxy`, stuck at 4.0.0: its autoupdate expects a `<version> (stable)` folder on SourceForge, and the 4.1.0 folder has no such suffix. This manifest reads the folder name in `checkver`, so either naming works. |
| [`NetTime`](bucket/NetTime.json) | [timesynctool.com](https://www.timesynctool.com) ([SourceForge](https://sourceforge.net/projects/nettime/)) | SNTP client that runs as the Windows service `NetTimeSvc` (as SYSTEM). **Global install only** (`scoop install -g`, elevated shell): a SYSTEM service must not run files that a non-admin program could replace, so the manifest refuses a per-user install. `post_install` also restricts the app folder to Administrators and SYSTEM (`icacls`, by SID so it works on localized Windows); new version folders inherit that. Updates and uninstall need admin too. Before `scoop update -g NetTime`, run `Stop-Service NetTimeSvc`: Scoop refuses to update an app with a running process and checks that before any manifest script runs ([#2952](https://github.com/ScoopInstaller/Scoop/issues/2952)); `scoop uninstall` stops the service by itself in `pre_uninstall`. Portable: the files are unpacked from the upstream Inno Setup installer, and `post_install` creates the service pointing to `current`, so it survives updates. Updates only stop the service; `scoop uninstall` also deletes it. Settings stay in `HKLM\Software\Wow6432Node\Subjective Software\NetTime`. Refuses to install if `NetTimeSvc` already exists from the regular installer. Tracks the stable version (3.14); the 3.20 alphas are not packaged. License: a short custom attribution notice, not BSD despite what some catalogs say; see [`licenses/NetTime.txt`](licenses/NetTime.txt). |
| [`Freesm-Launcher`](bucket/Freesm-Launcher.json) | [FreesmTeam/FreesmLauncher](https://github.com/FreesmTeam/FreesmLauncher) | Prism Launcher fork. Portable build (MSVC, x64 and arm64), modelled on the [games](https://github.com/Calinou/scoop-games) bucket's `prismlauncher`: data folders are persisted, and `accounts.json`, `metacache` and `freesmlauncher.cfg` are copied in and out because the launcher replaces them instead of writing into them. Data from an installed copy in `%APPDATA%\FreesmLauncher` is copied on the first install. The built-in updater is removed; use `scoop update`. Suggests `extras/vcredist2022`. |
| [`Radmin-VPN`](bucket/Radmin-VPN.json) | [radmin-vpn.com](https://www.radmin-vpn.com) (Famatech, freeware) | **Not portable**: runs the official installer silently (Inno Setup wrapping an MSI), which adds a network adapter driver and a service, like the `-np` packages in Scoop's [Nonportable](https://github.com/ScoopInstaller/Nonportable) bucket. Install, update and uninstall from an elevated shell. Updates install over the existing copy, so networks and settings are kept; `scoop uninstall` removes it through its MSI entry. Hash checked against [winget](https://github.com/microsoft/winget-pkgs/tree/master/manifests/f/Famatech/RadminVPN). The Inno Setup wrapper holds a WiX MSI (`Radmin VPN 2.1.1`, product code `{5560C73C-AE48-49C9-842C-8341D592F231}`); the network driver is signed by Microsoft's Windows Hardware Compatibility Publisher, so it installs without a trust prompt. The installer also adds Radmin Viewer 3, a desktop shortcut and a logon autostart. |
| [`Samsung-Magician`](bucket/Samsung-Magician.json) | [Samsung Semiconductor](https://semiconductor.samsung.com/consumer-storage/magician/) (freeware) | **Not portable and not silent**: Samsung's Inno Setup script refuses silent mode ("Samsung Magician cannot be installed in silent mode") and asks whether you live in a GDPR country or Brazil, so Scoop opens the setup wizard for you to finish. This manifest does not try to get around that: the answer is a privacy consent that belongs to the user. Adds the `SamsungMagicianSVC` service, the `magdrv` kernel driver, a logon scheduled task and possibly a power plan. Install, update and uninstall from an elevated shell; uninstall runs Magician's own uninstaller silently. Samsung's global [tools page](https://semiconductor.samsung.com/consumer-storage/support/tools/) lags behind (still 9.0.1.950 in October 2026), so `checkver` reads the download list embedded as JSON in a model support page ([9100 PRO 8 TB, UK](https://www.samsung.com/uk/support/model/MZ-VAP8T0BW/), the newest consumer model as of 2026) and builds the `downloadcenter.samsung.com/content/...` URL from its `filePath`, like [winget-extras](https://github.com/pl4nty/winget-extras/tree/main/manifests/s/Samsung/Magician) does. If Samsung drops Magician from that page, point `checkver` at another current SSD model. |

Non-portable packages (`NetTime`, `Radmin-VPN`, `Samsung-Magician`) check before installing whether the program is already installed on the system without Scoop, and stop instead of silently taking it over (a later `scoop uninstall` would remove that copy too). `scoop update` is not affected. For `Radmin-VPN` and `Samsung-Magician`, whose installers can install over an existing copy, run `$env:GESU_ALLOW_EXISTING = '1'` in the same shell to let Scoop take over; the variable stays set until you close the shell or run `Remove-Item Env:GESU_ALLOW_EXISTING`. `NetTime` has no such override: its regular installer registers its own `NetTimeSvc`, which a Scoop copy cannot share.

Manifest names keep the product's capitalisation: UniGetUI builds the display name from the file name with [`FormatAsName`](https://github.com/Devolutions/UniGetUI/blob/b85288414fea52a1283a67599da5558d4818d606/src/UniGetUI.Core.Tools/Tools.cs#L320), which turns dashes into spaces and only upper-cases the first letter of each word (`NBT-Studio` → "NBT Studio", but `nbt-studio` → "Nbt Studio"). Scoop itself is case-insensitive, so `nbt-studio` works in commands too. Folders under `scripts/` are lowercase; they do not affect the display name.

## Automation

GitHub Actions from Scoop's [BucketTemplate](https://github.com/ScoopInstaller/BucketTemplate), using [ScoopInstaller/GithubActions](https://github.com/ScoopInstaller/GithubActions):

| Workflow | Runs | Does |
|---|---|---|
| [`excavator.yml`](.github/workflows/excavator.yml) | every 4 hours, or by hand ([see below](#running-workflows-by-hand)) | Runs `checkver` with autoupdate on every manifest and pushes new versions with their hashes straight to `main`, as `github-actions[bot]` |
| [`ci.yml`](.github/workflows/ci.yml) | every push and PR | Scoop's Pester tests in Windows PowerShell and PowerShell 7: manifest schema and file style |
| [`issues.yml`](.github/workflows/issues.yml) | new issues | Checks reports such as `app@1.2.3: hash check failed` and fixes the hash if it really changed |
| [`pull_request.yml`](.github/workflows/pull_request.yml) | new PRs, `/verify` comments | Checks the changed manifests and posts the results |

Notes:

- The tests run on `bucket/` only ([`Scoop-Bucket.Tests.ps1`](Scoop-Bucket.Tests.ps1)): Scoop's style tests read every file as text and would fail on the PNGs in `icons/` and `screenshots/`.
- Manifests use Scoop's own format (4-space JSON) because Excavator rewrites a manifest with Scoop's formatter whenever it updates it. Run `.\bin\formatjson.ps1` after editing by hand.
- `.gitattributes` gives text files CRLF in working copies, which the tests require; the repository itself stores LF.
- GitHub turns off scheduled workflows in public repositories after 60 days without activity; re-enable Excavator on the Actions tab if that happens.
- [`bin/`](bin) holds the usual helper wrappers (`checkver.ps1`, `checkurls.ps1`, `checkhashes.ps1`, `formatjson.ps1`, `missing-checkver.ps1`, `auto-pr.ps1`, `test.ps1`) for running Scoop's maintainer scripts against this bucket locally.

### Running workflows by hand

Excavator and CI can be started from the [Actions tab](https://github.com/Gesugao-san/scoop-bucket/actions) (pick the workflow, then **Run workflow**) or with the [GitHub CLI](https://cli.github.com/):

```powershell
gh workflow run excavator.yml -R Gesugao-san/scoop-bucket
gh workflow run excavator.yml -R Gesugao-san/scoop-bucket -f force=NetTime,Privoxy
gh workflow run ci.yml -R Gesugao-san/scoop-bucket
gh run watch -R Gesugao-san/scoop-bucket
```

`force` lists manifests that Excavator re-downloads and re-hashes even when the version is unchanged, for when upstream replaces a file without a new version number. The issue and PR handlers have no manual run: they need the issue or PR that triggered them.

## Licenses

Manifests give the license as an [SPDX](https://spdx.org/licenses/) identifier with a link to the license text, which UniGetUI shows next to the name. Links to GitHub use `blob/HEAD/`, so they follow the upstream default branch even if it is renamed. `NBT-Studio` stays `Unknown`: upstream has no license file.

[`licenses/`](licenses) holds license texts that upstream does not publish as a file of its own, copied verbatim with their source:

| File | Notes |
|---|---|
| [`NetTime.txt`](licenses/NetTime.txt) | Notice from the header of NetTime's source files (`NetTimeSource-314.zip` from SourceForge). It matches no SPDX license, so the manifest uses the custom identifier `LicenseRef-NetTime`. |

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
| [`iloader-192.png`](icons/iloader-192.png) | 192×192 | Upstream icon, [`icon.png`](https://github.com/nab138/iloader/blob/902597564315442f00ab299dcc758ee0e13b8fa8/src-tauri/icons/icon.png) scaled down from 512×512. iloader's branding is not MIT: its [branding notice](https://github.com/nab138/iloader/blob/902597564315442f00ab299dcc758ee0e13b8fa8/LICENSE-BRANDING) allows use with a link to [iloader.app](https://iloader.app) and without implying endorsement. This bucket is not affiliated with iloader. |
| [`freesm-launcher-192.png`](icons/freesm-launcher-192.png) | 192×192 | Upstream logo, [`org.freesmlauncher.FreesmLauncher.svg`](https://github.com/FreesmTeam/FreesmLauncher/blob/660a9e4c64daeb414a3db8f17c046dc2552e28af/program_info/org.freesmlauncher.FreesmLauncher.svg) rendered at 192×192. Licensed [CC BY-SA 4.0](https://github.com/FreesmTeam/FreesmLauncher/blob/660a9e4c64daeb414a3db8f17c046dc2552e28af/program_info/LICENSE) by the Freesm Launcher authors; this render is under the same license. |
| [`apple-mobile-drivers-installer-alt.svg`](icons/apple-mobile-drivers-installer-alt.svg) | vector | Original icon (upstream has none): a phone with a download arrow and a USB cable. No Apple logo or other trademark. |
| [`apple-mobile-drivers-installer-alt.png`](icons/apple-mobile-drivers-installer-alt.png) | 192×192 | PNG render of `apple-mobile-drivers-installer-alt.svg`, used for UniGetUI |
| [`radmin-vpn-192.png`](icons/radmin-vpn-192.png) | 192×192 | Upstream icon: the 256×256 frame of `ProductIcon` from the Radmin VPN 2.1.4951.1 installer's MSI, scaled down. Trademark of Famatech Corp. |

File names: `<package>[-<variant>][-<size>].<ext>`. Upstream-based icons carry their size; `alt` is the redrawn one.

Icons already in UniGetUI's database, so nothing is hosted here for them: `nbt-explorer`, `privoxy`, `nettime` and `samsung-magician`.

### Icon size in UniGetUI

Checked against UniGetUI's source at commit [`b852884`](https://github.com/Devolutions/UniGetUI/tree/b85288414fea52a1283a67599da5558d4818d606):

- **Pixel size: 192 × 192 at most in practice.** After download, [`DownsizeImage`](https://github.com/Devolutions/UniGetUI/blob/b85288414fea52a1283a67599da5558d4818d606/src/UniGetUI.Core.IconStore/IconCacheEngine.cs#L318) shrinks any PNG, WebP, TIFF or AVIF icon whose side exceeds [`MAX_SIDE = 192`](https://github.com/Devolutions/UniGetUI/blob/b85288414fea52a1283a67599da5558d4818d606/src/UniGetUI.Core.IconStore/IconCacheEngine.cs#L322), keeping the aspect ratio. A non-integer downscale blurs pixel art, which is why the 192 px versions here exist: 192 = 16 × 12.
- **File size: no limit in the code.** Icons are fetched with a plain [`HttpClient`](https://github.com/Devolutions/UniGetUI/blob/b85288414fea52a1283a67599da5558d4818d606/src/UniGetUI.Core.IconStore/IconCacheEngine.cs#L236) using .NET defaults: a [100 s timeout](https://learn.microsoft.com/dotnet/api/system.net.http.httpclient.timeout) and the whole body read into memory. Keep icons small anyway; they are re-downloaded whenever the cache is cleared.
- **Formats** are chosen by the server's `Content-Type` ([mapping](https://github.com/Devolutions/UniGetUI/blob/b85288414fea52a1283a67599da5558d4818d606/src/UniGetUI.Core.IconStore/IconCacheEngine.cs#L464)): PNG, WebP, AVIF, GIF, SVG, ICO, TIFF. JPEG and BMP are commented out as non-transparent, so such icons are not loaded at all.
- **Shape:** the [contribution guide](https://www.marticliment.com/unigetui/help/icons-and-screenshots) asks for a square PNG.
- **Lookup key:** [`GenerateIconId`](https://github.com/Devolutions/UniGetUI/blob/b85288414fea52a1283a67599da5558d4818d606/src/UniGetUI.PackageEngine.PackageManagerClasses/Packages/Package.cs#L451) lower-cases the package ID and turns `_ . space / ,` into dashes, so the icon is found under `nbt-studio` whatever the case of the manifest name.
- **Adding an icon:** the old Google Sheet is closed; icons now go in through pull requests to [`screenshot-database-v2.json`](https://github.com/Devolutions/UniGetUI/blob/main/WebBasedData/screenshot-database-v2.json) (see the [file's history](https://github.com/Devolutions/UniGetUI/commits/main/WebBasedData/screenshot-database-v2.json) for examples).

## Screenshots

[`screenshots/`](screenshots) holds screenshots for UniGetUI's package details page (the `images` list in the [icon database](https://github.com/Devolutions/UniGetUI/blob/main/WebBasedData/screenshot-database-v2.json)). Taken by Gesugao-san on Windows 11, NBT Studio v1.15.3, a sample world:

| File | Shows |
|---|---|
| [`nbt-studio-1.png`](screenshots/nbt-studio-1.png) | `level.dat` tag tree |
| [`nbt-studio-2.png`](screenshots/nbt-studio-2.png) | Find dialog |
| [`nbt-studio-3.png`](screenshots/nbt-studio-3.png) | Edit menu: Edit Value, Edit as SNBT, undo history |
| [`nbt-studio-4.png`](screenshots/nbt-studio-4.png) | File menu: new region file, import from clipboard |
| [`nbt-studio-5.png`](screenshots/nbt-studio-5.png) | Icon set picker |
| [`nbt-studio-6.png`](screenshots/nbt-studio-6.png) | About and update check dialogs |

Icons belong to their respective authors.

Manifests only point to upstream release files; nothing else is redistributed here.
