---
name: scoop-bucket-add
description: Add a program to the gesu Scoop bucket (Gesugao-san/scoop-bucket): source research, manifest conventions, shortcuts, persist, conflict checks, autoupdate, testing and a UniGetUI icon.
---

# Adding a program to the gesu Scoop bucket

Bucket: [Gesugao-san/scoop-bucket](https://github.com/Gesugao-san/scoop-bucket), branch `main`, bucket name `gesu`.

Before starting, read:

- the bucket's [README](https://github.com/Gesugao-san/scoop-bucket/blob/HEAD/README.md) and [conventions](https://github.com/Gesugao-san/scoop-bucket/blob/HEAD/docs/conventions.md); every package has its own page in [`docs/packages/`](https://github.com/Gesugao-san/scoop-bucket/tree/HEAD/docs/packages);
- its [`.editorconfig`](https://github.com/Gesugao-san/scoop-bucket/blob/HEAD/.editorconfig);
- two or three existing manifests close to the new one, for example [`King-Arthurs-Gold.json`](https://github.com/Gesugao-san/scoop-bucket/blob/HEAD/bucket/King-Arthurs-Gold.json) (a choice made at install time, a launcher written at install time, a check for a copy installed outside Scoop) and [`jEveAssets.json`](https://github.com/Gesugao-san/scoop-bucket/blob/HEAD/bucket/jEveAssets.json) (a launcher, a check that the app is not running);
- the shared helpers in [`scripts/common/`](https://github.com/Gesugao-san/scoop-bucket/tree/HEAD/scripts/common);
- Scoop's [App Manifests](https://github.com/ScoopInstaller/Scoop/wiki/App-Manifests) reference, when a field is unclear.

## Language and length

- Talk to the user in the language and manner they asked for; follow their own instructions over this skill.
- Everything written into the bucket (manifests, `notes`, documentation, commit messages) is in English. Programs are installed in their English localisation where there is a choice.
- Match the destination: in this bucket, follow the existing package pages' level of detail. In other people's repositories (issues, pull requests, comments), be brief: a few lines on what changes and why, details only on request. Suggest, do not demand.
- Whenever this skill says "tell the user", do it in the reply that presents the manifest, not only in `notes`.

## 1. Research

1. **Source.** Prefer a source-code repository that publishes built binaries; if there are several, prefer GitHub Releases. Otherwise use the developer's site. If the official source is unreachable, say so and give the user options to choose from.
2. **Package facts.** The latest version; a direct download for every architecture upstream ships (Scoop's schema allows only `64bit`, `32bit` and `arm64`); the distribution type (archive, portable exe, Inno Setup / NSIS / MSI installer); the license; SHA256, checked against any hash upstream publishes.
3. **Existing packages.** Search all buckets at once on [scoop.sh](https://scoop.sh/) (or another search that covers all buckets). If that is unavailable, tell the user and check at least [main](https://github.com/ScoopInstaller/Main) and [extras](https://github.com/ScoopInstaller/Extras). Other manifests are reference material only: this bucket keeps its own manifest even when the package exists elsewhere. If the other manifest has a bug or is stuck on an old version, note it on the package page.
4. **Steam games.** Also check SteamDB (`https://steamdb.info/app/<appid>/`) and PCGamingWiki (`https://www.pcgamingwiki.com/wiki/<Title>`), for launch options and for where settings and saves live.
5. **Mirrors.** Look for mirrors, so the download can be split across several sources and threads with aria2. Add them to [`mirrors.psd1`](https://github.com/Gesugao-san/scoop-bucket/blob/HEAD/mirrors.psd1), which [`bin/Use-Mirror.ps1`](https://github.com/Gesugao-san/scoop-bucket/blob/HEAD/bin/Use-Mirror.ps1) reads.
6. **Network limits.** If the environment blocks a site needed for research, a check or a download, tell the user in the reply (not only in reasoning) and name the domain as eTLD+1, so they can allow it.
7. **Choices.** When the manifest can be built in more than one way, ask briefly before writing it. Typical cases: the program's name does not fit the naming rule below; portable, standalone or installed through another app (such as Steam); one package or one per edition; tracking releases or commits (say how far releases lag behind).

## 2. Manifest

### Naming

- **Manifest file:** `bucket/<Product-Name>.json` in kebab-case that keeps the product's own capitalisation (`NBT-Studio`, `King-Arthurs-Gold`, `jEveAssets`). A single-token or underscored upstream name stays as upstream spells it (`x64dbg`, `mtk_uartboot`). The reason is UniGetUI's `FormatAsName`, which builds the display name from the file name (see [Manifest names](https://github.com/Gesugao-san/scoop-bucket/blob/HEAD/docs/conventions.md#manifest-names)). The nearest general convention is Train-Case.
- **Everything else** is lowercase kebab-case, using the app ID that UniGetUI's `GenerateIconId` produces (`NBT-Studio` becomes `nbt-studio`): `scripts/<app-id>/`, `icons/<app-id>-*.png`, `screenshots/<app-id>-<n>.png`.
- **Formatting** follows `.editorconfig`: manifests use Scoop's 4-space JSON with CRLF, because Excavator rewrites them in that format.

### Fields and install method

- `version`, `description`, `homepage`, `license` (an [SPDX identifier](https://spdx.org/licenses/) with a link to the text; otherwise `LicenseRef-<Name>` with the text in [`licenses/`](https://github.com/Gesugao-san/scoop-bucket/tree/HEAD/licenses)).
- Downloads: top-level `url` + `hash` when there is one build for every machine; otherwise a separate `url` + `hash` for each architecture inside [`architecture`](https://github.com/ScoopInstaller/Scoop/wiki/App-Manifests#architecture).
- Prefer unpacking the installer to running it: [7-Zip](https://www.7-zip.org/) for archives and many installers, [innounp](https://innounp.sourceforge.net/) for Inno Setup (`"innosetup": true`), [lessmsi](https://github.com/activescott/lessmsi) for MSI. If it must run: silent switches, an `uninstaller`, a warning in `notes` and on the package page, and tell the user.
- **Dependencies:** `depends` for required ones, `suggest` for optional ones. Point to packages in this bucket (`gesu/<Package>`) when it has them.
- **Services and drivers:** global install only (`-g`); stop the app's processes and services in `pre_uninstall` (see [`scripts/common/Test-AppBusy.ps1`](https://github.com/Gesugao-san/scoop-bucket/blob/HEAD/scripts/common/Test-AppBusy.ps1)).
- **Autoupdate:** [`checkver` + `autoupdate`](https://github.com/ScoopInstaller/Scoop/wiki/App-Manifest-Autoupdate), extracting the hash when upstream publishes one, so the bucket's [Excavator workflow](https://github.com/Gesugao-san/scoop-bucket/blob/HEAD/.github/workflows/excavator-4h.yml) (based on [ScoopInstaller/GithubActions](https://github.com/ScoopInstaller/GithubActions)) keeps the package current. If autoupdate is impossible, explain why on the package page.

### Shortcuts

Every package gets a [shortcut](https://github.com/ScoopInstaller/Scoop/wiki/App-Manifests#shortcuts) in the Start menu's *Scoop Apps* folder, console tools included, so users can browse Scoop Apps to see what Scoop has installed.

- **GUI program:** a shortcut to its exe.
- **Console tool:** put it in `bin`, and also write a micro-launcher `<Product-Name>.cmd` into the app folder at install time (as `King-Arthurs-Gold` does) and point the shortcut at it. The micro-launcher says what the tool is, shows how to use it (its `--help` output or a short summary) and always ends with `PAUSE`, so the window stays open.
- **Micro-launcher style:** `@ECHO OFF`, commands in upper case, `::` comments, CRLF. Batch files have no shebang. Logic that does not fit in a `.cmd` goes into a `.ps1` that the `.cmd` micro-launcher calls: Scoop points the shortcut at the file itself, and opening a `.ps1` starts Notepad by default.

### User data (persist)

- Everything the program writes next to its exe (settings, profiles, databases, logs) goes into `persist`, so it survives updates and reinstalls; only `scoop uninstall -p` deletes it.
- If a persisted file is missing from the distribution, Scoop creates a **directory** with that name, and the program may fail to read or write it. Create such files in `pre_install` (not `post_install`) with sensible defaults, and tell the user.
- Data kept in AppData or the registry is not covered by `persist`: say so in `notes` and tell the user.
- In `notes`, never use `$dir`, `$persist_dir` or `$original_dir`: Scoop expands them to paths with the Windows user name. Write `%USERPROFILE%\scoop\persist\<Product-Name>` (or `...\apps\<Product-Name>\current`; `%ProgramData%\scoop\...` for global-only packages), and give commands to copy twice, for cmd (`%USERPROFILE%`) and PowerShell (`$env:USERPROFILE`). Every path printed by a hook or a script it calls (`warn`, `error`, `info`, `Write-Host`, `Write-Warning`) goes through `-replace [regex]::Escape($env:USERPROFILE), '%USERPROFILE%'`. See [Paths in notes and messages](https://github.com/Gesugao-san/scoop-bucket/blob/HEAD/docs/conventions.md#paths-in-notes-and-messages).

### Conflicts

- In `pre_install`, check (a) whether a mutually exclusive variant of this package is installed through Scoop (for example `MTKClient` and `MTKClient-Release`) and (b) whether the program is installed outside Scoop: Uninstall registry keys, known install paths, services (for example the check in `King-Arthurs-Gold` for a copy installed with the upstream MSI).
- On a conflict, stop with the bucket's pattern `error "<what was found and where, and what to do>"; break`. The message recommends either resolving the conflict or removing the leftovers (see below).
- `pre_install` also runs on `scoop update`, so the package's own Scoop install is never a conflict.
- **Bypass:** the bucket already has one shared variable for this, `$env:GESU_ALLOW_EXISTING = '1'` (see [Programs installed outside Scoop](https://github.com/Gesugao-san/scoop-bucket/blob/HEAD/docs/conventions.md#programs-installed-outside-scoop)); do not add a variable per package. Offer the bypass only where Scoop can safely take the existing copy over (`NetTime` has none: its own installer registers a service a Scoop copy cannot share). Mention it in the error message and on the package page.
- **The cost of stopping:** `pre_install` runs after the download and extraction, so a stop leaves `apps/<app>/<version>` and the cached download behind, and Scoop treats the install as failed (`scoop list` reports it as not installed correctly). The next `scoop install` purges it automatically, or `scoop uninstall <app>` does. Say this in the error message.

## 3. Icon and screenshots for UniGetUI

Ask the user whether to add an icon (recommend it). The format and the pull request follow [Devolutions/UniGetUI#5539](https://github.com/Devolutions/UniGetUI/pull/5539) (NBT Studio) and the bucket's [icons page](https://github.com/Gesugao-san/scoop-bucket/blob/HEAD/docs/icons.md).

- Prefer the original icon: a square 192x192 PNG with a transparent background, scaled with nearest neighbour for pixel art and Lanczos otherwise, saved as `icons/<app-id>-192.png`.
- If there is no usable original, draw a clean, minimalist original SVG (`icons/<app-id>-alt.svg`) with a 192x192 PNG render (`icons/<app-id>-alt.png`). Commit the script that writes the SVG and renders the PNG too (in `scripts/<app-id>/`), so the icon can be rebuilt or adjusted later. Example: [`nbt-studio-alt.svg`](https://github.com/Gesugao-san/scoop-bucket/blob/HEAD/icons/nbt-studio-alt.svg), redrawn in the spirit of NBT Studio's 16x16 pixel-art icon (same isometric blue book and palette, new artwork). No third-party logos or trademarks.
- Record the source and license of each file in the table on the [icons page](https://github.com/Gesugao-san/scoop-bucket/blob/HEAD/docs/icons.md).
- Screenshots only with the user's consent, and only real ones of the program: `screenshots/<app-id>-<n>.png`.
- Any image that a Markdown page of the bucket shows (README, docs, `misc/`) must get past ad blockers: run `python bin/check-adblock.py` before committing; it must print no `BLOCKED`. Ad-blocking lists hide images by a piece of their URL on any site, GitHub included (RU AdList hides every `/banner.gif`), so keep words such as *banner*, *ad*, *ads*, *advert*, *promo*, *sponsor*, *popup* and *tracking* out of image paths, and rename the file on a hit. Lists the script cannot download are skipped with a warning; run it where they are reachable.
- After the files are in the bucket's `main`, open a pull request to [Devolutions/UniGetUI](https://github.com/Devolutions/UniGetUI) adding the app ID to [`WebBasedData/screenshot-database-v2.json`](https://github.com/Devolutions/UniGetUI/blob/main/WebBasedData/screenshot-database-v2.json). Fill in the checklist, say in a few lines what the files are, and confirm that every URL returns `200 image/png`.

## 4. Testing

Run the bucket's wrappers in [`bin/`](https://github.com/Gesugao-san/scoop-bucket/tree/HEAD/bin) from the bucket root on Windows, with Scoop installed:

1. **Format and schema:** `.\bin\formatjson.ps1 <Package>` (Scoop's own formatting), then `.\bin\test.ps1` (needs Pester 5 and BuildHelpers; it runs Scoop's schema and file-style tests on `bucket/`).
2. **URLs:** `.\bin\checkurls.ps1 <Package>`: every download URL answers.
3. **Hashes:** `.\bin\checkhashes.ps1 <Package>`: downloads the files and compares them with the manifest.
4. **Version check:** `.\bin\checkver.ps1 <Package>` finds the current version; `.\bin\missing-checkver.ps1` lists manifests without `checkver` or `autoupdate`.
5. **Autoupdate:** on a scratch branch, `.\bin\checkver.ps1 <Package> -ForceUpdate`; the rewritten `url` and `hash` must be correct (inspect `git diff`), then discard the change.
6. **TLS:** `.\bin\Test-Tls.ps1 -App <Package>`: every host the manifest uses has a valid certificate (see [Checking TLS](https://github.com/Gesugao-san/scoop-bucket/blob/HEAD/docs/automation.md#checking-tls)).
7. **VirusTotal:** check the download once (`https://www.virustotal.com/gui/file/<sha256>`) and report the result to the user; if there are notable detections, mention them on the package page.
8. **PowerShell code** in hooks and scripts: pwsh 7 and PSScriptAnalyzer. If pwsh is missing (for example on Linux), download the release archive directly (`https://github.com/PowerShell/PowerShell/releases/download/v<ver>/powershell-<ver>-linux-x64.tar.gz`) and install the linter with `Install-PSResource PSScriptAnalyzer -TrustRepository`.

Without Windows, do steps 1 to 6 by hand as far as possible: parse the JSON, request each URL and check the status code and content type, download each file and compare its SHA256, apply the `checkver` regex to the fetched page. Windows behaviour (install, shortcuts, micro-launchers, persist, conflict checks, services) cannot be tested outside Windows. Say so plainly and ask the user to run `scoop install gesu/<Package>`, open it from Scoop Apps, then `scoop update <Package>` and `scoop uninstall <Package>`.

## 5. Finishing

- Write the package page `docs/packages/<app-id>.md` (manifest, upstream, install command, then the notes; follow an existing page), add a row with a short *About* to the table of the package's category (or subcategory, as under *Games*) in the README's *Packages* section and its install line to that category's code block (one category per package, under what it is rather than what it serves: every driver goes to *Drivers* and every database to *Databases*, whatever they are for; a new category only when no existing one fits, also added to the README's *Contents*), and add new mirrors to `mirrors.psd1` (see [Installing from a mirror](https://github.com/Gesugao-san/scoop-bucket/blob/HEAD/docs/mirrors.md)).
- Commit according to the user's own rules; never push without their explicit consent.
- Summarise: what was added, which choices were made, what the user should check on Windows, and whether an icon pull request is pending.
