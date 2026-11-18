# Conventions

Rules that several manifests in this bucket follow.

## Programs installed outside Scoop

Non-portable packages (`NetTime`, `Radmin-VPN`, `Samsung-Magician`, `PlanetSide-2-LaunchPad`, `WinMX`) check before installing whether the program is already installed on the system without Scoop, and stop instead of silently taking it over (a later `scoop uninstall` would remove that copy too). `scoop update` is not affected. For `Radmin-VPN`, `Samsung-Magician`, `PlanetSide-2-LaunchPad` and `WinMX`, whose installers can install over an existing copy, run `$env:GESU_ALLOW_EXISTING = '1'` in the same shell to let Scoop take over; the variable stays set until you close the shell or run `Remove-Item Env:GESU_ALLOW_EXISTING`. `NetTime` has no such override: its regular installer registers its own `NetTimeSvc`, which a Scoop copy cannot share.

## Shortcuts to programs outside the app folder

Scoop puts shortcuts only for files inside its app folder, so `Radmin-VPN`, `Samsung-Magician`, `PlanetSide-2-LaunchPad` and `WinMX` find the folder the installer used (through the program's uninstall entry) and link it into the app folder as a junction (`RadminVPN`, `SamsungMagician`, `LaunchPad`, `Winmx`); the shortcut in *Scoop Apps* points through it. Update and uninstall delete only the junction, before Scoop touches the app folder, never the files it points to. If the program is not found where its uninstall entry says, Scoop warns and installs without the shortcut. To get the shortcut for a copy installed before it was added, run `scoop update -f <package>` from an elevated shell: it reruns the installer over the existing copy.

## Programs that are running or have files open

`Tixati`, `Fopnu`, `DarkMX` and `WinMX` stop if the program is running or its data files are open in another program (the program itself, a backup or sync tool). Scoop's own check only looks for processes started from the app's folder in `~\scoop\apps`; [`scripts/common/Test-AppBusy.ps1`](../scripts/common/Test-AppBusy.ps1) also finds copies started from anywhere else, by process name, and tries to open every file in the data folder (`%APPDATA%\tixati`, `%APPDATA%\fopnu`, `%APPDATA%\darkmx`, the WinMX folder) exclusively. A fresh install is checked in `pre_install`; `scoop update` and `scoop uninstall` are checked in `pre_uninstall`, because Scoop runs that hook before it removes anything, while `pre_install` of the new version only runs after the old one is gone. Scoop runs the `pre_uninstall` of the manifest saved at install time, so the update check starts working once a version with it is installed (`scoop update <app> -f` does that). If the helper is missing, for example after `scoop bucket rm gesu`, the uninstall check only warns, so the app can still be removed.

## Manifest names

Manifest names keep the product's capitalisation: UniGetUI builds the display name from the file name with [`FormatAsName`](https://github.com/Devolutions/UniGetUI/blob/b85288414fea52a1283a67599da5558d4818d606/src/UniGetUI.Core.Tools/Tools.cs#L320), which turns dashes into spaces and only upper-cases the first letter of each word (`NBT-Studio` → "NBT Studio", but `nbt-studio` → "Nbt Studio"). Scoop itself is case-insensitive, so `nbt-studio` works in commands too. Folders under `scripts/` are lowercase; they do not affect the display name.

## Licenses

Manifests give the license as an [SPDX](https://spdx.org/licenses/) identifier with a link to the license text, which UniGetUI shows next to the name. Links to GitHub use `blob/HEAD/`, so they follow the upstream default branch even if it is renamed. `NBT-Studio` stays `Unknown`: upstream has no license file.

[`licenses/`](../licenses) holds license texts that upstream does not publish as a file of its own, copied verbatim with their source:

| File | Notes |
|---|---|
| [`NetTime.txt`](../licenses/NetTime.txt) | Notice from the header of NetTime's source files (`NetTimeSource-314.zip` from SourceForge). It matches no SPDX license, so the manifest uses the custom identifier `LicenseRef-NetTime`. |
| [`Fopnu.txt`](../licenses/Fopnu.txt) | License agreement shown by the Fopnu 1.68 installer; Fopnu publishes no license file on its website. |

## File associations

Like the [`git` manifest](https://github.com/ScoopInstaller/Main/blob/bcff7c46a4ad0a7765b9f61260ab75440a3e69ea/bucket/git.json) in Scoop's [Main bucket](https://github.com/ScoopInstaller/Main), `NBT-Studio` ships [registry templates](../scripts/nbt-studio) instead of touching the registry on its own. `post_install` fills in the install path; after install, run:

```cmd
reg import "%USERPROFILE%\scoop\apps\NBT-Studio\current\install-associations.reg"
```

This makes NBT Studio the default app for `.nbt` and adds it to "Open with" for `.snbt`, `.dat`, `.dat_old`, `.mca`, `.mcr`, `.mcc`, `.mcstructure` and `.schematic` without changing their defaults. Paths point to `current`, so they survive updates. `scoop uninstall` imports [`uninstall-associations.reg`](../scripts/nbt-studio/uninstall-associations.reg) and removes the entries.
