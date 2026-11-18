# Ghidra

| | |
|---|---|
| Manifest | [`bucket/Ghidra.json`](../../bucket/Ghidra.json) |
| Upstream | [NationalSecurityAgency/ghidra](https://github.com/NationalSecurityAgency/ghidra) |
| Install | `scoop install gesu/Ghidra                   # needs JDK 25` |

Reverse engineering framework. Needs a 64-bit **JDK 25** (Ghidra 12.2's `application.java.min`; a JRE is not enough) on the `PATH` or in `JAVA_HOME`; the manifest [suggests](https://github.com/ScoopInstaller/Scoop/wiki/App-Manifests#optional-properties) `java/temurin25-jdk` from Scoop's [Java](https://github.com/ScoopInstaller/Java) bucket. Without one, the launcher asks for the JDK folder on first start and remembers it. Commands: `ghidraRun`, `analyzeHeadless`, `pyghidraRun` (Python 3.9–3.15 as `py` or `python`); sets `GHIDRA_INSTALL_DIR` for PyGhidra and extension builds. Settings are kept in the user's settings folder (shown in *Help → Runtime Information → Application Layout*), outside Scoop, so nothing is persisted. The version is Ghidra's own (`12.2`); the build date in the file name comes from `checkver` as `$matchReleasedate`. Autoupdate takes the SHA-256 that the NSA publishes in each release's notes; 12.2's matches GitHub's asset digest. The [Extras](https://github.com/ScoopInstaller/Extras) bucket has `ghidra` too: its version carries the build date (`12.2-20261016`), and it persists `Ghidra/Configurations`, which holds only the shipped `Public_Release` module, not user settings.

[All packages](../../README.md#packages)
