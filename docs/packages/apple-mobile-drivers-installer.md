# Apple-Mobile-Drivers-Installer

| | |
|---|---|
| Manifest | [`bucket/Apple-Mobile-Drivers-Installer.json`](../../bucket/Apple-Mobile-Drivers-Installer.json) |
| Upstream | [NelloKudo/Apple-Mobile-Drivers-Installer](https://github.com/NelloKudo/Apple-Mobile-Drivers-Installer) |
| Install | `scoop install gesu/Apple-Mobile-Drivers-Installer` |

Installs only the script; run `AppleDrivInstaller` from an elevated PowerShell to install the drivers, or use the *Apple Mobile Drivers Installer* shortcut in Scoop Apps: it points to a small launcher (`AppleDrivInstaller-Admin.cmd`, written at install time) that asks for admin rights and keeps the window open. It downloads iTunes from apple.com for Apple Mobile Device Support and the USB and tethering drivers from the [Microsoft Update Catalog](https://www.catalog.update.microsoft.com/), then installs them with `pnputil`. Needed when Windows only sees the device as a media/MTP device, e.g. for `iloader`: the iTunes 12.13.11.1 installer (Apple Mobile Device Support 20.0.0.35) contains no USB driver (`usbaapl64.inf`). Upstream has no releases, so the version is the date of the script's last commit and the URL is pinned to that commit. `scoop uninstall` removes the script, not the drivers. For AMDS alone, without drivers and without downloading iTunes on every run, use `Apple-Mobile-Device-Support`.

[All packages](../../README.md#packages)
