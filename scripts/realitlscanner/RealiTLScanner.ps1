<#
.SYNOPSIS
  Runs RealiTLScanner with a GeoIP database from the gesu/Loyalsoldier-GeoIP package, so the
  GEO_CODE column is filled without putting Country.mmdb into every folder.

.DESCRIPTION
  RealiTLScanner opens 'Country.mmdb' from its working folder only. The gesu/RealiTLScanner
  manifest copies this script into the app folder and makes it the 'realitlscanner' command:

  1. If the current folder has a Country.mmdb of its own, the scanner runs there unchanged,
     exactly as upstream documents it.
  2. Otherwise the script looks for the database in the Loyalsoldier-GeoIP package (the same
     Scoop apps folder first, then the user and global Scoop folders), copies it to a folder
     under %TEMP% as Country.mmdb (again only after the package updates it) and starts the
     scanner there. The copy keeps the package folder free, so 'scoop update' of the database
     works while a scan is running.
  3. Without a database the scanner runs unchanged and logs that GeoIP is off.

  Starting the scanner in another folder would move its relative paths there too, so in case 2
  the values of -in and -out are made absolute against the current folder first, and the default
  -out (out.csv) is passed explicitly: results still land where the scan was started.

  Set GESU_GEOIP_MMDB to choose another database: a file name from the Loyalsoldier-GeoIP folder
  (e.g. 'Country-without-asn.mmdb' for plain country codes instead of CLOUDFLARE, GOOGLE, ...),
  a full path to any MaxMind Country database, or 'none' to run the scanner without GeoIP.

.EXAMPLE
  realitlscanner -addr 203.0.113.0/24 -thread 10

.EXAMPLE
  $env:GESU_GEOIP_MMDB = 'Country-without-asn.mmdb'; realitlscanner -in targets.txt

.NOTES
  No param() block on purpose: every argument goes to $args untouched and is passed on to the
  scanner, whose flags (-in, -out, -v, ...) PowerShell must not bind itself.
  Must run on Windows PowerShell 5.1, which Scoop's shims use when called from cmd.
#>

Set-StrictMode -Version 2.0

# Name of the Scoop package that ships the databases (bucket/Loyalsoldier-GeoIP.json).
$GeoIpApp = 'Loyalsoldier-GeoIP'

# Flags of RealiTLScanner that take a value; Go's flag package reads it after '=' or from the next
# argument. $true marks a value that is a file path, relative to the folder the scan starts from.
$ValueFlags = @{
  addr    = $false
  in      = $true
  out     = $true
  port    = $false
  thread  = $false
  timeout = $false
  url     = $false
}

<#
.SYNOPSIS
  Returns the Scoop apps folders to search for the GeoIP package, the scanner's own first.
.PARAMETER AppDir
  Folder this script runs from (...\apps\RealiTLScanner\current).
#>
function Get-ScoopAppsDir {
  param([string] $AppDir)

  $ownApps = [IO.Path]::GetFullPath((Join-Path $AppDir '..\..'))
  $userRoot = $env:SCOOP
  if (-not $userRoot) { $userRoot = Join-Path $env:USERPROFILE 'scoop' }
  $globalRoot = $env:SCOOP_GLOBAL
  if (-not $globalRoot) { $globalRoot = Join-Path $env:ProgramData 'scoop' }

  @($ownApps, (Join-Path $userRoot 'apps'), (Join-Path $globalRoot 'apps')) | Select-Object -Unique
}

<#
.SYNOPSIS
  Finds the GeoIP database to use, or returns $null for none.
.PARAMETER AppDir
  Folder this script runs from.
#>
function Get-GeoIpDatabase {
  param([string] $AppDir)

  $choice = $env:GESU_GEOIP_MMDB
  if (-not $choice) { $choice = 'Country.mmdb' }
  if ($choice -eq 'none') { return $null }

  if ([IO.Path]::IsPathRooted($choice)) {
    if (Test-Path -LiteralPath $choice -PathType Leaf) { return $choice }
    Write-Warning "GESU_GEOIP_MMDB points to '$choice', which does not exist; running without GeoIP."
    return $null
  }

  foreach ($appsDir in Get-ScoopAppsDir -AppDir $AppDir) {
    $candidate = Join-Path $appsDir "$GeoIpApp\current\$choice"
    if (Test-Path -LiteralPath $candidate -PathType Leaf) { return $candidate }
  }
  if ($env:GESU_GEOIP_MMDB) {
    Write-Warning "'$choice' (GESU_GEOIP_MMDB) is not in the $GeoIpApp package; running without GeoIP."
  }
  return $null
}

<#
.SYNOPSIS
  Copies the database to %TEMP%\RealiTLScanner-GeoIP\<name>\Country.mmdb when it changed, and
  returns that folder; $null if there is no usable copy.
.PARAMETER Source
  Full path of the database to use.
#>
function Sync-GeoIpCopy {
  param([string] $Source)

  $name = [IO.Path]::GetFileNameWithoutExtension($Source)
  $workDir = Join-Path ([IO.Path]::GetTempPath()) "RealiTLScanner-GeoIP\$name"
  $target = Join-Path $workDir 'Country.mmdb'
  $sourceItem = Get-Item -LiteralPath $Source
  $targetItem = Get-Item -LiteralPath $target -ErrorAction SilentlyContinue

  $isCurrent = $targetItem -and
    $targetItem.Length -eq $sourceItem.Length -and
    $targetItem.LastWriteTimeUtc -eq $sourceItem.LastWriteTimeUtc
  if ($isCurrent) { return $workDir }

  try {
    New-Item -ItemType Directory -Path $workDir -Force -ErrorAction Stop | Out-Null
    # Copy-Item keeps the modification time, which the check above compares next time.
    Copy-Item -LiteralPath $Source -Destination $target -Force -ErrorAction Stop
    return $workDir
  } catch {
    # Usually another scan still has the old copy open (it is memory-mapped).
    if ($targetItem) {
      Write-Warning "Could not refresh the GeoIP copy ($($_.Exception.Message)); using the previous one."
      return $workDir
    }
    Write-Warning "Could not copy the GeoIP database ($($_.Exception.Message)); running without GeoIP."
    return $null
  }
}

<#
.SYNOPSIS
  Returns the scanner's arguments with the paths of -in and -out made absolute against BaseDir,
  and an explicit -out when none was given.
.DESCRIPTION
  Rewritten flags are passed as -name=value: an empty value (-out "" turns the CSV file off) then
  survives Windows PowerShell 5.1, which drops empty arguments to native programs. Parsing stops
  where Go's flag package stops: at '--' or at the first argument that is not a flag.
.PARAMETER Arguments
  The arguments given to this script.
.PARAMETER BaseDir
  Folder the scan was started from.
#>
function Convert-ScannerArgument {
  param([object[]] $Arguments, [string] $BaseDir)

  $result = New-Object System.Collections.Generic.List[string]
  $hasOut = $false
  $i = 0
  while ($i -lt $Arguments.Count) {
    $token = [string] $Arguments[$i]
    $i++
    if ($token -eq '--' -or $token -notmatch '^--?([^-=][^=]*)(=(.*))?$') {
      $result.Add($token)
      while ($i -lt $Arguments.Count) { $result.Add([string] $Arguments[$i]); $i++ }
      break
    }

    $name = $Matches[1]
    $hasInlineValue = [bool] $Matches[2]
    $value = $Matches[3]
    # Flags without a value (-v, -46, -h) and unknown ones are the scanner's business.
    if (-not $ValueFlags.ContainsKey($name)) { $result.Add($token); continue }

    if (-not $hasInlineValue) {
      # A missing value is left for the scanner to report.
      if ($i -ge $Arguments.Count) { $result.Add($token); continue }
      $value = [string] $Arguments[$i]
      $i++
    }
    if ($name -eq 'out') { $hasOut = $true }
    if ($ValueFlags[$name] -and $value) {
      $value = [IO.Path]::GetFullPath([IO.Path]::Combine($BaseDir, $value))
    }
    $result.Add("-$name=$value")
  }

  # First, so that it is parsed even if a non-flag argument stops Go's parser later on.
  if (-not $hasOut) { $result.Insert(0, '-out=' + (Join-Path $BaseDir 'out.csv')) }
  return , $result.ToArray()
}

$scanner = Join-Path $PSScriptRoot 'RealiTLScanner.exe'
if (-not (Test-Path -LiteralPath $scanner -PathType Leaf)) {
  Write-Error "RealiTLScanner.exe is missing from $PSScriptRoot; reinstall with 'scoop install gesu/RealiTLScanner'."
  exit 1
}

# The folder the user started the scan from. Outside the file system (e.g. in HKLM:) use the
# process's own current folder, as a native program would.
$location = Get-Location
$callerDir = [Environment]::CurrentDirectory
if ($location.Provider.Name -eq 'FileSystem') { $callerDir = $location.ProviderPath }

# Case 1: a database of the user's own next to the scan, as upstream documents.
if (Test-Path -LiteralPath (Join-Path $callerDir 'Country.mmdb') -PathType Leaf) {
  & $scanner @args
  exit $LASTEXITCODE
}

$database = Get-GeoIpDatabase -AppDir $PSScriptRoot
$workDir = $null
if ($database) { $workDir = Sync-GeoIpCopy -Source $database }

# Case 3: no database; the scanner logs that GeoIP is off.
if (-not $workDir) {
  & $scanner @args
  exit $LASTEXITCODE
}

# Case 2: run in the folder with the copy, with the paths fixed up.
$scannerArgs = Convert-ScannerArgument -Arguments $args -BaseDir $callerDir
# To stderr, so it stays out of the scanner's own output when that is redirected to a file.
[Console]::Error.WriteLine("GeoIP database: $database")
Push-Location -LiteralPath $workDir
try {
  & $scanner @scannerArgs
} finally {
  Pop-Location
}
exit $LASTEXITCODE
