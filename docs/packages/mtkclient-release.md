# MTKClient-Release

| | |
|---|---|
| Manifest | [`bucket/MTKClient-Release.json`](../../bucket/MTKClient-Release.json) |
| Upstream | [bkerler/mtkclient](https://github.com/bkerler/mtkclient) |
| Install | `scoop install gesu/MTKClient-Release        # latest release; install one of the two` |

[`MTKClient`](../../bucket/MTKClient.json) on the latest upstream release instead of `main`: currently v2.1.4.1 (18 March 2026), without the safer `seccfg` unlock and the Windows USB fixes made in `main` since (the notes say so). Upstream publishes no binaries, not even for releases (each has only the two source archives GitHub adds, and its CI only lints), so it is built the same way, with `uv` from the tag's `uv.lock`; that version still uses `fusepy` (with WinFsp's DLL bundled) instead of `mfusepy`. Same commands as `MTKClient`, so only one of the two can be installed (each manifest's `pre_install` stops if the other is installed; Scoop runs it after the download); the shortcut is *MTKClient (release)*, `logs` is persisted separately. `checkver` follows GitHub releases, the URL is the tag archive. Not in Scoop's official buckets.

[All packages](../../README.md#packages)
