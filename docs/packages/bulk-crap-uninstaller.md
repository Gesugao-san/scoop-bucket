# Bulk-Crap-Uninstaller

| | |
|---|---|
| Manifest | [`bucket/Bulk-Crap-Uninstaller.json`](../../bucket/Bulk-Crap-Uninstaller.json) |
| Upstream | [BCUninstaller/Bulk-Crap-Uninstaller](https://github.com/BCUninstaller/Bulk-Crap-Uninstaller) |
| Install | `scoop install gesu/Bulk-Crap-Uninstaller    # runs elevated (UAC prompt)` |

Bulk program uninstaller (BCU): removes many programs in one go, also Store apps, Steam games and Windows updates, then looks for leftovers; finds orphaned apps. Commands: `BCUninstaller` (GUI) and `BCU-console`. Asks for admin rights (UAC) on every start. Upstream ships one portable `.7z` with self-contained .NET 8 builds for x64 and ARM64 (about 200 MB each, so Windows 10 or newer) plus a small launcher that picks one; the manifest extracts only the folder for the installed architecture (`extract_dir`), so the launcher is not needed. The archive uses 7-Zip's ARM64 filter, which needs 7-Zip 23.01 or newer; Scoop's own `7zip` is newer than that. BCU keeps everything next to its exe: settings in `BCUninstaller.settings`, notes on programs in `CustomNotes.xml` and the default uninstall list in `Default.bcul`. They are copied to the persist folder in `pre_uninstall` (which also runs on update) and back in `pre_install`, rather than persisted, because BCU deletes and recreates its settings file when it cannot read it or when *Reset settings* is used, which would break Scoop's hardlink. Its update check only opens the GitHub release page, so it is harmless; update with `scoop update`. Do not use *Uninstall BCUninstaller* from its Help menu. The upstream repository moved from `Klocman/` to the `BCUninstaller` organisation; URLs use the new one. The [Extras](https://github.com/ScoopInstaller/Extras) bucket has `bulk-crap-uninstaller` too, with the same file and hash: it keeps only `BCUninstaller.settings`, and also puts the helper programs (`SteamHelper`, `StoreAppHelper` and others) on the `PATH`.

[All packages](../../README.md#packages)
