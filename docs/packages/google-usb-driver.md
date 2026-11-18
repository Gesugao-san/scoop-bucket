# Google-USB-Driver

| | |
|---|---|
| Manifest | [`bucket/Google-USB-Driver.json`](../../bucket/Google-USB-Driver.json) |
| Upstream | [developer.android.com](https://developer.android.com/studio/run/win-usb) (Google, proprietary) |
| Install | `scoop install gesu/Google-USB-Driver        # driver, elevated shell` |

WinUSB driver for `adb` and `fastboot` on Windows (*Android ADB Interface*, *Android Bootloader Interface*); `platform-tools` (`adb` in Main) does not include it. **Not portable**: adds the package from the official `usb_driver_r13-windows.zip` to the Windows driver store with `pnputil /add-driver /install`, which also installs it on connected devices listed in its INF. Install and uninstall from an elevated shell. The catalog is Authenticode-signed by Google LLC (DigiCert), not by Microsoft, so Windows asks once whether to trust the publisher; the manifest does not add Google to *Trusted Publishers* by itself. The INF lists only Google vendor IDs (`VID_18D1`), so most other phones need the driver picked by hand once in Device Manager (*Update driver* → *Browse my computer* → *Let me pick* → *Show All Devices* → *Google, Inc.* → *Android Bootloader Interface*), e.g. phones on MediaTek in fastboot mode (`USB\VID_0E8D&PID_201C`). Published copies are found by their catalog name (`androidwinusba64.cat`) in `%windir%\INF\oem<N>.inf`, and the names this install added are kept in `published-inf.txt` in the persist folder; `scoop uninstall` deletes only those, and only if the file is still this package, since Windows reuses `oem<N>.inf` names. Updates leave the old package in place. Hash matches the one in the `google-usb-driver` manifest of [lzwme/scoop-proxy-cn](https://github.com/lzwme/scoop-proxy-cn); not in Scoop's official buckets.

[All packages](../../README.md#packages)
