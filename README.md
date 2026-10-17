# scoop-bucket

Personal [Scoop](https://scoop.sh) bucket by [Gesugao-san](https://github.com/Gesugao-san).

## Usage

```powershell
scoop bucket add gesugao https://github.com/Gesugao-san/scoop-bucket
scoop install gesugao/nbt-studio
```

Works in [UniGetUI](https://github.com/marticliment/UniGetUI) too: add the bucket in UniGetUI's Scoop settings (or with the command above), then search for the package.

## Packages

| Package | Upstream | Notes |
|---|---|---|
| `nbt-studio` | [tryashtar/nbt-studio](https://github.com/tryashtar/nbt-studio) | Needs .NET 6 Desktop Runtime x64 (`winget install Microsoft.DotNet.DesktopRuntime.6`). Upstream has no releases since v1.15.3. File associations: see below. |

## File associations

Like Scoop's `git` manifest, `nbt-studio` ships registry files instead of touching the registry on its own. After install, run:

```cmd
reg import "%USERPROFILE%\scoop\apps\nbt-studio\current\install-associations.reg"
```

This makes NBT Studio the default app for `.nbt` and adds it to "Open with" for `.snbt`, `.dat`, `.mca`, `.mcr`, `.mcc`, `.mcstructure` and `.schematic` without changing their defaults. Paths point to `current`, so they survive updates. `scoop uninstall` removes the entries.

Manifests only point to upstream release files; nothing is redistributed here.
