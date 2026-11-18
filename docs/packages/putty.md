# PuTTY

| | |
|---|---|
| Manifest | [`bucket/PuTTY.json`](../../bucket/PuTTY.json) |
| Upstream | [chiark.greenend.org.uk/~sgtatham/putty](https://www.chiark.greenend.org.uk/~sgtatham/putty/) (Simon Tatham) |
| Install | `scoop install gesu/PuTTY` |

SSH, Telnet, rlogin and serial-console client, with PSCP, PSFTP, Plink, Pageant and PuTTYgen. Official signed zip for x64, x86 and ARM64; commands `putty`, `puttygen`, `pscp`, `pageant`, `psftp`, `plink`; shortcuts for PuTTY, Pageant, PSFTP and PuTTYgen. Sessions and host keys stay in the registry (`HKCU\Software\SimonTatham\PuTTY`), so updates and uninstalls keep them; the notes give the `reg export` line. No ZModem/XModem/YModem: that is what [`Tabby`](../../bucket/Tabby.json) (or Tera Term) is for. Chosen over ExtraPuTTY (a PuTTY 0.67 fork, last snapshot 2016) and the PuTTY.ORG.RU build (last Russian build 0.73-RU-17, December 2019), which both miss years of security fixes. `checkver` reads the home page; autoupdate takes the hashes from the release's `sha512sums`. Same manifest as Scoop Extras (`extras/putty`), with notes; hashes taken from it.

[All packages](../../README.md#packages)
