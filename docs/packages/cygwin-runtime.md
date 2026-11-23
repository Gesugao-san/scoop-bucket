# Cygwin-Runtime

| | |
|---|---|
| Manifest | [`bucket/Cygwin-Runtime.json`](../../bucket/Cygwin-Runtime.json) |
| Upstream | [cygwin.com](https://cygwin.com) (Cygwin project, Red Hat; LGPL-3.0 or later) |
| Install | `scoop install gesu/Cygwin-Runtime` |

`cygwin1.dll`, the library that turns POSIX calls into Windows ones, so that programs written for Linux run as Windows programs. [`zapret`](zapret.md) and [`zapret2`](zapret2.md) build `winws.exe` and `winws2.exe` with Cygwin, so they need it next to them. This package is Cygwin's own `cygwin` package unpacked, not a Cygwin installation: no `setup-x86_64.exe`, no `C:\cygwin64`, no shell.

Downloads `cygwin-<version>-x86_64.tar.xz` from the official mirror at mirrors.kernel.org and keeps everything in it: `usr\bin\cygwin1.dll` and Cygwin's small tools (`cygcheck`, `cygpath`, `ldd`, `mount`, `ps`, `kill`, `strace`, `regtool`...), with their documentation. None of them is put on `PATH` or turned into a command: `ps`, `kill`, `mount` and friends would hide Windows' own, and they expect a Cygwin root around them. *Scoop Apps* gets a **Cygwin Runtime** shortcut: `Cygwin-Runtime.cmd`, written at install time, shows the version and where `cygwin1.dll` is, and waits for a key.

The hash is the SHA-512 from the mirror's `sha512.sum` (the same value on mirrors.kernel.org and mirrors.dotsrc.org for 3.6.12-1); the archive itself could not be downloaded where this package was written, so run `.\bin\checkhashes.ps1 Cygwin-Runtime` on Windows. `checkver` reads the current version of the `cygwin` package from the mirror's `setup.ini` (about 4 MB), the file Cygwin's installer reads; test releases (`3.7.0-0.x`) are not current and are skipped. Autoupdate takes the hash from `sha512.sum`.

## Who uses it

[`Sync-ZapretComponents.ps1`](../../scripts/zapret/Sync-ZapretComponents.ps1) copies `usr\bin\cygwin1.dll` next to `winws.exe` / `winws2.exe` in zapret, zapret2 and [zapret-discord-youtube](zapret-discord-youtube.md) whenever this package is installed or updated, except while their `winws` runs. A global zapret takes it only from a global Cygwin-Runtime (Scoop installs dependencies in the same scope), never from `%USERPROFILE%\scoop`, which a non-admin user could change.

zapret's releases ship Cygwin **3.4.10**, the last version that runs on Windows 7 and 8; Cygwin 3.5 and later need Windows 8.1 or newer, 64-bit. Cygwin keeps old programs working with newer runtimes, so `winws.exe` built against 3.4 runs on 3.6. On Windows 7, zapret-discord-youtube can go back to its bundled 3.4.10 with `zapret-discord-youtube bundled on`.

A full Cygwin installation elsewhere does not interfere: each `cygwin1.dll` keeps its own shared memory, keyed to its folder.

## Mirrors

Cygwin is distributed only through its mirror network ([list](https://cygwin.com/mirrors.html)). [`mirrors.psd1`](../../mirrors.psd1) lists two more official mirrors, dotsrc.org (Denmark) and ftp.fau.de (Germany): `.\bin\Use-Mirror.ps1 gesu/Cygwin-Runtime dotsrc`. None of the mirrors could be downloaded from where this package was written; Scoop checks the hash either way.

Scoop's main bucket has [`cygwin`](https://github.com/ScoopInstaller/Main/blob/HEAD/bucket/cygwin.json), which is Cygwin's installer, a different thing.

[All packages](../../README.md#packages)
