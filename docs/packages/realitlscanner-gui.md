# RealiTLScanner-GUI

| | |
|---|---|
| Manifest | [`bucket/RealiTLScanner-GUI.json`](../../bucket/RealiTLScanner-GUI.json) |
| Upstream | [EikeiDev/RealiTLScanner-GUI](https://github.com/EikeiDev/RealiTLScanner-GUI) (MPL-2.0 as stated in the README; no license file) |
| Install | `scoop install gesu/RealiTLScanner-GUI` |

A dark-themed Windows interface (WPF, .NET 9) for [`RealiTLScanner`](realitlscanner.md). It builds the scanner's command line from a form: the three modes (`-addr` for an IP, range or domain, `-in` for a file, `-url` for a web page), port, threads, timeout, output file, verbose and IPv6. While the scan runs it shows a colour-coded live log and an elapsed timer, and when the scanner exits it loads the results file into a sortable table (IP, origin, certificate domain and issuer, country) with copy on right-click and CSV export. It also keeps a GeoIP database next to the scanner and downloads a new one when it is older than 7 days. Upstream calls release 3.0 "Final".

Downloads the official `RealiTLScannerGUI_v3.0.zip` from the GitHub release (the hash matches GitHub's asset digest): `RealiTLScannerGUI.exe` (a framework-dependent single-file build for x64), its `.pdb`, and a copy of the scanner. That scanner copy is **0.2.1** (build info: commit `9bf9dfa`, the `v0.2.1` tag), from before the fix for a crash on certificates without DNS names in 0.2.3, so the package does not use it (see below). No checksum file upstream, so autoupdate lets Scoop compute the hash. The GUI itself cannot be rebuilt and compared here (WPF needs Windows), so the exe is taken as published. [VirusTotal](https://www.virustotal.com/gui/file/1795efdba632db40416f5dfe71618af9a2d62e701f9aed10ddc8fa06df285320) (`RealiTLScannerGUI.exe` from 3.0, November 2026): 0 of 67 engines. No mirror: upstream publishes only on GitHub.

## Scanner: gesu/RealiTLScanner

The manifest `depends` on [`gesu/RealiTLScanner`](realitlscanner.md), which Scoop installs first. The GUI looks for `RealiTLScanner-windows-64.exe` next to itself (and in up to four parent folders), and starts it with that folder as the working folder. The installer deletes the bundled 0.2.1 and puts a **Scoop shim** there under that name: a copy of Scoop's own `shim.exe` (the one Scoop uses for every command in `~\scoop\shims`, picked with Scoop's `get_shim_path`) with a `RealiTLScanner-windows-64.shim` file that points to `apps\RealiTLScanner\current\RealiTLScanner.exe`. The shim passes on the arguments, the working folder, the output and the exit code, and its child process ends with it, so the GUI's Stop button still works. Because it goes through `current`, `scoop update RealiTLScanner` updates the scanner for the GUI too, without reinstalling the GUI.

The GUI runs the exe itself, not the `realitlscanner` command, so the [GeoIP wrapper](realitlscanner.md#geoip) and `GESU_GEOIP_MMDB` do not apply here; the GUI has its own GeoIP handling.

## .NET runtime

`RealiTLScannerGUI.exe` is built for .NET 9 and needs a .NET **Desktop** Runtime on the system. [.NET 9 reached end of support on 10 November 2026](https://devblogs.microsoft.com/dotnet/dotnet-8-9-end-of-support/), so it gets no more security fixes. The command `realitlscanner-gui` and the *Scoop Apps* shortcut **RealiTLScanner GUI** therefore both open `RealiTLScanner-GUI.cmd`, a launcher written at install time that sets [`DOTNET_ROLL_FORWARD`](https://learn.microsoft.com/dotnet/core/versions/selection#control-roll-forward-behavior) `=LatestMajor` for this start only and starts the GUI: it then runs on the newest installed Desktop Runtime (10, 11, ...), or on 9 if that is the only one. Other .NET programs are not affected. A console window flashes briefly when the launcher starts; a launcher without one would need VBScript, which Windows is phasing out.

If no Desktop Runtime is installed, the GUI does not start and Windows offers to download one. The manifest suggests [`extras/windowsdesktop-runtime-lts`](https://github.com/ScoopInstaller/Extras/blob/master/bucket/windowsdesktop-runtime-lts.json) (.NET 10 LTS). Running a .NET 9 WPF app on 10 or newer is what Microsoft's roll-forward is for, but this app is not tested by upstream on it; starting `RealiTLScannerGUI.exe` directly uses .NET 9 if it is installed (`versions/windowsdesktop-runtime-9.0`).

## Files

- **Results:** the GUI's default output is `out.csv` in the scanner's folder, which is the app folder. The manifest `persist`s `out.csv` (an empty one is created on the first install, so that Scoop persists a file and not a folder), so the last results survive updates in `~\scoop\persist\RealiTLScanner-GUI\out.csv`. Any other relative name in the *Output* field lands in the version folder and is lost on update: give a full path for files to keep, or export from the table.
- **GeoIP:** `Country.mmdb` in the app folder. On install it is copied from [`gesu/Loyalsoldier-GeoIP`](loyalsoldier-geoip.md) when that is installed (in the same scope). On every start the GUI checks the file's age and, when it is missing or older than 7 days, downloads `Country.mmdb` from [Loyalsoldier/geoip's latest release](https://github.com/Loyalsoldier/geoip/releases/latest) itself (no hash check). The file is not persisted: the GUI replaces it by deleting and moving, which would break Scoop's hard link, so after an update of the GUI the copy is taken from `Loyalsoldier-GeoIP` again or downloaded again.

## Conflicts

Not in any bucket found on [scoop.sh](https://scoop.sh/) (November 2026). There is no check for copies installed without Scoop: the GUI is portable and registers nothing.

[All packages](../../README.md#packages)
