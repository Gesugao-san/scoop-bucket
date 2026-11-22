# NetFx-4.8.1

| | |
|---|---|
| Manifest | [`bucket/NetFx-4.8.1.json`](../../bucket/NetFx-4.8.1.json) |
| Upstream | [Microsoft](https://dotnet.microsoft.com/download/dotnet-framework/net481) (proprietary) |
| Install | `scoop install -g gesu/NetFx-4.8.1          # global, elevated shell; for CKAN-NetFx on older Windows` |

The Microsoft .NET Framework 4.8.1 runtime, the newest .NET Framework: an in-place update of every 4.x, with native ARM64 support. It is here for programs built for it, such as [`CKAN-NetFx`](ckan-netfx.md), which suggests it. Unlike .NET 5 and later, it cannot be installed side by side or into a folder: it is a Windows component, so this package only makes sure Windows has it.

**Global install only** (`scoop install -g`, elevated shell). The installer script reads `Release` in `HKLM\SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full`; 533320 or higher means 4.8.1 or later (533320 or 533509 on Windows 11, 533325 elsewhere). Windows 11 22H2 and later ship with 4.8.1, and Windows Update rolls it out to Windows 10 21H2 and 22H2, so on most up-to-date systems Scoop installs nothing and only records the package. Otherwise it runs Microsoft's offline installer, `NDP481-x86-x64-AllOS-ENU.exe` (signed by Microsoft Corporation, the 74 MB English package with the x86, x64 and ARM64 parts), with `/q /norestart`:

| Exit code | Result |
|---|---|
| 0 | installed |
| 3010, 1641 | installed; restart Windows to finish (Scoop warns) |
| 5100 | this Windows is not supported (needs Windows 10 20H2 or later, or Windows Server 2022 or later): install stops |
| anything else | install stops; the setup logs are in `%TEMP%` |

The installer is deleted from the app folder afterwards; Scoop's cache keeps a copy (`scoop cache rm NetFx-4.8.1` frees it). The *NetFx 4.8.1* shortcut in Scoop Apps opens a micro-launcher that shows the installed `Version` and `Release`.

`scoop uninstall` leaves .NET Framework in place, because Windows and other programs use it. On Windows 10 it appears under Control Panel > Programs > View installed updates (KB5011048) and can be removed there; on Windows 11 22H2 and later it is part of the system.

The license terms are Microsoft's supplemental license terms for .NET Framework, shown by the installer (`eula.rtf`) and not published as a page of their own; the silent install does not show them. No `checkver` or `autoupdate`: the offline installer of 4.8.1 does not change, and Microsoft ships fixes for it through Windows Update. A new .NET Framework version would be a new package. No mirror.

[All packages](../../README.md#packages)
