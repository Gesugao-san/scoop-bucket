<#
.SYNOPSIS
  Sorts the bucket's manifests into three update schedules (live, dormant, EOL) and moves them
  between the schedules in both directions.

.DESCRIPTION
  Checking every manifest every 4 hours is wasted work for packages whose upstream rarely releases.
  Each manifest therefore belongs to one tier:

    Frequent  Excavator 4h, every 4 hours: the "version" line changed less than dailyAfterDays days ago
              (update-tiers.json, default 30), or the name is in keepInExcavator, or the manifest
              has no history yet.
    Daily     Excavator 1d, 00:10 UTC: everything else that is not EOL.
    EOL       Excavator 1mo, the 1st of each month: the manifests listed in update-tiers.json under 'eol'.

  Frequent and Daily are computed from git history on every run, so they need no bookkeeping: when
  the daily run updates a package, its version changes and the next 4-hour run takes it over. Only
  the EOL list is stored. The actions:

    -Hide -Tier X  Excavator's first step: removes every manifest outside tier X from the working
                   copy with git's sparse checkout, so checkver does not see them and git reports no
                   change for them.
    -Check         Monthly: runs Scoop's checkver on each EOL manifest. A new version of a manifest
                   with autoupdate takes it off the list into 'returned' (so it lands in the Daily
                   tier, and the workflow starts Excavator 1d); without autoupdate it stays
                   listed and, with -OpenIssues, an issue asks for a manual update.
    -Demote        Monthly: lists every manifest with checkver whose version has not changed for
                   eolAfterDays days (default 365), except keepInExcavator and packages returned
                   less than eolAfterDays days ago.

  -Check and -Demote write update-tiers.json (unless -WhatIf) and return one object per change. On
  GitHub Actions they also write a table to the job summary and set the step outputs 'changed'
  (true or false) and 'promoted' (comma-separated names).

.PARAMETER Hide
  Hide every manifest outside -Tier from the working copy (sparse checkout). Used by the Excavator
  workflows.

.PARAMETER Tier
  With -Hide: the tier to keep, Frequent (excavator-4h.yml) or Daily (excavator-1d.yml).

.PARAMETER Check
  Check the EOL manifests for new versions and send updatable ones back.

.PARAMETER Demote
  Add manifests without a new version for eolAfterDays days to the EOL list.

.PARAMETER Show
  List every manifest with its tier and the age of its version.

.PARAMETER OpenIssues
  With -Check: open an issue (through the GitHub CLI, gh) for each EOL manifest that has a new
  version but no autoupdate, unless an open issue with the same title exists.

.PARAMETER ListPath
  Path of the tier settings and EOL list. Defaults to update-tiers.json in the bucket root.

.PARAMETER Now
  The date to measure ages from. Defaults to now; tests pass a fixed date.

.EXAMPLE
  .\bin\Watch-Tiers.ps1 -Show
  Shows which schedule each manifest is on.

.EXAMPLE
  .\bin\Watch-Tiers.ps1 -Check -Demote -WhatIf
  Shows what the monthly run would change, without writing update-tiers.json.

.NOTES
  Ages come from the bucket's git history (actions/checkout with fetch-depth: 0).
  -Check needs Scoop's checkver: SCOOP_HOME pointing to Scoop's core, or Scoop installed.
  See docs/automation.md#update-tiers.
#>
[CmdletBinding(SupportsShouldProcess, DefaultParameterSetName = 'Show')]
param (
  [Parameter(Mandatory, ParameterSetName = 'Hide')]
  [switch] $Hide,

  [Parameter(Mandatory, ParameterSetName = 'Hide')]
  [ValidateSet('Frequent', 'Daily')]
  [string] $Tier,

  [Parameter(ParameterSetName = 'Monthly')]
  [switch] $Check,

  [Parameter(ParameterSetName = 'Monthly')]
  [switch] $Demote,

  [Parameter(ParameterSetName = 'Show')]
  [switch] $Show,

  [Parameter(ParameterSetName = 'Monthly')]
  [switch] $OpenIssues,

  [string] $ListPath = (Join-Path (Join-Path $PSScriptRoot '..') 'update-tiers.json'),

  [datetime] $Now = (Get-Date)
)

Set-StrictMode -Version 3
$ErrorActionPreference = 'Stop'

$Root = Convert-Path (Join-Path $PSScriptRoot '..')
$BucketDir = Join-Path $Root 'bucket'
$ListPath = [IO.Path]::GetFullPath($ListPath)
$Today = $Now.ToString('yyyy-MM-dd')

#region update-tiers.json

<#
.SYNOPSIS
  Reads update-tiers.json into a hashtable with ordered 'eol' and 'returned' maps.
#>
function Read-TierList {
  if (-not (Test-Path $ListPath)) { throw "Tier list not found: $ListPath" }
  $raw = Get-Content $ListPath -Raw | ConvertFrom-Json

  $list = @{
    dailyAfterDays  = 30
    eolAfterDays    = 365
    keepInExcavator = @()
    eol             = [ordered]@{}
    returned        = [ordered]@{}
  }
  foreach ($key in 'dailyAfterDays', 'eolAfterDays') {
    if ($raw.PSObject.Properties[$key]) { $list[$key] = [int] $raw.$key }
  }
  if ($raw.PSObject.Properties['keepInExcavator']) { $list.keepInExcavator = @($raw.keepInExcavator) }
  foreach ($key in 'eol', 'returned') {
    if (-not $raw.PSObject.Properties[$key]) { continue }
    foreach ($property in $raw.$key.PSObject.Properties) { $list[$key][$property.Name] = [string] $property.Value }
  }
  return $list
}

<#
.SYNOPSIS
  Escapes a string for a JSON string literal.
#>
function ConvertTo-JsonString([string] $Text) {
  return '"' + ($Text -replace '\\', '\\' -replace '"', '\"') + '"'
}

<#
.SYNOPSIS
  Formats a map as a JSON object, sorted by key, its entries indented by 8 spaces.
#>
function Format-JsonMap($Map) {
  if ($Map.Count -eq 0) { return '{}' }
  $lines = $Map.Keys | Sort-Object | ForEach-Object { '        ' + (ConvertTo-JsonString $_) + ': ' + (ConvertTo-JsonString $Map[$_]) }
  return "{`r`n" + ($lines -join ",`r`n") + "`r`n    }"
}

<#
.SYNOPSIS
  Writes update-tiers.json in the bucket's JSON style (4 spaces, CRLF, sorted names, final newline).
#>
function Write-TierList {
  [CmdletBinding(SupportsShouldProcess)]
  param ($List)
  $keep = '[]'
  if ($List.keepInExcavator.Count) { $keep = '[' + (($List.keepInExcavator | Sort-Object | ForEach-Object { ConvertTo-JsonString $_ }) -join ', ') + ']' }
  $text = @(
    '{',
    '    "about": "Update schedules of the manifests. See docs/automation.md#update-tiers.",',
    "    `"dailyAfterDays`": $($List.dailyAfterDays),",
    "    `"eolAfterDays`": $($List.eolAfterDays),",
    "    `"keepInExcavator`": $keep,",
    "    `"eol`": $(Format-JsonMap $List.eol),",
    "    `"returned`": $(Format-JsonMap $List.returned)",
    '}',
    ''
  ) -join "`r`n"
  if ($PSCmdlet.ShouldProcess($ListPath, 'Write tier list')) {
    [IO.File]::WriteAllText($ListPath, $text, (New-Object Text.UTF8Encoding $false))
  }
}

#endregion

#region Manifests, history and tiers

<#
.SYNOPSIS
  Reads a manifest of bucket/ by name; $null if it does not exist.
#>
function Get-Manifest([string] $Name) {
  $path = Join-Path $BucketDir "$Name.json"
  if (-not (Test-Path $path)) { return $null }
  return Get-Content $path -Raw | ConvertFrom-Json
}

<#
.SYNOPSIS
  Tells whether an object has a property (StrictMode-safe).
#>
function Test-Property($Object, [string] $Name) {
  return [bool] $Object.PSObject.Properties[$Name]
}

<#
.SYNOPSIS
  The "version" value of a manifest in a commit; $null if the file is not there.
#>
function Get-VersionAt([string] $Commit, [string] $Path) {
  $text = (git -C $Root show "${Commit}:$Path" 2>$null) -join "`n"
  if ($text -match '"version"\s*:\s*"(?<version>[^"]*)"') { return $Matches.version }
  return $null
}

<#
.SYNOPSIS
  Date of the last commit that changed the manifest's version value; $null without history.

.DESCRIPTION
  Walks the manifest's commits from the newest (following renames) and compares the version value
  of each with the one before it, so commits that only reformat a manifest or rename it do not count.
  Without any change the date of the oldest commit, where the manifest was added, is returned.
#>
function Get-LastVersionChange([string] $Name) {
  # One entry per commit: '@<sha> <date>', then '<status>`t<path>' (renames and copies: '<status>`t<old>`t<new>').
  $log = @(git -C $Root log --follow --format='@%H %cI' --name-status -- "bucket/$Name.json" | Where-Object { $_ })
  # A merge commit has a header but no status line: it is skipped.
  $commits = [Collections.Generic.List[object]]::new()
  for ($i = 0; $i -lt $log.Count - 1; $i++) {
    if (-not $log[$i].StartsWith('@') -or $log[$i + 1].StartsWith('@')) { continue }
    $sha, $date = $log[$i].TrimStart('@') -split ' ', 2
    $status = $log[$i + 1] -split "`t"
    $commits.Add([pscustomobject]@{ Sha = $sha; Date = $date; Path = $status[-1] })
    # --follow also takes a new manifest with the same content as another one for a copy (C) of it:
    # follow renames (R) only, and treat a copy as the commit that added the manifest.
    if ($status[0] -like 'C*') { break }
  }
  if ($commits.Count -eq 0) { return $null }

  $newer = Get-VersionAt $commits[0].Sha $commits[0].Path
  for ($i = 0; $i -lt $commits.Count - 1; $i++) {
    $older = Get-VersionAt $commits[$i + 1].Sha $commits[$i + 1].Path
    if ($older -ne $newer) { return [datetime]::Parse($commits[$i].Date, [Globalization.CultureInfo]::InvariantCulture) }
    $newer = $older
  }
  return [datetime]::Parse($commits[-1].Date, [Globalization.CultureInfo]::InvariantCulture)
}

<#
.SYNOPSIS
  Every manifest of bucket/ with its tier, the date its version last changed and its age in days.
#>
function Get-ManifestTier($List) {
  foreach ($file in Get-ChildItem $BucketDir -Filter '*.json' | Sort-Object Name) {
    $name = $file.BaseName
    $changed = Get-LastVersionChange $name
    $age = $null
    if ($changed) { $age = [int] [math]::Floor(($Now - $changed).TotalDays) }

    $tier = 'Daily'
    if ($List.eol.Contains($name)) { $tier = 'EOL' }
    elseif ($List.keepInExcavator -contains $name) { $tier = 'Frequent' }
    elseif ($null -eq $age -or $age -lt $List.dailyAfterDays) { $tier = 'Frequent' }

    [pscustomobject]@{ Name = $name; Tier = $tier; VersionChanged = $changed; AgeDays = $age }
  }
}

#endregion

#region checkver

<#
.SYNOPSIS
  Runs Scoop's checkver on one manifest and returns Status (current, new or error), Current,
  Latest and Message.
#>
function Invoke-Checkver([string] $Name, $Manifest) {
  $result = [pscustomobject]@{ Status = 'error'; Current = [string] $Manifest.version; Latest = ''; Message = '' }
  if (-not (Test-Property $Manifest 'checkver')) {
    $result.Message = 'the manifest has no checkver'
    return $result
  }

  $scoopHome = $env:SCOOP_HOME
  if (-not $scoopHome) { $scoopHome = Convert-Path (scoop prefix scoop) }
  $checkver = Join-Path (Join-Path $scoopHome 'bin') 'checkver.ps1'

  # Scoop's scripts are not written for strict mode, which would otherwise reach them from this scope.
  Set-StrictMode -Off
  # -WhatIf is for update-tiers.json only; checkver must still clean up its own download events.
  $WhatIfPreference = $false
  # checkver prints with Write-Host only: collect the information stream (6) as text.
  $text = (& $checkver -App $Name -Dir $BucketDir 6>&1 2>&1 | ForEach-Object { "$_" }) -join ''
  $prefix = [regex]::Escape("${Name}: ")

  if ($text -match "$prefix(?<latest>\S+) \(scoop version is (?<current>[^)]+)\)") {
    $result.Status = 'new'
    $result.Latest = $Matches.latest
    return $result
  }
  if ($text -match "$prefix(?<latest>\S+)\s*$" -and $Matches.latest -eq $result.Current) {
    $result.Status = 'current'
    $result.Latest = $Matches.latest
    return $result
  }
  $result.Message = ($text -replace '\s+', ' ').Trim()
  if (-not $result.Message) { $result.Message = 'checkver printed nothing' }
  return $result
}

#endregion

#region Actions

<#
.SYNOPSIS
  Builds one change record for the report.
#>
function Get-ChangeRecord([string] $Name, [string] $Action, [string] $Detail) {
  return [pscustomobject]@{ Name = $Name; Action = $Action; Detail = $Detail }
}

<#
.SYNOPSIS
  Keeps only the manifests of one tier in the working copy, with a non-cone sparse checkout.
#>
function Invoke-Hide([string] $KeepTier) {
  $tiers = @(Get-ManifestTier (Read-TierList))
  $kept = @($tiers | Where-Object Tier -EQ $KeepTier | Select-Object -ExpandProperty Name)
  $hidden = @($tiers | Where-Object Tier -NE $KeepTier | Select-Object -ExpandProperty Name)
  if ($hidden.Count -eq 0) {
    Write-Host "Every manifest is in the $KeepTier tier: nothing to hide."
    return
  }
  # '/bucket/**' is needed: once a pattern excludes something inside bucket/, git matches each file
  # there on its own, and '/*' alone matches only top-level entries.
  $patterns = @('/*', '/bucket/**') + ($hidden | ForEach-Object { "!/bucket/$_.json" })
  # Through stdin, not as arguments: pwsh on Linux and macOS would expand '/*' as a file name pattern.
  $patterns | git -C $Root sparse-checkout set --no-cone --stdin
  if ($LASTEXITCODE) { throw "git sparse-checkout failed with exit code $LASTEXITCODE" }
  Write-Host "$KeepTier tier, checked by this run ($($kept.Count)): $($kept -join ', ')"
  Write-Host "Hidden ($($hidden.Count)): $($hidden -join ', ')"
}

<#
.SYNOPSIS
  Opens an issue for a new version that needs a manual update, unless one is already open.
#>
function Open-ManualUpdateIssue {
  [CmdletBinding(SupportsShouldProcess)]
  param ([string] $Name, $Result)
  $title = "${Name}: new version $($Result.Latest) (no autoupdate)"
  $open = gh issue list --state open --search "`"$title`" in:title" --json title --jq '.[].title'
  if ($open -contains $title) {
    Write-Host "Issue already open: $title"
    return
  }
  $repository = if ($env:GITHUB_REPOSITORY) { $env:GITHUB_REPOSITORY } else { 'Gesugao-san/scoop-bucket' }
  $page = "docs/packages/$($Name.ToLowerInvariant()).md"
  $howTo = ''
  if (Test-Path (Join-Path $Root $page)) { $howTo = " (see [$page](https://github.com/$repository/blob/HEAD/$page))" }
  $body = @(
    "The monthly EOL check found version $($Result.Latest) of ``$Name`` (the manifest has $($Result.Current)).",
    '',
    "The manifest has no ``autoupdate``, so update it by hand$howTo. It stays in the EOL list of ``update-tiers.json``; remove it there if the package should go back to Excavator."
  ) -join "`n"
  if ($PSCmdlet.ShouldProcess($title, 'Open issue')) {
    gh issue create --title $title --body $body | Out-Host
  }
}

# What -Check does with each checkver status of an EOL manifest.
$CheckActions = @{
  'current' = { param($Name, $Manifest, $Result, $List) $null }
  'error'   = { param($Name, $Manifest, $Result, $List) Get-ChangeRecord -Name $Name -Action 'error' -Detail $Result.Message }
  'new'     = {
    param($Name, $Manifest, $Result, $List)
    if (-not (Test-Property $Manifest 'autoupdate')) {
      if ($OpenIssues) { Open-ManualUpdateIssue -Name $Name -Result $Result }
      return Get-ChangeRecord -Name $Name -Action 'manual update' -Detail "$($Result.Current) -> $($Result.Latest), no autoupdate: stays EOL"
    }
    $List.eol.Remove($Name)
    $List.returned[$Name] = $Today
    return Get-ChangeRecord -Name $Name -Action 'promoted' -Detail "$($Result.Current) -> $($Result.Latest): back to Excavator 1d"
  }
}

<#
.SYNOPSIS
  Checks each EOL manifest and applies $CheckActions.
#>
function Invoke-Check($List) {
  foreach ($name in @($List.eol.Keys)) {
    $manifest = Get-Manifest $name
    if (-not $manifest) {
      $List.eol.Remove($name)
      Get-ChangeRecord -Name $name -Action 'dropped' -Detail 'the manifest no longer exists'
      continue
    }
    $result = Invoke-Checkver $name $manifest
    Write-Host "${name}: $($result.Status) $($result.Latest) $($result.Message)"
    & $CheckActions[$result.Status] $name $manifest $result $List
  }
}

<#
.SYNOPSIS
  Lists manifests with checkver whose version has not changed for eolAfterDays days.
#>
function Invoke-Demote($List) {
  # Entries in 'returned' only protect a package for eolAfterDays days.
  $limit = $Now.AddDays(-$List.eolAfterDays)
  foreach ($name in @($List.returned.Keys)) {
    if ([datetime] $List.returned[$name] -lt $limit) { $List.returned.Remove($name) }
  }

  foreach ($entry in Get-ManifestTier $List) {
    if ($entry.Tier -ne 'Daily') { continue }
    if ($entry.AgeDays -lt $List.eolAfterDays) { continue }
    if ($List.returned.Contains($entry.Name)) { continue }
    if (-not (Test-Property (Get-Manifest $entry.Name) 'checkver')) { continue }

    $since = $entry.VersionChanged.ToString('yyyy-MM-dd')
    $List.eol[$entry.Name] = "${Today}: no new version since $since"
    Get-ChangeRecord -Name $entry.Name -Action 'demoted' -Detail "no new version since ${since}: EOL"
  }
}

<#
.SYNOPSIS
  Writes the changes to the job summary and the step outputs on GitHub Actions.
#>
function Publish-ChangeReport($Changes) {
  if (-not $env:GITHUB_ACTIONS) { return }
  $promoted = @($Changes | Where-Object Action -EQ 'promoted' | Select-Object -ExpandProperty Name)
  $listChanged = @($Changes | Where-Object Action -In 'promoted', 'demoted', 'dropped').Count -gt 0
  if ($env:GITHUB_OUTPUT) {
    Add-Content $env:GITHUB_OUTPUT "changed=$($listChanged.ToString().ToLowerInvariant())" -WhatIf:$false
    Add-Content $env:GITHUB_OUTPUT "promoted=$($promoted -join ',')" -WhatIf:$false
  }
  if (-not $env:GITHUB_STEP_SUMMARY) { return }
  $rows = $Changes | ForEach-Object { "| ``$($_.Name)`` | $($_.Action) | $($_.Detail -replace '\|', '\|') |" }
  $table = if ($rows) { @('| Package | Action | Detail |', '|---|---|---|') + $rows } else { @('No changes.') }
  Add-Content $env:GITHUB_STEP_SUMMARY (@('## EOL packages', '') + $table + '' -join "`n") -WhatIf:$false
  foreach ($change in $Changes | Where-Object Action -EQ 'error') {
    Write-Host "::warning title=EOL check: $($change.Name)::$($change.Detail)"
  }
}

#endregion

if ($Hide) {
  Invoke-Hide $Tier
  return
}

$list = Read-TierList
if (-not ($Check -or $Demote)) {
  Get-ManifestTier $list
  return
}

$changes = @()
if ($Check) { $changes += @(Invoke-Check $list) }
if ($Demote) { $changes += @(Invoke-Demote $list) }
$changes = @($changes | Where-Object { $_ })

if (@($changes | Where-Object Action -In 'promoted', 'demoted', 'dropped').Count) { Write-TierList -List $list }
Publish-ChangeReport $changes
$changes
