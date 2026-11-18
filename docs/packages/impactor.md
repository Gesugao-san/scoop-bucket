# Impactor

| | |
|---|---|
| Manifest | [`bucket/Impactor.json`](../../bucket/Impactor.json) |
| Upstream | [claration/impactor](https://github.com/claration/impactor) |
| Install | `scoop install gesu/Impactor` |

iOS/iPadOS/tvOS sideloading (formerly PlumeImpactor): signs IPAs with an Apple ID, installs SideStore and LiveContainer, places pairing files. Needs Apple Mobile Device Support (usbmuxd): upstream asks for [iTunes](https://support.apple.com/106372); the lightest option is `Apple-Mobile-Device-Support` (AMDS alone); the Apple Devices app (`winget install 9NP83LWLPZ9K`) should work too, but upstream does not mention it. If Windows sees the device only as a camera/MTP device, install the USB driver with `Apple-Mobile-Drivers-Installer`. Portable: the upstream `-portable.exe` build for x64, x86 or ARM64, plus the `plumesign` command-line tool. Closing the window leaves it in the tray for auto-refresh, so quit it from the tray before updating. Data stays in `%APPDATA%\PlumeImpactor`. Its *start with Windows* option writes `<path> --tray` to `HKCU\…\Run` without quotes, so it may fail if the Scoop path has spaces; uninstall removes that entry.

[All packages](../../README.md#packages)
