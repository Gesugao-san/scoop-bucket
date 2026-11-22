# Pomme

| | |
|---|---|
| Manifest | [`bucket/Pomme.json`](../../bucket/Pomme.json) |
| Upstream | [PommeMC/Client](https://github.com/PommeMC/Client) (GPL-3.0-or-later) |
| Install | `scoop install gesu/Pomme` |

A Minecraft: Java Edition client written from scratch in Rust, drawing with Vulkan. It joins vanilla servers from 1.20 to 26.3, signs in with a Microsoft account (you need to own Java Edition), and runs singleplayer worlds on [SteelMC](steelmc.md), a Rust server built into the client. On first start it downloads Minecraft's own assets (textures, sounds, the version JSON) from Mojang. It runs no Java mods, so modded servers (Forge, NeoForge, Fabric) are out of reach. Upstream says it is in active development: expect missing features and bugs.

Downloads `pomme-client-windows-x64.zip` from the GitHub release: the same `pomme-client.exe` that upstream's Inno Setup installer (`pomme-client-windows-x64-setup.exe`) wraps, and the file Pomme's own updater downloads. Autoupdate takes the hash from the release's `sha256sums.txt`. Releases are tagged `client-v<version>+<Minecraft version>` (`client-v0.2.12+26.2`); the manifest keeps the client version and rebuilds the tag from the `checkver` match. Weekly releases come out on Sundays; the rolling `nightly` prerelease is not tracked. Upstream ships x64 only for Windows. No mirror: upstream publishes only on GitHub. The builds are not code-signed yet, so SmartScreen may warn on the first start (More info > Run anyway).

## Updates

Pomme updates itself on start: it downloads the newest release zip and replaces its own exe. In the Scoop folder that would leave Scoop's version number behind the real one, so the *Scoop Apps* shortcut passes `--no-update` (upstream's switch for starting a build as it is, [`args.rs`](https://github.com/PommeMC/Client/blob/HEAD/pomme-client/src/args.rs)). Update with `scoop update Pomme`. Started another way (the exe directly, a pinned taskbar icon of the window), Pomme still updates itself; the next `scoop update` puts Scoop's copy back in charge. There is no `bin` command for the same reason.

## Data

Everything lives in `%LOCALAPPDATA%\Pomme` ([`pomme-dirs`](https://github.com/PommeMC/Client/blob/HEAD/pomme-dirs/src/lib.rs)): Mojang's assets and version files (`minecraft\`), profiles with options, server list, saves, resource and shader packs (`profiles\`), and a rebuildable cache. It is outside the Scoop folder, so `persist` does not cover it, updates keep it, and `scoop uninstall -p` does not delete it. The Microsoft sign-in is kept in Windows Credential Manager. Pomme also moves an old `.pomme` folder from its former launcher into this layout on start.

## Copies installed without Scoop

A fresh install stops if Pomme is already installed with upstream's installer (uninstall entry `{22F91093-7D94-4FA4-9045-1F5CBA3D82D5}_is1`, per user in `%LOCALAPPDATA%\Programs\Pomme`). Uninstall that copy in Settings > Apps first; the data in `%LOCALAPPDATA%\Pomme` stays. To keep both copies, run `$env:GESU_ALLOW_EXISTING = '1'` and install again (see [Programs installed outside Scoop](../conventions.md#programs-installed-outside-scoop)): Scoop does not take that copy over, the two just share the data folder, so do not run them at the same time. When the install stops, Scoop has already downloaded and unpacked the package: `scoop uninstall Pomme`, or simply installing again, cleans that up.

[All packages](../../README.md#packages)
