<#
.SYNOPSIS
  Copies the files that winws.exe and winws2.exe need from their own gesu packages into the folders
  the zapret packages run them from: cygwin1.dll from Cygwin-Runtime, WinDivert from WinDivert (or
  WinDivert-hide), and for zapret-discord-youtube also winws.exe from zapret.

.DESCRIPTION
  winws.exe and winws2.exe load cygwin1.dll and WinDivert.dll from their own folder, and WinDivert.dll
  loads its driver (WinDivert64.sys) from its own folder. Upstream releases therefore ship copies of
  all of them. In the gesu bucket each of them is a package of its own, and this script puts the
  current files next to each program:

  | Package (consumer)     | Folder | Gets                                                      |
  |------------------------|--------|-----------------------------------------------------------|
  | zapret                 | (app)  | cygwin1.dll, WinDivert.dll + driver                       |
  | zapret2                | (app)  | cygwin1.dll, WinDivert.dll + driver                       |
  | zapret-discord-youtube | bin    | winws.exe (from zapret), cygwin1.dll, WinDivert + driver  |

  The driver is WinDivert64.sys from gesu/WinDivert or, when gesu/WinDivert-hide is installed,
  Monkey64.sys with its patched WinDivert.dll; the file of the other variant is removed.

  zapret-discord-youtube can keep Flowseal's own winws.exe and cygwin1.dll (the pair its strategies
  were tested with): when 'settings\use-bundled' exists in its app folder, those two come from its
  'bundled' folder instead ('zapret-discord-youtube bundled on').

  Copies, not links: a running winws keeps only the consumer's copies open, so the component
  packages update freely; a consumer picks the new files up the next time this script runs for it.
  The manifests run it from post_install, the component packages for every installed consumer.
  A copy fails while winws runs from that folder (the file is in use); the old copy stays then.

  Only one Scoop apps folder is used, the caller's: a global (admin) install must never copy
  binaries out of a folder that a non-admin user could have changed.

.PARAMETER App
  Consumers to refresh. Default: every one of them that is installed in AppsDir.

.PARAMETER AppsDir
  Scoop apps folder of the consumers and the components, e.g. %ProgramData%\scoop\apps.

.PARAMETER Strict
  Throw on the first problem instead of writing a warning. For a consumer's own post_install.

.OUTPUTS
  System.String, one line per file, with the user's profile folder shown as %USERPROFILE%.

.EXAMPLE
  & .\scripts\zapret\Sync-ZapretComponents.ps1 -AppsDir "$env:ProgramData\scoop\apps"
  Refreshes every installed consumer from the global Scoop folder.

.NOTES
  Must run on Windows PowerShell 5.1, which Scoop uses for hooks.
#>
[CmdletBinding()]
param(
  [ValidateSet('zapret', 'zapret2', 'zapret-discord-youtube')]
  [string[]] $App = @(),

  [Parameter(Mandatory)]
  [string] $AppsDir,

  [switch] $Strict
)

Set-StrictMode -Version 2.0

# Folder: where the consumer runs winws from, relative to its app folder. Winws: also gets winws.exe.
$Consumers = [ordered]@{
  'zapret'                 = @{ Folder = ''; Winws = $false }
  'zapret2'                = @{ Folder = ''; Winws = $false }
  'zapret-discord-youtube' = @{ Folder = 'bin'; Winws = $true }
}

<#
.SYNOPSIS
  Replaces the user's profile folder in a text with %USERPROFILE% (docs/conventions.md#paths-in-notes-and-messages).
#>
function Hide-UserProfile([string] $Text) {
  if (-not $env:USERPROFILE) { return $Text }
  $Text -replace [regex]::Escape($env:USERPROFILE), '%USERPROFILE%'
}

<#
.SYNOPSIS
  Reports a problem: throws with -Strict, otherwise writes a warning.
#>
function Write-Problem([string] $Message) {
  $Message = Hide-UserProfile $Message
  if ($Strict) { throw $Message }
  Write-Warning $Message
}

<#
.SYNOPSIS
  Returns the 'current' folder of an installed package, or $null.
#>
function Get-PackageDir([string] $Name) {
  $dir = Join-Path (Join-Path $AppsDir $Name) 'current'
  if (Test-Path -LiteralPath $dir -PathType Container) { return $dir }
  return $null
}

<#
.SYNOPSIS
  Reads the installed version of a package from the manifest Scoop keeps in its folder.
#>
function Get-PackageVersion([string] $PackageDir) {
  $manifest = Join-Path $PackageDir 'manifest.json'
  if (-not (Test-Path -LiteralPath $manifest -PathType Leaf)) { return 'unknown version' }
  try {
    return (Get-Content -LiteralPath $manifest -Raw | ConvertFrom-Json).version
  } catch {
    return 'unknown version'
  }
}

<#
.SYNOPSIS
  Lists the files a consumer needs: target name, source path and a label saying where it is from.
.OUTPUTS
  Hashtable per file (Target, Source, Label), plus 'Remove' entries for driver files of the other
  WinDivert variant. Writes a problem for every component that is missing.
#>
function Get-ComponentPlan([string] $ConsumerDir, [bool] $WithWinws) {
  $useBundled = $WithWinws -and (Test-Path -LiteralPath (Join-Path $ConsumerDir 'settings\use-bundled'))
  $bundledDir = Join-Path $ConsumerDir 'bundled'

  # Guard: Flowseal's own pair, when chosen, replaces winws.exe and cygwin1.dll from the packages.
  if ($useBundled) {
    foreach ($name in 'winws.exe', 'cygwin1.dll') {
      @{ Target = $name; Source = (Join-Path $bundledDir $name); Label = "bundled with zapret-discord-youtube (settings\use-bundled)" }
    }
  } else {
    if ($WithWinws) {
      $zapretDir = Get-PackageDir 'zapret'
      if ($zapretDir) {
        @{ Target = 'winws.exe'; Source = (Join-Path $zapretDir 'winws.exe'); Label = "zapret $(Get-PackageVersion $zapretDir)" }
      } else {
        Write-Problem "winws.exe: gesu/zapret is not installed in '$AppsDir'."
      }
    }

    $cygwinDir = Get-PackageDir 'Cygwin-Runtime'
    if ($cygwinDir) {
      @{ Target = 'cygwin1.dll'; Source = (Join-Path $cygwinDir 'usr\bin\cygwin1.dll'); Label = "Cygwin-Runtime $(Get-PackageVersion $cygwinDir)" }
    } else {
      Write-Problem "cygwin1.dll: gesu/Cygwin-Runtime is not installed in '$AppsDir'."
    }
  }

  # WinDivert-hide wins when installed: installing it is the only way to ask for it.
  $hideDir = Get-PackageDir 'WinDivert-hide'
  if ($hideDir) {
    $label = "WinDivert-hide $(Get-PackageVersion $hideDir)"
    @{ Target = 'WinDivert.dll'; Source = (Join-Path $hideDir 'WinDivert.dll'); Label = $label }
    @{ Target = 'Monkey64.sys'; Source = (Join-Path $hideDir 'Monkey64.sys'); Label = $label }
    @{ Target = 'WinDivert64.sys'; Remove = $true; Label = 'replaced by Monkey64.sys (WinDivert-hide)' }
    return
  }

  $divertDir = Get-PackageDir 'WinDivert'
  if (-not $divertDir) {
    Write-Problem "WinDivert.dll: gesu/WinDivert is not installed in '$AppsDir'."
    return
  }
  $label = "WinDivert $(Get-PackageVersion $divertDir)"
  @{ Target = 'WinDivert.dll'; Source = (Join-Path $divertDir 'WinDivert.dll'); Label = $label }
  @{ Target = 'WinDivert64.sys'; Source = (Join-Path $divertDir 'WinDivert64.sys'); Label = $label }
  @{ Target = 'Monkey64.sys'; Remove = $true; Label = 'WinDivert-hide is not installed' }
}

<#
.SYNOPSIS
  Tells whether two files have the same content (SHA-256; the files are small).
#>
function Test-SameFile([string] $Source, [string] $Target) {
  if (-not (Test-Path -LiteralPath $Target -PathType Leaf)) { return $false }
  $sourceHash = (Get-FileHash -LiteralPath $Source -Algorithm SHA256).Hash
  $targetHash = (Get-FileHash -LiteralPath $Target -Algorithm SHA256).Hash
  return $sourceHash -eq $targetHash
}

<#
.SYNOPSIS
  Applies one plan entry in the consumer's folder.
.OUTPUTS
  System.String: the line to show, or nothing when there is nothing to say.
#>
function Invoke-PlanEntry([hashtable] $Entry, [string] $TargetDir) {
  $target = Join-Path $TargetDir $Entry.Target

  if ($Entry.ContainsKey('Remove')) {
    if (-not (Test-Path -LiteralPath $target -PathType Leaf)) { return }
    try {
      Remove-Item -LiteralPath $target -Force -ErrorAction Stop
      return ('  {0,-16} removed: {1}' -f $Entry.Target, $Entry.Label)
    } catch {
      Write-Problem "$($Entry.Target) in '$TargetDir' could not be removed (stop winws first): $($_.Exception.Message)"
      return
    }
  }

  if (-not (Test-Path -LiteralPath $Entry.Source -PathType Leaf)) {
    Write-Problem "$($Entry.Target): '$($Entry.Source)' is missing ($($Entry.Label)); reinstall that package."
    return
  }

  if (Test-SameFile $Entry.Source $target) {
    return ('  {0,-16} {1}' -f $Entry.Target, $Entry.Label)
  }

  try {
    Copy-Item -LiteralPath $Entry.Source -Destination $target -Force -ErrorAction Stop
    return ('  {0,-16} {1} (updated)' -f $Entry.Target, $Entry.Label)
  } catch {
    Write-Problem "$($Entry.Target) in '$TargetDir' was not updated, it is probably in use (stop winws first): $($_.Exception.Message)"
  }
}

if (-not (Test-Path -LiteralPath $AppsDir -PathType Container)) {
  Write-Problem "Scoop apps folder '$AppsDir' does not exist."
  return
}

$selected = if ($App) { $App } else { @($Consumers.Keys) }

foreach ($name in $selected) {
  $consumerDir = Get-PackageDir $name
  # Not installed: nothing to refresh. With -Strict the caller expects it to be there.
  if (-not $consumerDir) {
    if ($Strict) { Write-Problem "$name is not installed in '$AppsDir'." }
    continue
  }

  $consumer = $Consumers[$name]
  $targetDir = if ($consumer.Folder) { Join-Path $consumerDir $consumer.Folder } else { $consumerDir }
  New-Item -ItemType Directory -Path $targetDir -Force | Out-Null

  Hide-UserProfile "$name, components in ${targetDir}:"
  foreach ($entry in @(Get-ComponentPlan $consumerDir $consumer.Winws)) {
    $line = Invoke-PlanEntry $entry $targetDir
    if ($line) { Hide-UserProfile $line }
  }
}
