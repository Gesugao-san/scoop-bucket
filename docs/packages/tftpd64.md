# Tftpd64

| | |
|---|---|
| Manifest | [`bucket/Tftpd64.json`](../../bucket/Tftpd64.json) |
| Upstream | [pjo2.github.io/tftpd64](https://pjo2.github.io/tftpd64/) ([PJO2/tftpd64](https://github.com/PJO2/tftpd64), Philippe Jounin) |
| Install | `scoop install gesu/Tftpd64` |

TFTP server and client with DHCP, DNS, SNTP and Syslog servers; the usual way to flash routers and boards from U-Boot or Breed over the network. Official signed portable zip (x64 `tftpd64.exe`, x86 `tftpd32.exe`); commands `tftpd64` (x64) or `tftpd32` (x86) and `tftpd`; *Tftpd64* shortcut. Settings are in the persisted `tftpd32.ini`, but since 4.73 it first looks in `%APPDATA%\Tftpd64`, `%LOCALAPPDATA%\Tftpd64`, `%ProgramData%\Tftpd64` and similar folders (`TFTPD32_INI_DIR` overrides), so a file left there by the installer version wins; the notes say so, with router-recovery hints. License: EUPL (per `readme.txt`, the source headers and the 4.72 release notes), although `license.md` in the repository is still the GPLv2 text and Scoop Extras says GPL-2.0-only. Otherwise the same manifest as Scoop Extras (`extras/tftpd`); hashes taken from it.

[All packages](../../README.md#packages)
