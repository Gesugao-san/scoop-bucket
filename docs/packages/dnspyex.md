# dnSpyEx

| | |
|---|---|
| Manifest | [`bucket/dnSpyEx.json`](../../bucket/dnSpyEx.json) |
| Upstream | [dnSpyEx/dnSpy](https://github.com/dnSpyEx/dnSpy) (GPL-3.0-or-later) |
| Install | `scoop install gesu/dnSpyEx` |

.NET debugger, decompiler and assembly editor: opens .NET Framework, .NET and Unity (Mono) assemblies, decompiles them to C# or Visual Basic, debugs them without source code and edits their IL and metadata. dnSpyEx is the community continuation of [dnSpy](https://github.com/dnSpy/dnSpy), whose original author archived it in 2020 at 6.1.8.

Downloads the self-contained .NET builds from the GitHub release: `dnSpy-net-win64.zip` and `dnSpy-net-win32.zip`. They bundle their own .NET runtime (.NET 10.0.9 in 6.6.0), so no .NET needs to be installed, but that runtime gets security fixes only with new dnSpyEx releases. Upstream publishes no hashes; `checkver` follows the latest GitHub release and Scoop computes the hash of each new version. No mirror: upstream publishes only on GitHub.

## Commands and shortcuts

Like the [Extras](https://github.com/ScoopInstaller/Extras) bucket's old [`dnspy`](https://github.com/ScoopInstaller/Extras/blob/master/bucket/dnspy.json) manifest, both programs are commands:

- `dnSpy`: the GUI. Extras' [`dnspyex`](https://github.com/ScoopInstaller/Extras/blob/master/bucket/dnspyex.json) (6.6.0 as of November 2026) makes only `dnSpy.Console` a command, so the GUI starts only from its shortcut there.
- `dnSpy.Console`: the command-line decompiler. `dnSpy.Console -o C:\out C:\Games\Game\Game_Data\Managed\Assembly-CSharp.dll` writes a project with the decompiled code; run it without arguments for every option and decompiler language.

*Scoop Apps* gets **dnSpy** and **dnSpy Console**. `dnSpy.Console.exe` prints its usage and exits at once, so the second shortcut opens `dnSpy-Console.cmd`, a micro-launcher written at install time that explains the command, shows a few examples and waits for a key.

## Settings

dnSpy keeps `dnSpy.xml` in `%APPDATA%\dnSpy`, outside the Scoop folder, so settings survive updates without `persist`, and `scoop uninstall --purge` does not delete them. The same folder serves dnSpy, dnSpyEx and both Extras packages, so switching between them keeps your settings.

dnSpy has a portable mode: if `bin\dnSpy.xml` exists next to its DLLs, it keeps settings there and ignores `%APPDATA%\dnSpy` ([`AppDirectories.cs`](https://github.com/dnSpyEx/dnSpy/blob/v6.6.0/dnSpy/dnSpy.Contracts.DnSpy/App/AppDirectories.cs)). This package does not use it: in that mode dnSpy also looks for user themes, file lists and scripts only in `bin`, which is replaced on every update.

## Debugging Unity games

dnSpyEx can debug Unity games built with Mono, but the game first needs the patched `mono.dll` (or `mono-2.0-bdwgc.dll`) for its Unity version from [dnSpyEx/dnSpy-Unity-mono](https://github.com/dnSpyEx/dnSpy-Unity-mono), copied over the game's own (keep a backup). Then start the game from dnSpy (*Debug > Start Debugging*, with the Unity debug engine) or attach to a running one (*Attach to Process (Unity)*). If dnSpy cannot connect, the `mono.dll` is not the patched one. Games built with IL2CPP (`GameAssembly.dll`, `il2cpp_data`, no `Managed` folder) contain no .NET code, so dnSpy cannot open or debug them.

With BepInEx mods, `[Preloader] DumpAssemblies` in `BepInEx\config\BepInEx.cfg` writes the patched assemblies to disk for dnSpy to open, and `BreakBeforeLoadAssemblies` stops the game before they load, so you can attach dnSpy and set breakpoints in them.

## Not packaged

- `dnSpy-netframework.zip`: the build for .NET Framework 4.8 that upstream also publishes. The .NET builds above debug .NET Framework programs too.
- ARM64: upstream ships no ARM64 build. Windows 11 on ARM can run the x64 build under emulation (untested).

## Conflicts

- **Extras' `dnspyex`** shares the app folder with this package, because Scoop is case-insensitive: `scoop install gesu/dnSpyEx` says it is already installed. Run `scoop uninstall dnspyex` first, then install this one; settings stay.
- **Extras' `dnspy`** (the original dnSpy, 6.1.8, unmaintained) adds the same `dnSpy.Console` command. A fresh install stops while it is installed: run `scoop uninstall dnspy` first. The stop comes after Scoop has unpacked dnSpyEx, so Scoop treats that install as failed; the next `scoop install` cleans it up, or run `scoop uninstall dnSpyEx`.

There is no check for copies installed without Scoop: dnSpyEx is portable and registers nothing, so another copy (unpacked by hand or by winget) does not interfere.

## Downloads from elsewhere

Install dnSpyEx only from its [GitHub releases](https://github.com/dnSpyEx/dnSpy/releases) or a package manager that downloads from there: lookalike sites and GitHub repositories have spread dnSpy builds with malware. Old builds are a risk too: 6.4.0 fixed vulnerabilities in the bundled .NET 6 runtime, and 6.4.1 fixed an arbitrary code execution vulnerability.

[All packages](../../README.md#packages)
