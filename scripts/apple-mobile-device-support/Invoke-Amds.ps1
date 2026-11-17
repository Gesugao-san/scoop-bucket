<#
.SYNOPSIS
  Installs, upgrades, adopts or removes Apple Mobile Device Support (AMDS) for the
  Apple-Mobile-Device-Support package of the gesu Scoop bucket.

.DESCRIPTION
  AMDS is a per-machine MSI (AppleMobileDeviceSupport64.msi, taken from Apple's iTunes installer). It
  installs the 'Apple Mobile Device Service' (Apple's usbmuxd) into Program Files, so Scoop only keeps
  the MSI in the app folder and this script runs msiexec on it.

  Install action, by what is already on the machine:
    - no AMDS:                         install the MSI.
    - AMDS from an MSI, older:         upgrade it (the MSI is a WiX major upgrade).
    - AMDS from an MSI, same or newer: leave it as it is; Scoop tracks it from now on.
    - the service exists without the MSI (for example, a copy that another app ships): stop, because
      the MSI cannot create a service whose name is taken.

  Uninstall action: removes the MSI, unless iTunes is installed (iTunes needs AMDS).

  Around msiexec, the services that depend on 'Apple Mobile Device Service' are stopped. After an install
  or upgrade the ones that were running are started again; after an uninstall they stay stopped, since
  they cannot run without AMDS. The MSI stops and starts AMDS itself.

  The script throws on any error; the manifest turns that into Scoop's usual error message.

.PARAMETER Action
  'Install' (also used for updates) or 'Uninstall'.

.PARAMETER MsiPath
  Path to AppleMobileDeviceSupport64.msi. Install only.

.PARAMETER Version
  Version of the MSI in MsiPath, as in the manifest. Install only.

.PARAMETER LogPath
  Verbose msiexec log (msiexec /l*v).

.OUTPUTS
  A short status line for the user.

.EXAMPLE
  .\Invoke-Amds.ps1 -Action Install -MsiPath "$dir\AppleMobileDeviceSupport64.msi" -Version 20.0.1.47 -LogPath "$dir\install.log"
#>

[CmdletBinding()]
param(
  [Parameter(Mandatory)]
  [ValidateSet('Install', 'Uninstall')]
  [string] $Action,

  [string] $MsiPath,

  [string] $Version,

  [Parameter(Mandatory)]
  [string] $LogPath
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$ServiceName = 'Apple Mobile Device Service'
$ProductName = 'Apple Mobile Device Support'

# msiexec exit codes that mean success; anything else is an error.
$MsiSuccess = @{
  0    = $null
  1641 = 'Windows is restarting to finish the change.'
  3010 = 'Restart Windows to finish the change.'
}

<#
.SYNOPSIS
  Returns the uninstall entries (64-bit registry view) whose DisplayName matches exactly.
#>
function Get-UninstallEntry {
  param([Parameter(Mandatory)] [string] $DisplayName)

  $root = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall'
  Get-ChildItem $root -ErrorAction SilentlyContinue |
    Get-ItemProperty -ErrorAction SilentlyContinue |
    Where-Object { $_.PSObject.Properties['DisplayName'] -and $_.DisplayName -eq $DisplayName }
}

<#
.SYNOPSIS
  Returns the installed AMDS MSI (ProductCode and version), or $null.
#>
function Get-InstalledAmds {
  $entry = Get-UninstallEntry -DisplayName $ProductName |
    Where-Object { $_.PSChildName -match '^\{[0-9A-Fa-f-]{36}\}$' } |
    Select-Object -First 1
  if (-not $entry) { return $null }

  [pscustomobject]@{
    ProductCode = $entry.PSChildName
    Version     = [version] $entry.DisplayVersion
  }
}

<#
.SYNOPSIS
  Stops the running services that depend on AMDS and returns their names, so they can be started again.
#>
function Stop-DependentService {
  $service = Get-Service -Name $ServiceName -ErrorAction SilentlyContinue
  if (-not $service) { return @() }

  $running = @($service.DependentServices | Where-Object Status -eq 'Running')
  foreach ($dependent in $running) {
    Write-Host "Stopping '$($dependent.DisplayName)', it depends on $ServiceName."
    Stop-Service -Name $dependent.Name -Force
  }
  return @($running | ForEach-Object Name)
}

<#
.SYNOPSIS
  Starts the services that Stop-DependentService stopped. A failure is a warning, not an error:
  AMDS itself is already in place at this point.
#>
function Start-DependentService {
  param([string[]] $Name)

  foreach ($serviceName in $Name) {
    try {
      Start-Service -Name $serviceName
    } catch {
      Write-Warning "Could not start '$serviceName' again: $($_.Exception.Message)"
    }
  }
}

<#
.SYNOPSIS
  Runs msiexec with the given arguments, quietly, with a verbose log; throws on failure.
#>
function Invoke-Msiexec {
  param([Parameter(Mandatory)] [string[]] $Arguments)

  $allArguments = $Arguments + @('/qn', '/norestart', '/l*v', "`"$LogPath`"")
  $process = Start-Process msiexec.exe -ArgumentList $allArguments -Wait -PassThru
  $code = $process.ExitCode

  if (-not $MsiSuccess.ContainsKey($code)) {
    throw "msiexec failed with exit code $code. Log: $LogPath"
  }
  if ($MsiSuccess[$code]) { Write-Warning $MsiSuccess[$code] }
}

<#
.SYNOPSIS
  Runs msiexec while the dependent services are stopped, and starts them again afterwards.
#>
function Invoke-MsiexecWithServicesPaused {
  param([Parameter(Mandatory)] [string[]] $Arguments)

  $stopped = Stop-DependentService
  try {
    Invoke-Msiexec -Arguments $Arguments
  } finally {
    Start-DependentService -Name $stopped
  }
}

<#
.SYNOPSIS
  Installs, upgrades or adopts AMDS (see the script's description).
#>
function Install-Amds {
  if (-not $MsiPath -or -not (Test-Path $MsiPath)) { throw "MSI not found: $MsiPath" }
  if (-not $Version) { throw 'Install needs -Version.' }

  $wanted = [version] $Version
  $installed = Get-InstalledAmds

  if (-not $installed -and (Get-Service -Name $ServiceName -ErrorAction SilentlyContinue)) {
    $path = (Get-CimInstance Win32_Service -Filter "Name='$ServiceName'").PathName
    throw "'$ServiceName' already exists, but not from the $ProductName MSI ($path). " +
      'The MSI cannot install over a service it does not own. Remove the program that installed it first.'
  }

  if ($installed -and $installed.Version -ge $wanted) {
    return "$ProductName $($installed.Version) is already installed; Scoop tracks it from now on, nothing changed."
  }

  $verb = if ($installed) { "Upgrading $ProductName $($installed.Version) to $wanted" } else { "Installing $ProductName $wanted" }
  Write-Host "$verb..."
  Invoke-MsiexecWithServicesPaused -Arguments @('/i', "`"$MsiPath`"")
  return "$ProductName $wanted is installed."
}

<#
.SYNOPSIS
  Removes AMDS, unless iTunes still needs it.
#>
function Uninstall-Amds {
  $installed = Get-InstalledAmds
  if (-not $installed) { return "$ProductName is not installed; nothing to remove." }

  if (Get-UninstallEntry -DisplayName 'iTunes') {
    return "iTunes is installed and needs $ProductName, so it stays. Scoop no longer tracks it."
  }

  Write-Host "Removing $ProductName $($installed.Version)..."
  # Services that depend on AMDS cannot run without it, so they stay stopped.
  $stopped = Stop-DependentService
  Invoke-Msiexec -Arguments @('/x', $installed.ProductCode)
  if ($stopped) { Write-Warning "These services depend on AMDS and stay stopped: $($stopped -join ', ')" }
  return "$ProductName is removed."
}

# Action name -> handler.
$handlers = @{
  Install   = { Install-Amds }
  Uninstall = { Uninstall-Amds }
}

& $handlers[$Action]
