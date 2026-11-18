# UltraDefrag

| | |
|---|---|
| Manifest | [`bucket/UltraDefrag.json`](../../bucket/UltraDefrag.json) |
| Upstream | [SourceForge](https://sourceforge.net/projects/ultradefrag/) (GPL, last open source release) |
| Install | `scoop install gesu/UltraDefrag              # runs elevated (UAC prompt)` |

Disk defragmenter: files, folders, the MFT and other NTFS metafiles; full or quick optimization sorts small files by path, size, creation, modification or access time. **7.1.4 (2020) is the last open source release**: version 8 and later are proprietary and paid ([ultradefrag.net](https://ultradefrag.net)) and are not packaged; the authors say 7.x will most likely get no more updates. Uses the official portable zips (x64 and x86). Both `ultradefrag.exe` (GUI) and `udefrag.exe` (command line, the `udefrag` command) ask for admin rights (UAC) on every start. The GUI reads `gui.ini`, `conf\options.lua` and `logs` relative to the **current folder** (portable mode in [`main.cpp`](https://sourceforge.net/projects/ultradefrag/files/stable-release/7.1.4/ultradefrag-7.1.4.src.7z) opens `gui.ini` with `wxCONFIG_USE_RELATIVE_PATH`), so it gets only the *UltraDefrag* shortcut, which Scoop starts in the app folder, and no command. `conf` (with `options.lua`) is persisted as a folder. `gui.ini` holds the window, sorting, language and update-check settings; wxFileConfig saves it through a temporary file and a rename, which would break a hardlink, so it is copied to the persist folder in `pre_uninstall` (which also runs on update) and back in `pre_install`. On the first install `gui.ini` is created with *Help → Upgrade* set to *Never check* (`[Upgrade] Level=0`): the check would only advertise the paid versions. No boot-time defragmentation and no Explorer context menu: the portable build has neither; they come with the regular installer. Hashes match the SHA-1 and MD5 that SourceForge lists for both zips. License: the source headers say "version 2 of the License, or (at your option) any later version", hence `GPL-2.0-or-later`. Not in the [Extras](https://github.com/ScoopInstaller/Extras) bucket.

[All packages](../../README.md#packages)
