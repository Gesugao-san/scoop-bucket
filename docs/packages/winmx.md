# WinMX

| | |
|---|---|
| Manifest | [`bucket/WinMX.json`](../../bucket/WinMX.json) |
| Upstream | [WinMX Community Patch](https://patch.winmxconex.com) ([WinMXWorld](https://www.winmxworld.com)) |
| Install | `scoop install gesu/WinMX                    # setup wizard, elevated shell` |

WinMX 3.54 Beta 4 (Frontcode, abandoned in 2005) with the community patch 1.0, which replaces `OLEDLG.DLL` so WinMX reconnects to the user-run network. **Not portable and not silent**: the only download is the community's Smart Install Maker 5.01 setup, which 7-Zip cannot unpack and whose silent switches are undocumented, so Scoop opens its wizard and `scoop uninstall` opens WinMX's own uninstaller (`Remove1.exe`, found through the `Winmx Community 1` uninstall entry in HKLM). Install and uninstall from an elevated shell. Because the wizard lets you pick any folder, the installer script finds it through that uninstall entry and links it into the app folder as a `Winmx` junction, so that `shortcuts` can add WinMX to *Scoop Apps*; the uninstaller removes only the junction. The SHA-256 is of the file whose MD5 matches the one on the patch page. No `checkver`: nothing new is expected.

[All packages](../../README.md#packages)
