<#
.SYNOPSIS
  Finds the current iTunes x64 installer and the version of Apple Mobile Device Support (AMDS) inside it,
  for the checkver of the Apple-Mobile-Device-Support package.

.DESCRIPTION
  Apple's permanent link (https://www.apple.com/itunes/download/win64) redirects to the current
  iTunes64Setup.exe on secure-appldnld.apple.com. Each release gets a new folder in that URL.

  The package version is the AMDS version, which is only written inside the MSI. So:
    - same URL as in the manifest: no new release, the manifest's version is returned and nothing is
      downloaded;
    - new URL: the installer (about 200 MB) is downloaded, AppleMobileDeviceSupport64.msi is extracted
      with 7-Zip and its ProductVersion is read through the Windows Installer COM API.

  Windows only (7-Zip and Windows Installer are needed); Excavator runs on windows-latest.

.PARAMETER CurrentUrl
  The manifest's url, with or without the '#/dl.7z' suffix.

.PARAMETER CurrentVersion
  The manifest's version.

.OUTPUTS
  One line: '<AMDS version> <installer URL>', for the checkver regex.

.EXAMPLE
  .\Get-AmdsRelease.ps1 -CurrentUrl $json.url -CurrentVersion $json.version
#>

[CmdletBinding()]
param(
  [Parameter(Mandatory)]
  [string] $CurrentUrl,

  [Parameter(Mandatory)]
  [string] $CurrentVersion
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$PermanentLink = 'https://www.apple.com/itunes/download/win64'
$MsiName = 'AppleMobileDeviceSupport64.msi'

<#
.SYNOPSIS
  Returns where the permanent link redirects to, without following it.
#>
function Get-RedirectTarget {
  param([Parameter(Mandatory)] [string] $Url)

  $handler = [System.Net.Http.HttpClientHandler]::new()
  $handler.AllowAutoRedirect = $false
  $client = [System.Net.Http.HttpClient]::new($handler)
  try {
    $request = [System.Net.Http.HttpRequestMessage]::new([System.Net.Http.HttpMethod]::Head, $Url)
    $response = $client.SendAsync($request).GetAwaiter().GetResult()
    $location = $response.Headers.Location
    if (-not $location) { throw "$Url did not redirect (HTTP $([int] $response.StatusCode))." }
    return $location.AbsoluteUri
  } finally {
    $client.Dispose()
  }
}

<#
.SYNOPSIS
  Returns the path of 7z.exe: Scoop's 7zip, one on the PATH, or the regular 7-Zip install.
#>
function Get-SevenZip {
  $candidates = @(
    (Get-Command 7z.exe -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Source),
    "$env:ProgramFiles\7-Zip\7z.exe"
  )
  $found = $candidates | Where-Object { $_ -and (Test-Path $_) } | Select-Object -First 1
  if (-not $found) { throw '7-Zip (7z.exe) not found.' }
  return $found
}

<#
.SYNOPSIS
  Reads one property from the Property table of an MSI through the Windows Installer COM API.
  InvokeMember works the same in Windows PowerShell and PowerShell 7.
#>
function Get-MsiProperty {
  param(
    [Parameter(Mandatory)] [string] $Path,
    [Parameter(Mandatory)] [string] $Property
  )

  $flags = [System.Reflection.BindingFlags]
  $installer = New-Object -ComObject WindowsInstaller.Installer
  $database = $installer.GetType().InvokeMember('OpenDatabase', $flags::InvokeMethod, $null, $installer, @($Path, 0))
  $query = "SELECT ``Value`` FROM ``Property`` WHERE ``Property`` = '$Property'"
  $view = $database.GetType().InvokeMember('OpenView', $flags::InvokeMethod, $null, $database, @($query))
  try {
    [void] $view.GetType().InvokeMember('Execute', $flags::InvokeMethod, $null, $view, $null)
    $record = $view.GetType().InvokeMember('Fetch', $flags::InvokeMethod, $null, $view, $null)
    if (-not $record) { throw "$Property not found in $Path." }
    return $record.GetType().InvokeMember('StringData', $flags::GetProperty, $null, $record, @(1))
  } finally {
    [void] $view.GetType().InvokeMember('Close', $flags::InvokeMethod, $null, $view, $null)
    [void] [System.Runtime.InteropServices.Marshal]::ReleaseComObject($database)
    [void] [System.Runtime.InteropServices.Marshal]::ReleaseComObject($installer)
  }
}

<#
.SYNOPSIS
  Downloads the installer, extracts the AMDS MSI and returns its ProductVersion.
#>
function Get-AmdsVersionFromInstaller {
  param([Parameter(Mandatory)] [string] $Url)

  $work = Join-Path ([System.IO.Path]::GetTempPath()) "amds-checkver-$([guid]::NewGuid())"
  New-Item -ItemType Directory -Path $work | Out-Null
  try {
    $setup = Join-Path $work 'iTunes64Setup.exe'
    Invoke-WebRequest -Uri $Url -OutFile $setup -UseBasicParsing
    & (Get-SevenZip) e -y "-o$work" $setup $MsiName | Out-Null
    if ($LASTEXITCODE -ne 0) { throw "7-Zip could not extract $MsiName (exit code $LASTEXITCODE)." }
    return Get-MsiProperty -Path (Join-Path $work $MsiName) -Property 'ProductVersion'
  } finally {
    Remove-Item $work -Recurse -Force -ErrorAction SilentlyContinue
  }
}

$latestUrl = Get-RedirectTarget -Url $PermanentLink
$knownUrl = ($CurrentUrl -split '#')[0]

if ($latestUrl -eq $knownUrl) {
  "$CurrentVersion $latestUrl"
  return
}

"$(Get-AmdsVersionFromInstaller -Url $latestUrl) $latestUrl"
