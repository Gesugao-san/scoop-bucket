# EVE-IPH

| | |
|---|---|
| Manifest | [`bucket/EVE-IPH.json`](../../bucket/EVE-IPH.json) |
| Upstream | [EVEIPH/LatestFiles](https://github.com/EVEIPH/LatestFiles) (EVEIPH, no license stated) |

EVE Isk per Hour, an industry calculator for EVE Online. Upstream uploads its builds by hand to LatestFiles, with no source for the newest versions and no signature, and its zip often carries an older main program than the separate exe: the manifest pins all three files (zip, exe, `LatestVersionIPH.xml`) to one LatestFiles commit and puts the newer exe on top. Runs as if installed: with no database next to the exe, EVE IPH keeps its database, settings, ESI logins and its own updater in `%APPDATA%\EVE IPH`, which `pre_install` seeds once and never overwrites, so updates do not touch the user's data (a hard link to a persisted database would break, because EVE IPH's updater replaces the file). EVE IPH still updates itself on start, straight from upstream. Excavator does not update this manifest (no `autoupdate`); [`iph-watch.yml`](../../.github/workflows/iph-watch.yml) checks each new build first ([see below](../automation.md#checking-eve-iph-builds)).

[All packages](../../README.md#packages)
