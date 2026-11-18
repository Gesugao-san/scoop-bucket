# bin

Maintainer scripts, run from the bucket root.

| Script | Does |
|---|---|
| [`Use-Mirror.ps1`](Use-Mirror.ps1) | Puts a download from a mirror into Scoop's cache, see [Installing from a mirror](../docs/mirrors.md) |
| [`Test-Tls.ps1`](Test-Tls.ps1) | Checks TLS of every host the manifests use, see [Checking TLS](../docs/automation.md#checking-tls) |
| [`Test-NetMetadata.ps1`](Test-NetMetadata.ps1) | Compares .NET assemblies with a snapshot, see [Checking EVE-IPH builds](../docs/automation.md#checking-eve-iph-builds) |
| [`update-host-notes.py`](update-host-notes.py) | Refreshes the host survey in [`docs/research/`](../docs/research/README.md) |
| `checkver.ps1`, `checkurls.ps1`, `checkhashes.ps1`, `formatjson.ps1`, `missing-checkver.ps1`, `auto-pr.ps1`, `test.ps1` | Wrappers that run Scoop's own maintainer scripts and tests against this bucket |

[Back to the main README](../README.md)
