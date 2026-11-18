# UsbDk

| | |
|---|---|
| Manifest | [`bucket/UsbDk.json`](../../bucket/UsbDk.json) |
| Upstream | [daynix/UsbDk](https://github.com/daynix/UsbDk) (Daynix / Red Hat, Apache-2.0) |
| Install | `scoop install gesu/UsbDk                    # driver, elevated shell` |

USB Development Kit: a filter driver and library that give a user-mode program exclusive access to any USB device without replacing its driver; libusb uses it as a backend, so [`MTKClient`](../../bucket/MTKClient.json) can open MediaTek's BROM/preloader port while it keeps its serial driver. **1.0.22 (17 March 2020) is still the current version.** Not portable: runs the official MSI (*UsbDk Runtime Libraries*) quietly from an elevated shell, which installs into Program Files, copies `UsbDkHelper.dll` to System32 (where libusb loads it from) and installs the driver; a 3010 exit code is reported as a needed reboot, and the MSI log is kept as `install.log` in the app folder. The install folder is linked as `UsbDk` inside the app folder for the command `UsbDkController` (`-n` lists devices); no shortcut, it has no window. x64 and x86 only: Scoop would fall back to the x64 package on ARM64 Windows, so `pre_install` stops there, a kernel driver must match the OS. A fresh install stops if UsbDk is already installed without Scoop (`$env:GESU_ALLOW_EXISTING = '1'` lets Scoop take it over); updates go over the existing copy, and only `scoop uninstall` runs `msiexec /x`. `checkver` reads the latest release from the GitHub API (tag `v1.00-22`, file `UsbDk_1.0.22_x64.msi`). Hashes taken from [winget](https://github.com/microsoft/winget-pkgs/tree/master/manifests/d/daynix/UsbDk/1.0.22) (not downloaded and checked here). Not in Scoop's official buckets.

[All packages](../../README.md#packages)
