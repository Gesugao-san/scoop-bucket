<#
.SYNOPSIS
  The 'zapret-discord-youtube' command of the gesu Scoop bucket: opens Flowseal's service manager with
  the components from their own packages, and stops, starts and updates the 'zapret' service around
  Scoop.

.DESCRIPTION
  The gesu/zapret-discord-youtube manifest copies this script into the app folder and makes it the
  'zapret-discord-youtube' command; the shortcut in Scoop Apps (zapret-discord-youtube.cmd) runs it
  without a command. Every command except 'status' and 'help' needs administrator rights: the
  script asks for them itself (UAC) and runs again in a new window.

  Commands:
    menu       (default) Copy the components into bin (Sync-ZapretComponents.ps1), then open
               Flowseal's service.bat: Install Service, Remove Services, Game Filter, Run Tests...
    status     Component versions, the 'zapret' service and its strategy, running winws.exe.
    stop       Stop the 'zapret' service and every winws.exe started from this app's folder.
    start      Start the 'zapret' service again.
    update     stop, 'scoop update' this package and its components, start again if it ran.
               Scoop itself refuses to update the package while winws.exe runs from its folder.
    sync       Copy the components into bin again (after 'scoop update' of a component, when
               winws was running at that moment).
    bundled on|off
               on:  use Flowseal's own winws.exe and cygwin1.dll (the pair its strategies were
                    tested with) instead of gesu/zapret and gesu/Cygwin-Runtime.
               off: back to the packages (default). Restarts the service when it runs.
    folder     Open the app folder (the general*.bat strategies, lists, utils) in Explorer.
    cleanup    For 'scoop uninstall' (pre_uninstall): remove the 'zapret' service and the WinDivert
               driver services when they point into this app's folder.

.EXAMPLE
  zapret-discord-youtube update
  Stops the bypass, updates it and its components with Scoop, and starts it again.

.NOTES
  Must run on Windows PowerShell 5.1, which Scoop's shims use when called from cmd.
  'Pause' is internal: added when the script restarts itself elevated, so the window stays open.
#>
param(
  [Parameter(Position = 0)]
  [ValidateSet('menu', 'status', 'stop', 'start', 'update', 'sync', 'bundled', 'folder', 'cleanup', 'help')]
  [string] $Command = 'menu',

  [Parameter(Position = 1)]
  [ValidateSet('', 'on', 'off')]
  [string] $Value = '',

  [switch] $Pause
)

Set-StrictMode -Version 2.0

$AppDir = $PSScriptRoot                          # ...\apps\zapret-discord-youtube\current
$AppRoot = Split-Path -Parent $AppDir            # ...\apps\zapret-discord-youtube
$AppsDir = Split-Path -Parent $AppRoot           # ...\apps
$ServiceName = 'zapret'
$DriverServices = @('WinDivert', 'WinDivert14', 'Monkey')
$Components = @('WinDivert', 'WinDivert-hide', 'Cygwin-Runtime', 'zapret')

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
  Tells whether this process runs with administrator rights.
#>
function Test-Admin {
  $principal = [Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()
  $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

<#
.SYNOPSIS
  Runs this script again elevated, in a new window, and waits for it.
#>
function Invoke-Elevated {
  $arguments = @('-NoLogo', '-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', "`"$PSCommandPath`"", $Command)
  if ($Value) { $arguments += $Value }
  # The menu ends in service.bat's own prompt; the other commands would close before you read them.
  if ($Command -ne 'menu') { $arguments += '-Pause' }

  Write-Host "Asking for administrator rights (UAC) to run 'zapret-discord-youtube $Command $Value'..."
  try {
    Start-Process -FilePath (Get-Process -Id $PID).Path -Verb RunAs -ArgumentList $arguments -Wait -ErrorAction Stop
  } catch {
    Write-Warning "Not started: $($_.Exception.Message)"
  }
}

<#
.SYNOPSIS
  Returns the executable or driver path a service starts, without arguments and the \??\ prefix.
#>
function Get-ServicePath([string] $Name) {
  $key = "HKLM:\SYSTEM\CurrentControlSet\Services\$Name"
  $imagePath = (Get-ItemProperty -LiteralPath $key -Name ImagePath -ErrorAction SilentlyContinue).ImagePath
  if (-not $imagePath) { return $null }

  $imagePath = $imagePath.Trim() -replace '^\\\?\?\\', ''
  if ($imagePath.StartsWith('"')) { return $imagePath.Substring(1).Split('"')[0] }
  return ($imagePath -split '\s+', 2)[0]
}

<#
.SYNOPSIS
  Tells whether a path lies inside this app's folder (any version, or 'current').
#>
function Test-InApp([string] $Path) {
  if (-not $Path) { return $false }
  $Path.StartsWith("$AppRoot\", [StringComparison]::OrdinalIgnoreCase)
}

<#
.SYNOPSIS
  Returns the 'zapret' service when it runs winws.exe from this app's folder, else $null.
#>
function Get-OwnService {
  $service = Get-Service -Name $ServiceName -ErrorAction SilentlyContinue
  if (-not $service) { return $null }
  if (-not (Test-InApp (Get-ServicePath $ServiceName))) { return $null }
  return $service
}

<#
.SYNOPSIS
  Lists winws.exe processes started from this app's folder.
#>
function Get-OwnWinwsProcess {
  @(Get-Process -Name winws -ErrorAction SilentlyContinue | Where-Object { Test-InApp $_.Path })
}

<#
.SYNOPSIS
  Runs Sync-ZapretComponents.ps1 for this package and prints its lines.
#>
function Invoke-Sync {
  $sync = Join-Path $AppDir 'Sync-ZapretComponents.ps1'
  if (-not (Test-Path -LiteralPath $sync)) {
    Write-Warning "Sync-ZapretComponents.ps1 is missing from the app folder; reinstall: scoop install -g gesu/zapret-discord-youtube"
    return
  }
  & $sync -App 'zapret-discord-youtube' -AppsDir $AppsDir | ForEach-Object { Write-Host $_ }
}

<#
.SYNOPSIS
  Stops the bypass: the own 'zapret' service, own winws.exe processes, then idle driver services.
.OUTPUTS
  System.Boolean: whether the service was running, so that it can be started again.
#>
function Stop-Bypass {
  $wasRunning = $false
  $service = Get-OwnService
  if ($service -and $service.Status -ne 'Stopped') {
    Write-Host "Stopping the '$ServiceName' service..."
    Stop-Service -Name $ServiceName -Force -ErrorAction Continue
    $wasRunning = $true
  }

  foreach ($process in Get-OwnWinwsProcess) {
    Write-Host "Stopping winws.exe (PID $($process.Id))..."
    Stop-Process -Id $process.Id -Force -ErrorAction Continue
  }

  # With winws gone the driver has no handles left and stops, which frees its .sys file in bin.
  foreach ($name in $DriverServices) {
    if (-not (Test-InApp (Get-ServicePath $name))) { continue }
    & sc.exe stop $name 2>&1 | Out-Null
  }
  return $wasRunning
}

<#
.SYNOPSIS
  Starts the own 'zapret' service, if Flowseal's service manager installed one.
#>
function Start-Bypass {
  $service = Get-OwnService
  if (-not $service) {
    Write-Host "No '$ServiceName' service from this app's folder. Install one in the service manager:"
    Write-Host '  zapret-discord-youtube   then  1. Install Service'
    return
  }
  Write-Host "Starting the '$ServiceName' service..."
  Start-Service -Name $ServiceName -ErrorAction Continue
}

<#
.SYNOPSIS
  Shows component versions, the service, its strategy and running winws.exe.
#>
function Show-Status {
  Write-Host "zapret-discord-youtube in $(Hide-UserProfile $AppDir)"
  Write-Host ''
  Write-Host 'Packages:'
  foreach ($name in @('zapret-discord-youtube') + $Components) {
    $manifest = Join-Path $AppsDir "$name\current\manifest.json"
    $version = if (Test-Path -LiteralPath $manifest) { (Get-Content -LiteralPath $manifest -Raw | ConvertFrom-Json).version } else { 'not installed' }
    Write-Host ('  {0,-24} {1}' -f $name, $version)
  }
  $bundled = Test-Path -LiteralPath (Join-Path $AppDir 'settings\use-bundled')
  Write-Host "  winws.exe, cygwin1.dll    $(if ($bundled) { "Flowseal's bundled pair (bundled on)" } else { 'from the packages (bundled off)' })"
  Write-Host ''

  $service = Get-Service -Name $ServiceName -ErrorAction SilentlyContinue
  if (-not $service) {
    Write-Host "Service '$ServiceName': not installed"
  } else {
    $where = if (Get-OwnService) { 'this app' } else { "another copy: $(Hide-UserProfile (Get-ServicePath $ServiceName))" }
    Write-Host "Service '$ServiceName': $($service.Status), $($service.StartType) start, from $where"
    $strategy = (Get-ItemProperty -LiteralPath "HKLM:\SYSTEM\CurrentControlSet\Services\$ServiceName" -Name 'zapret-discord-youtube' -ErrorAction SilentlyContinue).'zapret-discord-youtube'
    if ($strategy) { Write-Host "  strategy: $strategy" }
  }

  $running = @(Get-Process -Name winws -ErrorAction SilentlyContinue)
  if (-not $running) {
    Write-Host 'winws.exe: not running'
    return
  }
  foreach ($process in $running) {
    $where = if ($process.Path) { Hide-UserProfile $process.Path } else { 'path not readable without admin rights' }
    Write-Host "winws.exe: running, PID $($process.Id), $where"
  }
}

<#
.SYNOPSIS
  Updates this package and its installed components with Scoop, around a stopped bypass.
#>
function Update-Bypass {
  $scoop = Get-Command scoop -ErrorAction SilentlyContinue
  if (-not $scoop) {
    Write-Warning "The 'scoop' command was not found in PATH."
    return
  }

  $wasRunning = Stop-Bypass
  $installed = @($Components | Where-Object { Test-Path -LiteralPath (Join-Path $AppsDir "$_\current") })
  $global = $AppsDir.StartsWith((Join-Path $env:ProgramData ''), [StringComparison]::OrdinalIgnoreCase) -or
    ($env:SCOOP_GLOBAL -and $AppsDir.StartsWith($env:SCOOP_GLOBAL, [StringComparison]::OrdinalIgnoreCase))
  $arguments = @('update') + $(if ($global) { @('-g') } else { @() }) + $installed + @('zapret-discord-youtube')

  # Leave the app folder first: Scoop relinks 'current' while this runs.
  Push-Location $env:SystemRoot
  try {
    Write-Host "scoop $($arguments -join ' ')"
    & scoop @arguments
  } finally {
    Pop-Location
  }

  # post_install of each package has copied the components already; this shows the result.
  Invoke-Sync
  if ($wasRunning) { Start-Bypass }
}

<#
.SYNOPSIS
  Switches between Flowseal's bundled winws.exe + cygwin1.dll and the packages' ones.
#>
function Set-Bundled([string] $State) {
  if (-not $State) {
    Write-Warning "Say 'bundled on' or 'bundled off'."
    return
  }
  $marker = Join-Path $AppDir 'settings\use-bundled'
  if ($State -eq 'on') {
    New-Item -ItemType File -Path $marker -Force | Out-Null
  } else {
    Remove-Item -LiteralPath $marker -Force -ErrorAction SilentlyContinue
  }

  $wasRunning = Stop-Bypass
  Invoke-Sync
  if ($wasRunning) { Start-Bypass }
}

<#
.SYNOPSIS
  Removes the own service and driver services, for 'scoop uninstall'.
#>
function Remove-Bypass {
  Stop-Bypass | Out-Null
  if (Get-OwnService) {
    & sc.exe delete $ServiceName | Out-Null
    Write-Host "Removed the '$ServiceName' service."
  }
  foreach ($name in $DriverServices) {
    if (-not (Test-InApp (Get-ServicePath $name))) { continue }
    & sc.exe delete $name | Out-Null
    Write-Host "Removed the '$name' driver service."
  }
}

<#
.SYNOPSIS
  Opens Flowseal's service manager (service.bat) in this window, after copying the components.
#>
function Open-Menu {
  Invoke-Sync
  Write-Host ''
  Write-Host 'Strategies by hand: run one of the general*.bat files in the app folder as administrator'
  Write-Host "('zapret-discord-youtube folder' opens it). Close its winws window before trying the next."
  Write-Host ''
  $bat = Join-Path $AppDir 'service.bat'
  # service.bat asks for admin rights itself unless its first argument is 'admin'.
  Start-Process -FilePath "$env:ComSpec" -ArgumentList '/d', '/c', "`"`"$bat`" admin`"" -WorkingDirectory $AppDir -NoNewWindow -Wait
}

# Guard: the read-only commands need no admin rights.
if ($Command -eq 'help') {
  Get-Help $PSCommandPath -Detailed
  return
}
if ($Command -eq 'status') {
  Show-Status
  return
}
if ($Command -eq 'folder') {
  Start-Process -FilePath explorer.exe -ArgumentList "`"$AppDir`""
  return
}

if (-not (Test-Admin)) {
  Invoke-Elevated
  return
}

$actions = @{
  'menu'    = { Open-Menu }
  'stop'    = { Stop-Bypass | Out-Null }
  'start'   = { Start-Bypass }
  'update'  = { Update-Bypass }
  'sync'    = { Invoke-Sync }
  'bundled' = { Set-Bundled $Value }
  'cleanup' = { Remove-Bypass }
}
& $actions[$Command]

if ($Pause) {
  Write-Host ''
  Read-Host 'Press Enter to close this window' | Out-Null
}
