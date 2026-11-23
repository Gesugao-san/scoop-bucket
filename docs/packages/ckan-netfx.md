# CKAN-NetFx

| | |
|---|---|
| Manifest | [`bucket/CKAN-NetFx.json`](../../bucket/CKAN-NetFx.json) |
| Upstream | [KSP-CKAN/CKAN](https://github.com/KSP-CKAN/CKAN) (MIT) |
| Install | `scoop install gesu/CKAN-NetFx      # KSP mod manager, .NET Framework build; one of the two` |

[`CKAN`](ckan.md), the Kerbal Space Program mod manager, as `ckan.exe`: the small build (about 7.5 MB) for .NET Framework 4.8.1, which upstream now offers for Mono on macOS and Linux and which was its Windows download until 1.36.2. Same code, commands and data as `CKAN`, without the dark theme. Choose it to save disk space and download time (130 MB for every update of `CKAN`) or on 32-bit and ARM64 Windows, where the x64-only `ckan-windows.exe` cannot run or runs emulated.

It needs .NET Framework 4.8.1 (the build targets it), which Windows 11 22H2 and later include; elsewhere, if CKAN does not start, install it with [`NetFx-4`](netfx-4.md) (`scoop install -g gesu/NetFx-4` from an elevated shell, suggested by the manifest) or from [Microsoft](https://dotnet.microsoft.com/download/dotnet-framework/net481).

Both packages add the command `ckan`, so only one can be installed: each manifest's `pre_install` stops if the other one, or `ksp-ckan` from another bucket, is installed (Scoop runs it after the download). The shortcuts in Scoop Apps are *CKAN (.NET Framework)* and *CKAN (.NET Framework, --asroot)*, the latter for elevated sessions (see [Administrator rights](ckan.md#administrator-rights)). One manifest without `architecture` serves all of them: `ckan.exe` is a plain AnyCPU .NET assembly (IL only), so it runs as a 64-bit process on x64 and natively on ARM64.

Everything else (updates, [`Play-KSP.cmd`](ckan.md#launching-ksp-steam-and-ckan-play-time), `ckan://` links, data, other buckets) is as described for [`CKAN`](ckan.md), with `CKAN-NetFx` in the commands. The self-updater of this build always asks for `ckan.exe`, so it stays on this build. `checkver` follows GitHub releases; upstream publishes no hashes, so autoupdate computes them.

[All packages](../../README.md#packages)
