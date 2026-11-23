# KML

| | |
|---|---|
| Manifest | [`bucket/KML.json`](../../bucket/KML.json) |
| Upstream | [my-th-os/KML](https://github.com/my-th-os/KML) (GPL-3.0), [forum thread](https://forum.kerbalspaceprogram.com/topic/133971-win-kml-persistence-file-editor/) |
| Install | `scoop install gesu/KML             # KSP save file editor` |

KML (Kerbal Markup Lister) edits Kerbal Space Program saves (`saves\<save>\persistent.sfs`) and `.craft` files outside the game: the whole file as a tree, sorted and filtered lists of vessels and kerbals, a graph of how a vessel's parts are attached, warnings about structural problems, and repairs for broken docking ports, grappling devices and contract references. Upstream tests it with KSP 1.0 to 1.12. The package installs upstream's `KML_Windows_v<version>.zip`, which holds a single `KML.exe` with both the window and the command line; upstream's `KML_Mono` build is the command line alone for Mono on Linux and macOS and adds nothing on Windows.

The shortcut in Scoop Apps is *KML (Kerbal Markup Lister)*, and `bin` adds the command `kml`. `KML.exe` is a console program that closes its console when it opens the window, so starting it from the shortcut flashes a console window for a moment. Given any dashed option it stays on the command line (`kml --help`, `kml persistent.sfs --warnings`, `kml persistent.sfs --repair`; see upstream's [COMMANDLINE.md](https://github.com/my-th-os/KML/blob/HEAD/KML/Doc/COMMANDLINE.md)). Without one, `kml <file>` opens the window, and the shell waits until it is closed, because Scoop's shim waits for the program it starts.

It needs .NET Framework 4.5 or later, which every Windows that can run Scoop already has. `KML.exe` is AnyCPU with 32-bit preferred, so one download serves every architecture and runs as a 32-bit process.

## Saves and backups

KML keeps no settings, so the manifest persists nothing. Saving in KML renames the previous file to `zKMLBACKUP<yyyyMMddHHmmss>-<name>` in the same folder and writes the new one; these backups are never deleted, so remove old ones by hand. Edit a save with KSP closed: the game writes `persistent.sfs` itself and would overwrite the changes.

When it opens a file under `%ProgramFiles%` or `%ProgramFiles(x86)%` (for example a Steam library in its default place), KML warns that it cannot overwrite it without admin rights: run it elevated, or move the game out of Program Files.

## Updates

On start the window asks GitHub's API for the latest release and shows an orange link if there is a newer one; it does not update itself. Update with `scoop update KML` instead. `checkver` follows GitHub releases; upstream publishes no hashes, so autoupdate computes them. The latest release, 0.9.4, is from 2023-04-21, so the package will soon move to the EOL tier (see [Update tiers](../automation.md#update-tiers)) and still return if upstream releases again.

## VirusTotal

[`KML_Windows_v0.9.4.zip`](https://www.virustotal.com/gui/file/856e1edd928b923084a015b35432708887973992edc654e1188805b7d6e9a0e5): 1 of 67 engines (MaxSecure, `Trojan.Malware.300983.susgen`, a generic heuristic), at the check in November 2026 of an analysis from a year earlier. The sandbox tags (`checks-network-adapters`, `detect-debug-environment`, `long-sleeps`, `checks-user-input`) fit an ordinary .NET GUI app that checks GitHub for updates on start. The source is open, but the release is built by the author, so the binary cannot be matched to it.

## Other buckets

At the time of writing, Scoop's Main, Extras and Games buckets and the DEV-tools bucket (which has `ksp-ckan`) have no KML package.

[All packages](../../README.md#packages)
