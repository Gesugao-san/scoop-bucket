# NetFx-4

| | |
|---|---|
| Manifest | [`bucket/NetFx-4.json`](../../bucket/NetFx-4.json) |
| Upstream | [Microsoft](https://dotnet.microsoft.com/download/dotnet-framework) (proprietary) |
| Install | `scoop install -g gesu/NetFx-4               # global, elevated shell; for CKAN-NetFx on older Windows` |

The Microsoft .NET Framework runtime at the newest 4.x, now 4.8.1: an in-place update of every 4.x, with native ARM64 support. It is here for programs built for it, such as [`CKAN-NetFx`](ckan-netfx.md), which suggests it. Unlike .NET 5 and later, it cannot be installed side by side or into a folder: it is a Windows component, so this package only makes sure Windows has it.

The name follows Scoop's convention: a name without a full version follows the newest release, here of .NET Framework 4. After 4.x Microsoft moved on to .NET 5 and later, a different product, so `NetFx-4` is the last line of .NET Framework. Until 23 November 2026 the package was called `NetFx-4.8.1`; if you installed it under that name, run `scoop uninstall NetFx-4.8.1` and `scoop install -g gesu/NetFx-4` (neither touches .NET Framework itself).

**Global install only** (`scoop install -g`, elevated shell). The installer script reads `Release` in `HKLM\SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full`; for 4.8.1, 533320 or higher means 4.8.1 or later (533320 or 533509 on Windows 11, 533325 elsewhere). Windows 11 22H2 and later ship with 4.8.1, and Windows Update rolls it out to Windows 10 21H2 and 22H2, so on most up-to-date systems Scoop installs nothing and only records the package. Otherwise it runs Microsoft's offline installer, `NDP481-x86-x64-AllOS-ENU.exe` (signed by Microsoft Corporation, the 74 MB English package with the x86, x64 and ARM64 parts), with `/q /norestart`:

| Exit code | Result |
|---|---|
| 0 | installed |
| 3010, 1641 | installed; restart Windows to finish (Scoop warns) |
| 5100 | this Windows is not supported (4.8.1 needs Windows 10 20H2 or later, or Windows Server 2022 or later): install stops |
| anything else | install stops; the setup logs are in `%TEMP%` |

The installer is deleted from the app folder afterwards; Scoop's cache keeps a copy (`scoop cache rm NetFx-4` frees it). The *NetFx 4* shortcut in Scoop Apps opens a micro-launcher that shows the installed `Version` and `Release`.

`scoop uninstall` leaves .NET Framework in place, because Windows and other programs use it. On Windows 10 it appears under Control Panel > Programs > View installed updates (KB5011048) and can be removed there; on Windows 11 22H2 and later it is part of the system.

## Updates

`checkver` reads the first `.NET Framework 4.x` on Microsoft's [downloads page](https://dotnet.microsoft.com/en-us/download/dotnet-framework), which lists the newest version first. There is no `autoupdate`: the offline installer's URL contains a new GUID for every version, and the `Release` number a version registers is published only in Microsoft's [documentation](https://learn.microsoft.com/dotnet/framework/install/how-to-determine-which-versions-are-installed). Fixes for 4.8.1 itself come through Windows Update, not through a new offline installer.

The package is in the EOL tier ([`update-tiers.json`](../../update-tiers.json)), so the Excavators skip it and the monthly *EOL* workflow checks it on the 1st of each month instead ([Update tiers](../automation.md#update-tiers)). If that check finds a new version, it opens an issue, because without `autoupdate` the update is done by hand: change `version`, `url`, `hash`, `homepage` and `license` (if Microsoft gives the version its own page), `$minRelease` in the installer script (the lowest `Release` of the new version from the documentation above), and the Windows versions on this page.

The license terms are Microsoft's supplemental license terms for .NET Framework, shown by the installer (`eula.rtf`) and not published as a page of their own; the silent install does not show them. No mirror.

[All packages](../../README.md#packages)
