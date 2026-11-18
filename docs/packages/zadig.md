# Zadig

| | |
|---|---|
| Manifest | [`bucket/Zadig.json`](../../bucket/Zadig.json) |
| Upstream | [zadig.akeo.ie](https://zadig.akeo.ie) ([pbatard/libwdi](https://github.com/pbatard/libwdi), Pete Batard) |
| Install | `scoop install gesu/Zadig                    # asks for admin rights (UAC) on start` |

Installs a generic USB driver (WinUSB, libusb-win32, libusbK or USB serial) for a chosen device, so libusb programs can open it, e.g. MediaTek's BROM port for [`MTKClient`](../../bucket/MTKClient.json) (the alternative that keeps the original driver is [`UsbDk`](../../bucket/UsbDk.json)). **2.9 (13 June 2024) is still the current version**, released as `zadig-2.9.exe` with libwdi v1.5.1. One portable exe (x86, runs on x64 and ARM64), saved as `zadig.exe`; command `zadig` and a *Zadig* shortcut in Scoop Apps; it asks for admin rights (UAC) on every start. It reads `zadig.ini` from the folder it is started in, which the shortcut sets to the app folder, where the file is persisted (empty means defaults). Its own once-a-day update check stays on; updates come from Scoop. `checkver` reads the latest libwdi release from the GitHub API (tag and `zadig-<version>.exe`), since the libwdi and Zadig versions differ. Hash taken from [winget](https://github.com/microsoft/winget-pkgs/tree/master/manifests/a/akeo/ie/Zadig/2.9.788) (`akeo.ie.Zadig`, version 2.9.788). Not in Scoop's official buckets.

[All packages](../../README.md#packages)
