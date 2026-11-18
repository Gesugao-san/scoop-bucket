# OCCT

| | |
|---|---|
| Manifest | [`bucket/OCCT.json`](../../bucket/OCCT.json) |
| Upstream | [ocbase.com](https://www.ocbase.com/occt-personal-use) (OCBASE, Personal edition) |
| Install | `scoop install gesu/OCCT                     # runs elevated (UAC prompt)` |

Stability check and stress test tool. **Personal edition: free for personal use only**, a paid edition is needed at work ([EULA](https://www.ocbase.com/eula)). `OCCT.exe` is a launcher that asks for admin rights (UAC) on every start and unpacks about 400 MB of test programs into a temporary folder. The download URL ends in `os:Windows`, which is not a valid file name, so the manifest names the file with `#/OCCT.exe`. `checkver` reads the version from the [download page](https://www.ocbase.com/download-personal), and autoupdate takes the SHA-256 that OCBASE publishes on the same page, so Excavator checks each new file against the vendor's checksum (17.1.10 also matches [winget](https://github.com/microsoft/winget-pkgs/tree/master/manifests/o/OCBase/OCCT/Personal)). OCCT has its own updater that would replace `OCCT.exe` inside the version folder: turn off *Check for updates* in its settings and use `scoop update OCCT`. Settings live in `OCCT.config.json` next to `OCCT.exe`; it is copied to the persist folder in `pre_uninstall` (which also runs on update) and back in `pre_install`, rather than persisted, because a hardlink would break if OCCT replaces the file instead of writing into it. Not in the [Extras](https://github.com/ScoopInstaller/Extras) bucket.

[All packages](../../README.md#packages)
