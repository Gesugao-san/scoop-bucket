# OpenSSL-Light

| | |
|---|---|
| Manifest | [`bucket/OpenSSL-Light.json`](../../bucket/OpenSSL-Light.json) |
| Upstream | [Win32/Win64 OpenSSL](https://slproweb.com/products/Win32OpenSSL.html) by Shining Light Productions; [OpenSSL](https://www.openssl.org/) itself is Apache-2.0 |
| Install | `scoop install gesu/OpenSSL-Light` |

The `openssl` command line tool and its DLLs for Windows, from the most widely used Windows build of OpenSSL. "Light" is the build without the headers and libraries for developers. Added as the tool [`3X-UI`](3x-ui.md) ships an installer of in its release archive, for making self-signed certificates.

Downloads the Inno Setup installers `Win64OpenSSL_Light-<version>.exe`, `Win32OpenSSL_Light-...` and `Win64ARMOpenSSL_Light-...` and unpacks them with [innounp](https://innounp.sourceforge.net/) (a dependency) instead of running them, as Scoop's [`main/openssl-light`](https://github.com/ScoopInstaller/Main/blob/HEAD/bucket/openssl-light.json) does: the program files go to `bin`, the common `SSL` folder with `openssl.cnf` to `bin\cnf`. The hashes come from upstream's own list, [slproweb/opensslhashes](https://github.com/slproweb/opensslhashes) (`win32_openssl_hashes.json`), which `checkver` also reads for the newest version, and autoupdate for the hashes.

slproweb.com could not be reached from where this package was written, so the installers were not downloaded or unpacked here: the layout is the one `main/openssl-light` relies on. Check with `scoop install gesu/OpenSSL-Light` and `openssl version -a` on Windows.

## Command and shortcut

`openssl` in any console. The package sets **`OPENSSL_CONF`** in your user environment to `%USERPROFILE%\scoop\apps\OpenSSL-Light\current\bin\cnf\openssl.cnf`, like `main/openssl-light`: without a config file, commands that ask questions (such as `openssl req` without `-subj`) fail. Open a new console after installing; `scoop uninstall` removes the variable.

*Scoop Apps* gets an **OpenSSL Light** shortcut. `openssl.exe` without arguments waits for commands at an `OpenSSL>` prompt, so the shortcut opens `OpenSSL-Light.cmd`, a micro-launcher written at install time that prints `openssl version -a` and a few common commands, and waits for a key.

A self-signed certificate for a panel on this machine, valid for a year:

```cmd
openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout localhost.key -out localhost.crt -subj /CN=localhost
```

## Conflicts

Scoop's main bucket has `openssl`, `openssl-light`, `openssl-lts` and `openssl-lts-light`; each adds the same `openssl` command and sets `OPENSSL_CONF`. Installing this package stops while any of them is installed. A copy installed with upstream's own installer can stay: it has its own folder and PATH entry, so the first one on `PATH` answers to `openssl`, and the `OPENSSL_CONF` set here applies to both. The install only warns about it.

UniGetUI already has an icon for `openssl-light`, so none is hosted here.

[All packages](../../README.md#packages)
