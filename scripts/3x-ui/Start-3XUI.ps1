<#
.SYNOPSIS
  Runs 3X-UI with its data in the Scoop persist folder and with Xray, mtg-multi and the geo files
  taken from their own gesu packages.

.DESCRIPTION
  The gesu/3X-UI manifest copies this script into the app folder and makes it the '3x-ui' command;
  the '3X-UI' shortcut (3X-UI.cmd) runs it with 'run'.

  1. Folders. 3X-UI on Windows keeps its database next to 3x-ui.exe and its logs and binaries in
     'log' and 'bin' under the CURRENT folder. The script points XUI_DB_FOLDER, XUI_LOG_FOLDER and
     XUI_BIN_FOLDER at 'data', 'log' and 'bin' in the app folder, which Scoop keeps in the persist
     folder, so they survive updates and do not depend on where the command is started. A variable
     that is already set (for example by the user, to share a database) is left alone.

  2. Components. Before the panel starts ('run', or no command at all), every file the panel expects
     in its bin folder is copied there from the package that provides it: xray.exe and wintun.dll from
     Xray-core, mtg-multi.exe from mtg-multi, and geoip/geosite from Loyalsoldier-v2ray-rules-dat,
     Chocolate4U-Iran-v2ray-rules (_IR) and runetfreedom-russia-v2ray-rules-dat (_RU). A file is copied
     only when it differs from the copy in bin (size or modification time). Packages are looked up in
     the same Scoop apps folder as 3X-UI first, then in the user and global Scoop folders. When a
     package is not installed, the copy that came in the 3X-UI release archive ('bundled') is used.

  Copies, not links: the running panel and Xray then hold no files of the other packages open, so
  'scoop update Xray-core' and the rest work while the panel runs; the panel picks them up when it
  starts next time. For the same reason, an Xray version or geo file the panel downloads itself
  (Panel Settings, Xray updates) is replaced again by the package's copy on the next start.

  Other commands (setting, migrate-db, ...) only get the folders.

.EXAMPLE
  3x-ui
  Starts the panel; same as '3x-ui run'.

.EXAMPLE
  3x-ui setting -show
  Shows the panel's port, path and other settings from the persisted database.

.NOTES
  No param() block on purpose: every argument goes to $args untouched and is passed on to 3x-ui.exe,
  whose flags PowerShell must not bind itself.
  Must run on Windows PowerShell 5.1, which Scoop's shims use when called from cmd.
#>

Set-StrictMode -Version 2.0

# The panel is a 64-bit build, so it looks for the amd64 names whatever Xray and mtg-multi run as.
# Target: name in the bin folder; App: Scoop package; File: name in that package.
$Components = @(
  @{ Target = 'xray-windows-amd64.exe'; App = 'Xray-core'; File = 'xray.exe' }
  @{ Target = 'wintun.dll'; App = 'Xray-core'; File = 'wintun.dll' }
  @{ Target = 'mtg-windows-amd64.exe'; App = 'mtg-multi'; File = 'mtg-multi.exe' }
  @{ Target = 'geoip.dat'; App = 'Loyalsoldier-v2ray-rules-dat'; File = 'geoip.dat' }
  @{ Target = 'geosite.dat'; App = 'Loyalsoldier-v2ray-rules-dat'; File = 'geosite.dat' }
  @{ Target = 'geoip_IR.dat'; App = 'Chocolate4U-Iran-v2ray-rules'; File = 'geoip.dat' }
  @{ Target = 'geosite_IR.dat'; App = 'Chocolate4U-Iran-v2ray-rules'; File = 'geosite.dat' }
  @{ Target = 'geoip_RU.dat'; App = 'runetfreedom-russia-v2ray-rules-dat'; File = 'geoip.dat' }
  @{ Target = 'geosite_RU.dat'; App = 'runetfreedom-russia-v2ray-rules-dat'; File = 'geosite.dat' }
)

# Commands of 3x-ui.exe that start the panel and therefore need the bin folder filled.
$ServerCommands = @('run')

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
  Prints a status line to stderr, so that it stays out of the panel's own output when that is redirected.
#>
function Write-Status([string] $Line) {
  [Console]::Error.WriteLine($Line)
}

<#
.SYNOPSIS
  Sets a XUI_* folder variable for this process unless it is already set.
.PARAMETER Name
  Variable name, e.g. XUI_DB_FOLDER.
.PARAMETER Path
  Folder to use when the variable is not set.
.OUTPUTS
  System.String: the folder in effect.
#>
function Use-DefaultFolder([string] $Name, [string] $Path) {
  $current = [Environment]::GetEnvironmentVariable($Name, 'Process')
  if ($current) { return $current }
  [Environment]::SetEnvironmentVariable($Name, $Path, 'Process')
  return $Path
}

<#
.SYNOPSIS
  Returns the Scoop apps folders to search for the component packages, 3X-UI's own first.
.PARAMETER AppDir
  Folder this script runs from (...\apps\3X-UI\current).
#>
function Get-ScoopAppsDir([string] $AppDir) {
  $ownApps = Split-Path -Parent (Split-Path -Parent $AppDir)
  $userRoot = $env:SCOOP
  if (-not $userRoot) { $userRoot = Join-Path $env:USERPROFILE 'scoop' }
  $globalRoot = $env:SCOOP_GLOBAL
  if (-not $globalRoot) { $globalRoot = Join-Path $env:ProgramData 'scoop' }

  @($ownApps, (Join-Path $userRoot 'apps'), (Join-Path $globalRoot 'apps')) | Select-Object -Unique
}

<#
.SYNOPSIS
  Reads the installed version of a Scoop package from the manifest Scoop keeps in its folder.
.OUTPUTS
  System.String: the version, or 'unknown version'.
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
  Finds where one bin file should come from: the component's package, else the bundled copy.
.OUTPUTS
  Hashtable with Path (full path of the source file) and Label (where it is from), or $null when
  neither exists.
#>
function Find-ComponentSource([hashtable] $Component, [string[]] $AppsDirs, [string] $BundledDir) {
  foreach ($appsDir in $AppsDirs) {
    $packageDir = Join-Path (Join-Path $appsDir $Component.App) 'current'
    $candidate = Join-Path $packageDir $Component.File
    if (Test-Path -LiteralPath $candidate -PathType Leaf) {
      return @{ Path = $candidate; Label = "$($Component.App) $(Get-PackageVersion $packageDir)" }
    }
  }

  $bundled = Join-Path $BundledDir $Component.Target
  if (Test-Path -LiteralPath $bundled -PathType Leaf) {
    return @{ Path = $bundled; Label = "bundled with 3X-UI (install gesu/$($Component.App) for updates)" }
  }
  return $null
}

<#
.SYNOPSIS
  Copies Source to Target unless Target already has the same size and modification time.
.OUTPUTS
  System.String: 'same', 'copied' or 'failed: <reason>'.
#>
function Sync-File([string] $Source, [string] $Target) {
  $sourceItem = Get-Item -LiteralPath $Source
  $targetItem = Get-Item -LiteralPath $Target -ErrorAction SilentlyContinue
  $isCurrent = $targetItem -and
    $targetItem.Length -eq $sourceItem.Length -and
    $targetItem.LastWriteTimeUtc -eq $sourceItem.LastWriteTimeUtc
  if ($isCurrent) { return 'same' }

  try {
    # Copy-Item keeps the modification time, which the check above compares next time.
    Copy-Item -LiteralPath $Source -Destination $Target -Force -ErrorAction Stop
    return 'copied'
  } catch {
    return "failed: $($_.Exception.Message)"
  }
}

<#
.SYNOPSIS
  Fills the bin folder from the component packages and prints one line per file.
#>
function Sync-BinFolder([string] $BinDir, [string] $AppDir) {
  New-Item -ItemType Directory -Path $BinDir -Force | Out-Null
  $appsDirs = Get-ScoopAppsDir $AppDir
  $bundledDir = Join-Path $AppDir 'bundled'

  Write-Status "Components in $(Hide-UserProfile $BinDir):"
  foreach ($component in $Components) {
    $source = Find-ComponentSource $component $appsDirs $bundledDir
    if (-not $source) {
      Write-Warning "$($component.Target): not found; install gesu/$($component.App)."
      continue
    }

    $result = Sync-File $source.Path (Join-Path $BinDir $component.Target)
    if ($result -like 'failed*') {
      Write-Warning "$($component.Target): $(Hide-UserProfile $result); the copy already in bin is used."
      continue
    }
    Write-Status ('  {0,-23} {1}{2}' -f $component.Target, $source.Label, $(if ($result -eq 'copied') { ' (updated)' } else { '' }))
  }
  Write-Status ''
}

<#
.SYNOPSIS
  Tells whether this 3X-UI installation already runs a panel.
#>
function Test-PanelRunning([string] $AppDir) {
  $appRoot = Split-Path -Parent $AppDir
  $running = @(Get-Process -Name '3x-ui' -ErrorAction SilentlyContinue |
      Where-Object { $_.Path -and $_.Path -like (Join-Path $appRoot '*') })
  return $running.Count -gt 0
}

$appDir = $PSScriptRoot
$exe = Join-Path $appDir '3x-ui.exe'
if (-not (Test-Path -LiteralPath $exe -PathType Leaf)) {
  Write-Error "3x-ui.exe is missing from $(Hide-UserProfile $appDir); reinstall with 'scoop install gesu/3X-UI'."
  exit 1
}

Use-DefaultFolder 'XUI_DB_FOLDER' (Join-Path $appDir 'data') | Out-Null
Use-DefaultFolder 'XUI_LOG_FOLDER' (Join-Path $appDir 'log') | Out-Null
$binDir = Use-DefaultFolder 'XUI_BIN_FOLDER' (Join-Path $appDir 'bin')

# Without a command 3x-ui.exe starts the panel too.
$command = if ($args.Count -gt 0) { [string] $args[0] } else { 'run' }
$startsPanel = $ServerCommands -contains $command

if ($startsPanel -and (Test-PanelRunning $appDir)) {
  Write-Error '3X-UI is already running from this installation. Use the open panel, or stop it first (Ctrl+C in its window).'
  exit 1
}

if ($startsPanel) { Sync-BinFolder $binDir $appDir }

& $exe @args
exit $LASTEXITCODE
