<#
.SYNOPSIS
  Lists why an app cannot be installed, updated or uninstalled right now: its running processes and its
  data files that another program holds open.

.DESCRIPTION
  Manifests call this from pre_install for 'scoop install', and from pre_uninstall for 'scoop update' and
  'scoop uninstall': Scoop runs pre_uninstall before it removes the old version, while the new version's
  pre_install only runs after that, so stopping there would leave the app half-updated.

  Scoop itself only refuses to update an app whose processes run from the app's own folder; this also
  catches a copy started from anywhere else (an older installer, a portable copy) and data folders
  outside Scoop, such as %APPDATA%\tixati, that the app or a backup or sync tool still has open.

  A file counts as busy when it cannot be opened exclusively (read access, no sharing): that fails only
  while some other handle is open, and unlike a write test it does not trip over read-only files.

  The script only reports; the manifest decides to stop, so the message and 'break' stay in Scoop's
  usual style.

.PARAMETER ProcessName
  Process names without '.exe', as Get-Process takes them, e.g. 'tixati'.

.PARAMETER Path
  Data folders to scan recursively. Folders that do not exist are skipped (e.g. on a first install).

.PARAMETER MaxFiles
  How many busy files to list by name; the rest are only counted.

.OUTPUTS
  System.String, one line per problem. No output means the app is idle.

.EXAMPLE
  & .\scripts\common\Test-AppBusy.ps1 -ProcessName tixati -Path "$env:APPDATA\tixati"
#>
[CmdletBinding()]
param(
  [Parameter(Mandatory)]
  [string[]] $ProcessName,

  [string[]] $Path = @(),

  [ValidateRange(1, [int]::MaxValue)]
  [int] $MaxFiles = 10
)

<#
.SYNOPSIS
  Describes every running process with one of the given names.
.OUTPUTS
  System.String per process: name, PID and executable path when Windows lets us read it.
#>
function Get-RunningProcessLines([string[]] $Names) {
  foreach ($process in @(Get-Process -Name $Names -ErrorAction SilentlyContinue)) {
    $where = if ($process.Path) { $process.Path } else { 'path not readable' }
    "running: $($process.ProcessName).exe (PID $($process.Id), $where)"
  }
}

<#
.SYNOPSIS
  Tells whether another handle holds the file open.
.OUTPUTS
  System.Boolean: $true when an exclusive open fails with a sharing violation.
#>
function Test-FileBusy([string] $File) {
  try {
    [System.IO.File]::Open($File, 'Open', 'Read', 'None').Dispose()
    return $false
  } catch {
    # Only ERROR_SHARING_VIOLATION (32) and ERROR_LOCK_VIOLATION (33) mean another handle; a file deleted
    # during the scan, access denied and the like say nothing about other programs.
    # PowerShell wraps exceptions from .NET method calls in MethodInvocationException.
    $exception = if ($_.Exception.InnerException) { $_.Exception.InnerException } else { $_.Exception }
    return ($exception.HResult -band 0xFFFF) -in 32, 33
  }
}

<#
.SYNOPSIS
  Describes the busy files under the given folders.
.OUTPUTS
  System.String per busy file (up to $Limit), then one summary line for the rest.
#>
function Get-BusyFileLines([string[]] $Folders, [int] $Limit) {
  $busy = @(
    foreach ($folder in $Folders) {
      if (!$folder -or !(Test-Path -LiteralPath $folder -PathType Container)) { continue }
      Get-ChildItem -LiteralPath $folder -File -Recurse -Force -ErrorAction SilentlyContinue |
        Where-Object { Test-FileBusy $_.FullName } |
        ForEach-Object FullName
    }
  )
  $busy | Select-Object -First $Limit | ForEach-Object { "in use: $_" }
  if ($busy.Count -gt $Limit) { "in use: $($busy.Count - $Limit) more file(s)" }
}

Get-RunningProcessLines $ProcessName
Get-BusyFileLines $Path $MaxFiles
