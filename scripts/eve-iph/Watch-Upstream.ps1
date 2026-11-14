#Requires -Version 7
<#
.SYNOPSIS
  Checks EVE IPH upstream for a new build, inspects it with bin/Test-NetMetadata.ps1 and, if nothing
  alarming turns up, updates bucket/EVE-IPH.json and the approved baseline.

.DESCRIPTION
  EVE IPH builds are uploaded by hand to github.com/EVEIPH/LatestFiles, without source for the newest
  versions and without a signature, so Excavator does not update this package (the manifest has no
  autoupdate). The iph-watch workflow runs this script instead:

    1. Finds the newest LatestFiles commit that changed LatestVersionIPH.xml and the version of
       "EVE Isk per Hour.exe" in it. Same version as the manifest: nothing to do.
    2. Downloads the three files the manifest installs, pinned to that commit, and lays them out the
       way Scoop would (the zip, then the newer exe on top).
    3. Compares every .exe and .dll with scripts/eve-iph/baseline.snapshot using Test-NetMetadata.ps1.
    4. With -Apply and no red finding: writes the new commit, version and hashes into the manifest and
       the new snapshot into the baseline. The workflow then opens a pull request; on a red finding it
       opens an issue instead. Nothing reaches main without a person merging it.

  Results go to GITHUB_OUTPUT when it is set: status (uptodate, approved, blocked), version, commit,
  report (path of the Markdown report).

.PARAMETER Manifest
  Path of the manifest to check and update.

.PARAMETER Baseline
  Path of the approved metadata snapshot.

.PARAMETER WorkDir
  Scratch folder for downloads; created if needed.

.PARAMETER Commit
  Check this LatestFiles commit instead of the newest one (for a manual re-check or a test).

.PARAMETER Apply
  Update the manifest and the baseline when the check passes. Without it the script only reports.

.EXAMPLE
  ./scripts/eve-iph/Watch-Upstream.ps1 -Apply
#>

[CmdletBinding()]
param(
  [string] $Manifest = (Join-Path $PSScriptRoot '../../bucket/EVE-IPH.json'),

  [string] $Baseline = (Join-Path $PSScriptRoot 'baseline.snapshot'),

  [string] $WorkDir = (Join-Path ([System.IO.Path]::GetTempPath()) 'eve-iph-watch'),

  [string] $Commit,

  [switch] $Apply
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$repo = 'EVEIPH/LatestFiles'
$mainExe = 'EVE Isk per Hour.exe'
$checker = Join-Path $PSScriptRoot '../../bin/Test-NetMetadata.ps1'

# The files the manifest installs, in the order of its url and hash arrays.
$files = @('EVEIPH Binaries.zip', $mainExe, 'LatestVersionIPH.xml')

<#
.SYNOPSIS
  Writes key=value to GITHUB_OUTPUT (when running in Actions) and to the log.
#>
function Set-Output([string] $Name, [string] $Value) {
  Write-Host "$Name=$Value"
  if ($env:GITHUB_OUTPUT) { "$Name=$Value" | Add-Content -LiteralPath $env:GITHUB_OUTPUT }
}

<#
.SYNOPSIS
  Raw URL of a file in LatestFiles at a given commit.
#>
function Get-RawUrl([string] $Commit, [string] $Name) {
  "https://raw.githubusercontent.com/$repo/$Commit/$([uri]::EscapeDataString($Name))"
}

<#
.SYNOPSIS
  Newest commit that touched LatestVersionIPH.xml, and the main exe version listed in it.
#>
function Get-Upstream([string] $Pinned) {
  $commit = $Pinned
  if (!$commit) {
    $headers = @{ Accept = 'application/vnd.github+json' }
    if ($env:GITHUB_TOKEN) { $headers.Authorization = "Bearer $env:GITHUB_TOKEN" }
    $commit = @(Invoke-RestMethod -Headers $headers "https://api.github.com/repos/$repo/commits?path=LatestVersionIPH.xml&per_page=1")[0].sha
  }
  $list = [xml](Invoke-WebRequest (Get-RawUrl $commit 'LatestVersionIPH.xml')).Content
  $row = $list.SelectSingleNode("//row[@Name='$mainExe']")
  if (!$row) { throw "LatestVersionIPH.xml at $commit lists no '$mainExe'." }

  [PSCustomObject]@{ Commit = $commit; Version = $row.Version }
}

<#
.SYNOPSIS
  Downloads the pinned files, lays them out like a Scoop install and returns their SHA-256 hashes.
#>
function Get-Build([string] $Commit, [string] $Folder) {
  Remove-Item -LiteralPath $Folder -Recurse -Force -ErrorAction SilentlyContinue
  $download = New-Item -ItemType Directory -Force -Path (Join-Path $Folder 'download')
  $app = New-Item -ItemType Directory -Force -Path (Join-Path $Folder 'app')

  $hashes = foreach ($name in $files) {
    $target = Join-Path $download $name
    Invoke-WebRequest (Get-RawUrl $Commit $name) -OutFile $target
    (Get-FileHash -LiteralPath $target -Algorithm SHA256).Hash.ToLowerInvariant()
  }

  Expand-Archive -LiteralPath (Join-Path $download $files[0]) -DestinationPath $app
  Copy-Item -LiteralPath (Join-Path $download $mainExe) -Destination $app -Force

  [PSCustomObject]@{ App = $app.FullName; Hashes = @($hashes) }
}

<#
.SYNOPSIS
  Rewrites commit, version and hashes in the manifest text, keeping its formatting.
#>
function Update-Manifest([string] $Path, $Old, [string] $Commit, [string] $Version, [string[]] $Hashes) {
  $text = Get-Content -Raw -LiteralPath $Path
  $text = $text.Replace($Old.Commit, $Commit)
  $text = $text.Replace("`"version`": `"$($Old.Version)`"", "`"version`": `"$Version`"")
  for ($i = 0; $i -lt $Hashes.Count; $i++) { $text = $text.Replace($Old.Hashes[$i], $Hashes[$i]) }
  Set-Content -LiteralPath $Path -Value $text -NoNewline -Encoding utf8NoBOM
}

# --- main ---

$current = Get-Content -Raw -LiteralPath $Manifest | ConvertFrom-Json
$currentCommit = [regex]::Match($current.url[0], '[0-9a-f]{40}').Value
if (!$currentCommit) { throw "No pinned commit in the first url of '$Manifest'." }
$old = [PSCustomObject]@{ Commit = $currentCommit; Version = $current.version; Hashes = @($current.hash) }

$upstream = Get-Upstream $Commit
Set-Output 'version' $upstream.Version
Set-Output 'commit' $upstream.Commit

if ($upstream.Version -eq $old.Version) {
  Write-Host "EVE IPH $($old.Version) is current (upstream commit $($upstream.Commit))."
  Set-Output 'status' 'uptodate'
  exit 0
}

Write-Host "EVE IPH $($old.Version) -> $($upstream.Version) (commit $($upstream.Commit))"
$build = Get-Build $upstream.Commit $WorkDir

$binaries = Get-ChildItem -LiteralPath $build.App -File | Where-Object Extension -In '.exe', '.dll'
$snapshot = Join-Path $WorkDir 'snapshot.json'
$report = Join-Path $WorkDir 'report.md'
& $checker -Path $binaries.FullName -Baseline $Baseline -SnapshotFile $snapshot -ReportFile $report
$checkExit = $LASTEXITCODE
if ($checkExit -ge 2) { throw "Test-NetMetadata.ps1 failed with exit code $checkExit." }

$header = "EVE IPH $($old.Version) -> $($upstream.Version), [LatestFiles@$($upstream.Commit.Substring(0, 7))](https://github.com/$repo/commit/$($upstream.Commit))`n`n"
Set-Content -LiteralPath $report -Value ($header + (Get-Content -Raw -LiteralPath $report)) -Encoding utf8NoBOM
Set-Output 'report' $report

if ($checkExit -eq 1) {
  Set-Output 'status' 'blocked'
  exit 0
}

if ($Apply) {
  Update-Manifest $Manifest $old $upstream.Commit $upstream.Version $build.Hashes
  Copy-Item -LiteralPath $snapshot -Destination $Baseline -Force
  Write-Host "Updated '$Manifest' and '$Baseline'."
}
Set-Output 'status' 'approved'

