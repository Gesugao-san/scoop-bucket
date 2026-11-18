# Automation

GitHub Actions from Scoop's [BucketTemplate](https://github.com/ScoopInstaller/BucketTemplate), using [ScoopInstaller/GithubActions](https://github.com/ScoopInstaller/GithubActions):

| Workflow | Runs | Does |
|---|---|---|
| [`excavator.yml`](../.github/workflows/excavator.yml) | every 4 hours, or by hand ([see below](#running-workflows-by-hand)) | Runs `checkver` with autoupdate on every manifest and pushes new versions with their hashes straight to `main`, as `github-actions[bot]`. A second job, *Check TLS*, runs [`bin/Test-Tls.ps1`](../bin/Test-Tls.ps1) ([see below](#checking-tls)) |
| [`ci.yml`](../.github/workflows/ci.yml) | every push and PR | Scoop's Pester tests in Windows PowerShell and PowerShell 7: manifest schema and file style |
| [`issues.yml`](../.github/workflows/issues.yml) | new issues | Checks reports such as `app@1.2.3: hash check failed` and fixes the hash if it really changed |
| [`pull_request.yml`](../.github/workflows/pull_request.yml) | new PRs, `/verify` comments | Checks the changed manifests and posts the results |
| [`iph-watch.yml`](../.github/workflows/iph-watch.yml) | every 4 hours (at :50), or by hand | Checks a new EVE-IPH build with [`bin/Test-NetMetadata.ps1`](../bin/Test-NetMetadata.ps1) and opens a pull request with the update, or an issue when the check is red ([see below](#checking-eve-iph-builds)) |

Notes:

- The tests run on `bucket/` only ([`Scoop-Bucket.Tests.ps1`](../Scoop-Bucket.Tests.ps1)): Scoop's style tests read every file as text and would fail on the PNGs in `icons/` and `screenshots/`. The schema check is wider in CI: it takes every changed `*.json` in the repository, so JSON files that are not manifests must not be added anywhere.
- Manifests use Scoop's own format (4-space JSON) because Excavator rewrites a manifest with Scoop's formatter whenever it updates it. Run `.\bin\formatjson.ps1` after editing by hand.
- `.gitattributes` gives text files CRLF in working copies, which the tests require; the repository itself stores LF.
- GitHub turns off scheduled workflows in public repositories after 60 days without activity; re-enable Excavator on the Actions tab if that happens.
- [`bin/`](../bin) holds `Use-Mirror.ps1` ([see above](mirrors.md#installing-from-a-mirror)), `Test-Tls.ps1` ([see below](#checking-tls)), `Test-NetMetadata.ps1` ([see below](#checking-eve-iph-builds)) and the usual helper wrappers (`checkver.ps1`, `checkurls.ps1`, `checkhashes.ps1`, `formatjson.ps1`, `missing-checkver.ps1`, `auto-pr.ps1`, `test.ps1`) for running Scoop's maintainer scripts against this bucket locally.

## Running workflows by hand

Excavator and CI can be started from the [Actions tab](https://github.com/Gesugao-san/scoop-bucket/actions) (pick the workflow, then **Run workflow**) or with the [GitHub CLI](https://cli.github.com/):

```powershell
gh workflow run excavator.yml -R Gesugao-san/scoop-bucket
gh workflow run excavator.yml -R Gesugao-san/scoop-bucket -f force=NetTime,Privoxy
gh workflow run ci.yml -R Gesugao-san/scoop-bucket
gh run watch -R Gesugao-san/scoop-bucket
```

`force` lists manifests that Excavator re-downloads and re-hashes even when the version is unchanged, for when upstream replaces a file without a new version number. The issue and PR handlers have no manual run: they need the issue or PR that triggered them.

## Checking TLS

[`bin/Test-Tls.ps1`](../bin/Test-Tls.ps1) collects every host the manifests use (homepage, downloads, `checkver`, `autoupdate`) and the mirrors in `mirrors.psd1`, and opens a TLS handshake to each one through Schannel, the same TLS stack Scoop downloads with. It sends no HTTP request and does not check revocation.

| Status | Means |
|---|---|
| `FAIL` | no TCP connection, no TLS handshake, an expired certificate, or one Windows does not trust |
| `WARN` | plain HTTP, TLS older than 1.2, or a certificate that expires within 21 days (`-WarnDays`) |
| `OK` | everything else |

Excavator runs it as a separate job, *Check TLS*, every 4 hours: the table goes to the run summary, failures and warnings appear as annotations, and the job turns red when a host fails (Excavate itself is not affected). A GitHub runner is outside Russia, so comparing with a run on your own PC tells where a problem is: a host that fails on both is broken on its own side; a host that fails only at home is blocked or filtered on the way.

```powershell
.\bin\Test-Tls.ps1                                  # all hosts, as a table
.\bin\Test-Tls.ps1 TrueConf, Radmin-VPN | Format-List  # these apps only, all details
```

## Checking EVE-IPH builds

[`bin/Test-NetMetadata.ps1`](../bin/Test-NetMetadata.ps1) records what each .NET assembly can reach: referenced libraries, native DLLs and functions (P/Invoke), types and members used from other assemblies, string literals, and the IL size of every method; native files are recorded by SHA-256. It compares that with the approved snapshot in [`scripts/eve-iph/baseline.snapshot`](../scripts/eve-iph/baseline.snapshot) (JSON, named so that CI's schema check skips it):

| Level | Means |
|---|---|
| red | a new library, native DLL or native function; new use of networking, processes, the registry, dynamic code loading or code generation; a new string that looks like a URL, an IP address, a command or a registry path |
| yellow | more than 5 methods added, removed or resized in one assembly; a native file changed; a file appeared or disappeared |
| info | everything else that is new |

[`scripts/eve-iph/Watch-Upstream.ps1`](../scripts/eve-iph/Watch-Upstream.ps1) downloads a new build the way Scoop installs it and runs the check. `iph-watch.yml` turns a build without red findings into a pull request (branch `eve-iph/<version>`) with the report as its description, and a red one into an issue; nothing reaches `main` without a merge. Tried on the last three builds: 5.1.9669 → 9701 removed one method (`OnInitialize`, the minimum splash screen time), 9701 → 9721 resized one (`LoadPrices`), matching the release notes. The check cannot see harmful logic added inside an existing method without new strings or references; the method count is the only hint of that. It also does not cover EVE IPH's own updater, which pulls new builds straight from upstream on start. The workflow needs *Allow GitHub Actions to create and approve pull requests* (Settings → Actions → General).

```powershell
./bin/Test-NetMetadata.ps1 -Path (Get-ChildItem "$dir\*" -Include *.exe, *.dll).FullName -Baseline scripts/eve-iph/baseline.snapshot
./scripts/eve-iph/Watch-Upstream.ps1                 # report only
./scripts/eve-iph/Watch-Upstream.ps1 -Commit <sha>   # check a given LatestFiles commit
```
