# Automation

GitHub Actions from Scoop's [BucketTemplate](https://github.com/ScoopInstaller/BucketTemplate), using [ScoopInstaller/GithubActions](https://github.com/ScoopInstaller/GithubActions):

| Workflow | Runs | Does |
|---|---|---|
| [`excavator-4h.yml`](../.github/workflows/excavator-4h.yml) | every 4 hours at :20 (00:20 UTC, 04:20 …), or by hand ([see below](#running-workflows-by-hand)) | Runs `checkver` with autoupdate on the manifests of the Frequent tier ([see below](#update-tiers)) and pushes new versions with their hashes straight to `main`, as `github-actions[bot]` |
| [`excavator-1d.yml`](../.github/workflows/excavator-1d.yml) | once a day (00:10 UTC), or by hand | The same for the Daily tier: manifests without a new version for 30 days ([see below](#update-tiers)) |
| [`excavator-1mo.yml`](../.github/workflows/excavator-1mo.yml) | the 1st of each month (00:40 UTC), or by hand | Checks the EOL tier, sends updated packages back, opens issues for manual updates, and moves packages without a new version for a year into it ([see below](#update-tiers)) |
| [`security.yml`](../.github/workflows/security.yml) | once a day (00:00 UTC), or by hand ([see below](#running-workflows-by-hand)) | Runs [`bin/Test-Tls.ps1`](../bin/Test-Tls.ps1) on every host the manifests use ([see below](#checking-tls)) |
| [`ci.yml`](../.github/workflows/ci.yml) | every push and PR | Scoop's Pester tests in Windows PowerShell and PowerShell 7: file style of `bucket/`, schema of the manifests that changed |
| [`issues.yml`](../.github/workflows/issues.yml) | new issues | Checks reports such as `app@1.2.3: hash check failed` and fixes the hash if it really changed |
| [`pull_request.yml`](../.github/workflows/pull_request.yml) | new PRs, `/verify` comments | Checks the changed manifests and posts the results |
| [`iph-watch.yml`](../.github/workflows/iph-watch.yml) | every 4 hours at :30 (00:30 UTC, 04:30 …), or by hand | Checks a new EVE-IPH build with [`bin/Test-NetMetadata.ps1`](../bin/Test-NetMetadata.ps1) and opens a pull request with the update, or an issue when the check is red ([see below](#checking-eve-iph-builds)) |

The scheduled runs are spread over 00:00-00:40 UTC (03:00-03:40 Moscow time), daily ones first: Security :00 (it can wait best, and :00 is the minute GitHub delays most), Excavator 1d :10, Excavator 4h :20 (then every 4 hours), EVE-IPH watch :30 (every 4 hours), Excavator 1mo :40 (the 1st). GitHub often starts scheduled runs late, by minutes up to half an hour; the two Excavators that update share a concurrency group, so a late one waits for the other instead of racing it.

Notes:

- The tests run on `bucket/` only ([`Scoop-Bucket.Tests.ps1`](../Scoop-Bucket.Tests.ps1)): Scoop's style tests read every file as text and would fail on the PNGs in `icons/` and `screenshots/`. The schema check covers only the manifests in `bucket/` that changed since the commit before the push (or the base of a pull request), across all commits of the push; when nothing in `bucket/` changed, it does not run. Without that base commit (a local run, a run by hand) it checks every manifest. Scoop's own version checks the `*.json` files changed in the last commit only, anywhere in the repository, which misses earlier commits of a push and treats data files such as [`hosts.json`](research/tixati-software/hosts.json) as manifests; [`Scoop-Bucket.Tests.ps1`](../Scoop-Bucket.Tests.ps1) does the check itself instead. JSON data files outside `bucket/` are fine.
- Manifests use Scoop's own format (4-space JSON) because Excavator rewrites a manifest with Scoop's formatter whenever it updates it. Run `.\bin\formatjson.ps1` after editing by hand.
- `.gitattributes` gives text files CRLF in working copies, which the tests require; the repository itself stores LF.
- GitHub turns off scheduled workflows in public repositories after 60 days without activity; re-enable Excavator on the Actions tab if that happens.
- [`bin/`](../bin) holds `Use-Mirror.ps1` ([see above](mirrors.md#installing-from-a-mirror)), `Test-Tls.ps1` ([see below](#checking-tls)), `Test-NetMetadata.ps1` ([see below](#checking-eve-iph-builds)), `Watch-Tiers.ps1` ([see below](#update-tiers)) and the usual helper wrappers (`checkver.ps1`, `checkurls.ps1`, `checkhashes.ps1`, `formatjson.ps1`, `missing-checkver.ps1`, `auto-pr.ps1`, `test.ps1`) for running Scoop's maintainer scripts against this bucket locally.

## Running workflows by hand

The three Excavators, Security and CI can be started from the [Actions tab](https://github.com/Gesugao-san/scoop-bucket/actions) (pick the workflow, then **Run workflow**) or with the [GitHub CLI](https://cli.github.com/):

```powershell
gh workflow run excavator-4h.yml -R Gesugao-san/scoop-bucket
gh workflow run excavator-1d.yml -R Gesugao-san/scoop-bucket
gh workflow run excavator-4h.yml -R Gesugao-san/scoop-bucket -f force=NetTime,Privoxy
gh workflow run security.yml -R Gesugao-san/scoop-bucket
gh workflow run excavator-1mo.yml -R Gesugao-san/scoop-bucket
gh workflow run excavator-1mo.yml -R Gesugao-san/scoop-bucket -f dry_run=true
gh workflow run security.yml -R Gesugao-san/scoop-bucket -f app=PlanetSide-2*
gh workflow run ci.yml -R Gesugao-san/scoop-bucket
gh run watch -R Gesugao-san/scoop-bucket
```

`force` lists manifests that Excavator re-downloads and re-hashes even when the version is unchanged, for when upstream replaces a file without a new version number. `app` limits the Security run's TLS check to these manifests (comma-separated, wildcards allowed). `dry_run` makes the Excavator 1mo run only report: no change to `update-tiers.json`, no issues, no Excavator run. Each Excavator sees only the manifests of its own tier, so `force` works for those only: force a Daily package in Excavator 1d; for an EOL package, run Excavator 1mo or take it out of the EOL list. The issue and PR handlers have no manual run: they need the issue or PR that triggered them.

## Update tiers

Checking every manifest every 4 hours wastes work on packages whose upstream rarely releases, so each manifest belongs to one of three tiers, checked on its own schedule. [`bin/Watch-Tiers.ps1`](../bin/Watch-Tiers.ps1) decides the tier and moves packages between tiers in both directions; the settings and the EOL list are in [`update-tiers.json`](../update-tiers.json).

| Tier | Checked by | Which manifests |
|---|---|---|
| Frequent | `excavator-4h.yml`, every 4 hours | version changed less than `dailyAfterDays` days ago (30), names in `keepInExcavator`, and manifests without history yet |
| Daily | `excavator-1d.yml`, 00:10 UTC | every other manifest that is not EOL |
| EOL | `excavator-1mo.yml`, the 1st of each month | the manifests listed under `eol` |

Frequent and Daily are worked out from git history on every run and need no bookkeeping. The age of a version is the time since the last commit that changed the manifest's `version` value: the script compares the value commit by commit, following renames, so a commit that only reformats or renames a manifest does not count, and a new manifest counts from the commit that added it (even when git takes its content for a copy of another manifest). Both Excavators therefore check out the full history.

| Move | When | Rule |
|---|---|---|
| Frequent → Daily | any Excavator run | 30 days pass without a new version: the 4-hour run stops seeing the package, the daily one starts. |
| Daily → Frequent | the daily run that finds a new version | It updates the package like Excavator always does; the version is new, so the next 4-hour run takes it over. |
| Daily → EOL | `excavator-1mo.yml` | A manifest with `checkver` whose version has not changed for `eolAfterDays` days (365) is listed under `eol` with the date and the reason, unless it is in `keepInExcavator` or came back from EOL less than `eolAfterDays` days ago (`returned`), so a package whose update the daily run cannot finish does not bounce every month. |
| EOL → Daily | `excavator-1mo.yml` | Scoop's `checkver` runs on each EOL manifest. A new version of a manifest with `autoupdate` takes it off the list (recorded in `returned`), and the workflow starts Excavator 1d right away, which updates it; after that the package is Frequent. |
| stays EOL | `excavator-1mo.yml` | A new version of a manifest without `autoupdate` cannot be applied by a bot: the package stays listed, and an issue titled `<name>: new version <version> (no autoupdate)` asks for a manual update (one per version; an open one is not repeated). A `checkver` error (site down, page changed) is a warning in the run summary. A listed manifest that no longer exists is dropped. |

How each Excavator sees only its own tier: its first step runs `Watch-Tiers.ps1 -Hide -Tier <tier>`, which removes every other manifest from the working copy with git's sparse checkout (`/*`, `/bucket/**`, then `!/bucket/<name>.json` for each hidden one, passed through stdin). Scoop's `checkver` only sees the files that are there, and git marks the hidden ones as skipped, not deleted, so `auto-pr` neither checks nor commits them, while pulling, rebasing and pushing work as usual, also when someone changes a hidden manifest in the meantime. The two Excavators share a concurrency group, so they never run at the same time. Nothing else changes: CI, the issue and PR handlers, and the Security check still see every manifest.

`update-tiers.json` is written by Excavator 1mo (as `github-actions[bot]`, one commit per run, listing what moved) and can be edited by hand: list a package under `eol` with a note, or put its name in `keepInExcavator` to keep it on the 4-hour schedule however long it goes without a release.

| Field | Means |
|---|---|
| `dailyAfterDays` | days without a new version before a package moves from Frequent to Daily (30) |
| `eolAfterDays` | days without a new version before a package becomes EOL (365) |
| `keepInExcavator` | names that always stay Frequent |
| `eol` | the EOL packages: name → `date: reason` |
| `returned` | packages sent back from EOL: name → date; protects them from becoming EOL again for `eolAfterDays` days |

```powershell
.\bin\Watch-Tiers.ps1                              # every manifest with its tier and the age of its version
.\bin\Watch-Tiers.ps1 -Check -Demote -WhatIf       # what the monthly run would change, without writing update-tiers.json
.\bin\Watch-Tiers.ps1 -Check                       # check the EOL packages now
```

## Checking TLS

[`bin/Test-Tls.ps1`](../bin/Test-Tls.ps1) collects every host the manifests use (homepage, downloads, `checkver`, `autoupdate`) and the mirrors in `mirrors.psd1`, and opens a TLS handshake to each one through Schannel, the same TLS stack Scoop downloads with. It sends no HTTP request and does not check revocation.

| Status | Means |
|---|---|
| `FAIL` | no TCP connection, no TLS handshake, an expired certificate, or one Windows does not trust |
| `WARN` | plain HTTP, TLS older than 1.2, or a certificate that expires within 21 days (`-WarnDays`) |
| `OK` | everything else |

The *Security* workflow runs it once a day: the table goes to the run summary, failures and warnings appear as annotations, and the run turns red when a host fails. It is a workflow of its own, not a job in Excavator, so a failure shows up as "Security failed" (in GitHub's notifications too) and never as "Excavator failed". There the timeout is 30 s (`-TimeoutSec`, 15 s by default), and a host that gives no connection or no handshake is tried 2 more times, 60 s apart (`-Retries`, `-RetryDelaySec`), because a single dropped connection from a runner is common; the note says when a host needed a retry. Certificates are warned about 21 days ahead, so once a day is enough. A GitHub runner is outside Russia, so comparing with a run on your own PC tells where a problem is: a host that fails on both is broken on its own side; a host that fails only at home is blocked or filtered on the way.

```powershell
.\bin\Test-Tls.ps1                                  # all hosts, as a table
.\bin\Test-Tls.ps1 TrueConf, Radmin-VPN | Format-List  # these apps only, all details
.\bin\Test-Tls.ps1 PlanetSide-2* -Retries 2            # retry hosts that do not answer
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
