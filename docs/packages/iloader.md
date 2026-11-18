# iloader

| | |
|---|---|
| Manifest | [`bucket/iloader.json`](../../bucket/iloader.json) |
| Upstream | [nab138/iloader](https://github.com/nab138/iloader) |
| Install | `scoop install gesu/iloader` |

Installs SideStore, LiveContainer or any IPA on an iPhone/iPad. Needs Apple Mobile Device Support (usbmuxd): upstream asks for [iTunes](https://support.apple.com/106372); the lightest option is `Apple-Mobile-Device-Support` (AMDS alone); the Apple Devices app (`winget install 9NP83LWLPZ9K`) should work too, but upstream does not mention it. If Windows sees the device only as a camera/MTP device, install the USB driver with `Apple-Mobile-Drivers-Installer`. Portable: the binary is unpacked from the upstream NSIS installer. Decline the in-app update, it would install a second copy outside Scoop; use `scoop update iloader`. Upstream warns that only its GitHub releases and [iloader.app](https://iloader.app) are official sources.

[All packages](../../README.md#packages)
