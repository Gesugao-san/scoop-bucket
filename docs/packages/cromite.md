# Cromite

| | |
|---|---|
| Manifest | [`bucket/Cromite.json`](../../bucket/Cromite.json) |
| Upstream | [cromite.org](https://www.cromite.org/) ([uazo/cromite](https://github.com/uazo/cromite), GPL-3.0) |
| Install | `scoop install gesu/Cromite` |

Chromium fork based on Bromite, focused on privacy: fingerprinting mitigations, a built-in ad blocker, an internal firewall that blocks unwanted connections, no Google services. Upstream builds Windows x64 only (`chrome-win.zip`, no ARM64 or 32-bit build); `chrome.exe` is not code-signed. *Cromite* shortcut in Scoop Apps and the `cromite` command, both starting Cromite with the profile in the persist folder. `checkver` follows GitHub releases; the release tag carries the commit hash (`v153.0.8010.37-11507ac...`), which autoupdate takes from the tag for the download URL. Upstream publishes no checksums, so autoupdate computes the hash from the download.

Cromite's defaults differ from Chrome's in ways that show on some sites: JIT is off (turn it on per site in the site settings if a heavy web app is slow), WebRTC and WebGPU are off, push notifications do not arrive (Google's cloud messaging is disabled), there is no Google Sync or Safe Browsing. See upstream's [FAQ](https://github.com/uazo/cromite/blob/HEAD/docs/FAQ.md) and [features](https://github.com/uazo/cromite/blob/HEAD/docs/FEATURES.md).

## Data in persist

The shortcut and the command pass `--user-data-dir` pointing to `User Data` in the app folder, which Scoop links to `%USERPROFILE%\scoop\persist\Cromite\User Data`. The whole profile (bookmarks, history, passwords, cookies, extensions, settings) lives there, survives updates, and is deleted only by `scoop uninstall -p`.

Without that switch, Cromite uses `%LOCALAPPDATA%\Cromite\User Data`. On install, when the persist folder is still empty, the manifest copies (does not move) that folder into it, so a profile from a Cromite run without Scoop carries over. If that Cromite is running at the time, the copy is skipped with a warning; close it and run `scoop update Cromite -f`. The copy is skipped for global installs (`-g`).

To bring data over from Google Chrome, use Cromite's *Settings > Import bookmarks and settings*.

## Default browser

A program that opens a link starts the browser registered in Windows, and that registration knows nothing about the shortcut's `--user-data-dir`. Chromium-based browsers register `chrome.exe` without it (the *Make default* button inside the browser), so links would open with an empty profile in `%LOCALAPPDATA%\Cromite`; [Brave installed through Scoop](https://gist.github.com/hosaka/bd889b596f25292e14c97d558ad6cff8) has the same problem. So the manifest ships [registry templates](../../scripts/cromite) instead, like [file associations](../conventions.md#file-associations) elsewhere in the bucket: `post_install` fills in the install path, and after install, run:

```cmd
reg import "%USERPROFILE%\scoop\apps\Cromite\current\install-default-browser.reg"
```

```powershell
reg import "$env:USERPROFILE\scoop\apps\Cromite\current\install-default-browser.reg"
```

This registers *Cromite (Scoop)* (ProgID `CromiteHTML.Scoop`) for `http`, `https`, `.htm`, `.html`, `.shtml`, `.xht`, `.xhtml`, `.pdf`, `.svg` and `.webp`, every command with `--user-data-dir`, and adds Cromite to "Open with" for those files. It changes no defaults by itself: pick *Cromite (Scoop)* in *Settings > Apps > Default apps*. Paths point to `current`, so they survive updates. `scoop uninstall` imports [`uninstall-default-browser.reg`](../../scripts/cromite/uninstall-default-browser.reg) and removes the entries; Windows then asks which browser to use for the next link.

## Compared with extras/cromite

The [Extras](https://github.com/ScoopInstaller/Extras) bucket's [`cromite`](https://github.com/ScoopInstaller/Extras/blob/master/bucket/cromite.json) (153.0.8010.37 as of November 2026) installs the same file the same way, with the same persist folder and the same copy from `%LOCALAPPDATA%\Cromite\User Data`. It differs in two places:

- It sets the user variable `CHROME_EXECUTABLE` to Cromite's `chrome.exe`. Tools that read it (Flutter's `flutter run -d chrome`, Puppeteer-based tools) then start Cromite instead of Google Chrome, with JIT off and Cromite's other restrictions. This manifest does not set it.
- It has no browser registration, so links from other programs open in the empty default profile (see above). It also prints its copy message with the full profile path.

### Switching from extras/cromite

Scoop is case-insensitive, so `extras/cromite` and `gesu/Cromite` share the app and persist folders and cannot be installed side by side. Close Cromite, then:

```powershell
scoop uninstall cromite        # without -p: the profile stays in the persist folder
scoop install gesu/Cromite
```

The new install finds the profile already in place. `scoop uninstall` removes `CHROME_EXECUTABLE`.

## Copies run without Scoop

Upstream ships only a zip, with no installer and no uninstall entry, so there is nothing to detect or take over: a copy unpacked elsewhere keeps working alongside this package, with its own profile in `%LOCALAPPDATA%\Cromite\User Data` (copied once on install, see above). `scoop update` and `scoop uninstall` stop while Cromite from the app folder is running (Scoop's own check).

## Mirror

SourceForge's [`cromite.mirror`](https://sourceforge.net/projects/cromite.mirror/) copies the GitHub releases automatically (not run by the developers), in folders named after the release tag; its `chrome-win.zip` for 153.0.8010.37 has the same SHA-256 as the GitHub file. See [Installing from a mirror](../mirrors.md).

[All packages](../../README.md#packages)
