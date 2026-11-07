<#
.SYNOPSIS
  Downloads an app's file from a mirror into Scoop's cache, so that 'scoop install' or 'scoop update' uses it.

.DESCRIPTION
  Scoop has no fallback URLs: a manifest's 'url' array lists different files, not alternatives for one file,
  and a failed download stops the install before any manifest script runs. But Scoop looks in its cache
  before downloading, so a file put there under the expected name is used as if it had been downloaded.

  This script reads the app's manifest through Scoop's own functions, works out the cache file name that
  Scoop expects for the manifest URL, downloads the mirror URL, checks the file against the manifest's hash
  and only then moves it into the cache. A mirror can therefore only supply the exact file the manifest
  describes; Scoop checks the hash again when it installs.

  Scoop's lib/ is dot-sourced, so the cache file name, cache folder and default architecture always match
  the installed Scoop version. If a Scoop update renames those functions, this script stops with an error
  instead of guessing.

.PARAMETER App
  App name as passed to 'scoop install', with or without the bucket: 'TrueConf' or 'gesu/TrueConf'.

.PARAMETER MirrorUrl
  URL of the same file on another host.

.PARAMETER Architecture
  32bit, 64bit or arm64. Defaults to the architecture Scoop would choose.

.PARAMETER Index
  Which file to fetch when the manifest lists several URLs for this architecture (0 = first).

.EXAMPLE
  .\bin\Use-Mirror.ps1 gesu/TrueConf https://download.trueconf.ru/download/client/windows/trueconf_client_x64.msi
  scoop install gesu/TrueConf

.NOTES
  The manifest's URL is part of the cache file name, so a new version needs a new run of this script.
#>
[CmdletBinding()]
param (
  [Parameter(Mandatory = $true, Position = 0)]
  [string] $App,

  [Parameter(Mandatory = $true, Position = 1)]
  [string] $MirrorUrl,

  [ValidateSet('32bit', '64bit', 'arm64')]
  [string] $Architecture,

  [ValidateRange(0, [int]::MaxValue)]
  [int] $Index = 0
)

$ErrorActionPreference = 'Stop'
# Windows PowerShell's progress bar slows Invoke-WebRequest down a lot on large files.
$ProgressPreference = 'SilentlyContinue'

# Hash prefixes Scoop accepts in manifests, mapped to Get-FileHash algorithm names; no prefix means SHA256.
$hashAlgorithms = @{
  'md5'    = 'MD5'
  'sha1'   = 'SHA1'
  'sha256' = 'SHA256'
  'sha512' = 'SHA512'
}

<#
.SYNOPSIS
  Splits a manifest hash such as 'sha512:abc...' into the algorithm and the lower-case value.
.OUTPUTS
  System.String[] with two items: the Get-FileHash algorithm name and the expected hash.
#>
function Split-ManifestHash([string] $Hash) {
  if ($Hash -notmatch '^(?<prefix>[a-z0-9]+):(?<value>.+)$') {
    return 'SHA256', $Hash.ToLower()
  }
  $algorithm = $hashAlgorithms[$Matches.prefix.ToLower()]
  if (!$algorithm) { throw "Unsupported hash type '$($Matches.prefix)' in the manifest." }
  return $algorithm, $Matches.value.ToLower()
}

# Load Scoop's own helpers (foreach, not ForEach-Object: a script block would scope the dot-sourcing away).
if (!$env:SCOOP_HOME) { $env:SCOOP_HOME = Convert-Path (scoop prefix scoop) }
foreach ($lib in 'core', 'buckets', 'json', 'versions', 'manifest') {
  . "$env:SCOOP_HOME\lib\$lib.ps1"
}

$appName, $manifest, $bucket, $null = Get-Manifest $App
if (!$manifest) { throw "Couldn't find a manifest for '$App'. Run 'scoop update' and check the name." }
if (!$Architecture) { $Architecture = Get-DefaultArchitecture }

$urls = @(@(url $manifest $Architecture) | Where-Object { $_ })
$hashes = @(hash $manifest $Architecture)
if ($urls.Count -eq 0) { throw "'$appName' has no download for $Architecture." }
if ($Index -ge $urls.Count) { throw "'$appName' lists $($urls.Count) URL(s) for $Architecture; -Index $Index is out of range." }

$manifestUrl = @($urls)[$Index]
$manifestHash = @($hashes)[$Index]
if (!$manifestHash) { throw "The manifest has no hash for this file, so a mirror's copy cannot be checked." }
$algorithm, $expected = Split-ManifestHash $manifestHash

$target = cache_path $appName $manifest.version $manifestUrl
if (Test-Path $target) {
  Write-Host "Already in the cache: $target"
  return
}

$partial = "$target.mirror"
New-Item -ItemType Directory -Path (Split-Path $target) -Force | Out-Null
Write-Host "Downloading $MirrorUrl"
try {
  Invoke-WebRequest -Uri $MirrorUrl -OutFile $partial -UseBasicParsing
  $actual = (Get-FileHash -Path $partial -Algorithm $algorithm).Hash.ToLower()
  if ($actual -ne $expected) {
    throw "The mirror's file does not match the manifest.`n  Expected ($algorithm): $expected`n  Actual:   $actual"
  }
  Move-Item -Path $partial -Destination $target -Force
} finally {
  if (Test-Path $partial) { Remove-Item $partial -Force }
}

Write-Host "Hash OK. Cached as $target" -ForegroundColor Green
Write-Host "Now run: scoop install $App   (or 'scoop update $appName' if it is already installed)"
