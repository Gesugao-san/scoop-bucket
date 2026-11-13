<#
.SYNOPSIS
  Builds a Windows .ico file from PNG images stored inside a zip archive (a .jar is a zip too).

.DESCRIPTION
  Some apps ship their icon only as PNG resources inside a jar or zip, while a Start menu shortcut needs
  an .ico (or an .exe/.dll with an icon resource). Manifests call this from pre_install, so the icon is
  built from the very archive Scoop has just verified by hash; nothing extra is downloaded.

  Each PNG becomes one frame of the .ico unchanged: Windows Vista and later read PNG-compressed frames
  natively, so no image library is needed and no pixels are resampled. Frames are written smallest
  first, the order Windows expects.

  Missing entries are skipped with a warning. If none of them exists (upstream renamed or removed its
  icon), the script still writes a valid .ico with a single transparent 1x1 frame and warns: Scoop
  refuses to create a shortcut whose icon file is missing, and a shortcut without the right picture is
  better than no shortcut at all.

  Works in Windows PowerShell 5.1 and PowerShell 7, which are the two hosts Scoop runs in.

.PARAMETER Archive
  Path to the zip or jar file.

.PARAMETER Entry
  Full names of the PNG entries inside the archive, with forward slashes, as the zip stores them,
  e.g. 'net/nikr/eve/jeveasset/gui/images/misc_assets_64.png'.

.PARAMETER Destination
  Path of the .ico file to write. An existing file is replaced.

.OUTPUTS
  System.Int32. The number of frames taken from the archive (0 when the placeholder was written).

.EXAMPLE
  & .\New-IconFromArchive.ps1 -Archive "$dir\jeveassets.jar" -Destination "$dir\jEveAssets.ico" `
    -Entry 'net/nikr/eve/jeveasset/gui/images/misc_assets_32.png', 'net/nikr/eve/jeveasset/gui/images/misc_assets_64.png'
#>

param(
  [Parameter(Mandatory)]
  [string] $Archive,

  [Parameter(Mandatory)]
  [string[]] $Entry,

  [Parameter(Mandatory)]
  [string] $Destination
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# A transparent 1x1 PNG, used only when the archive has none of the requested entries.
$placeholderPng = [Convert]::FromBase64String(
  'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg=='
)

<#
.SYNOPSIS
  Reads the width and height of a PNG from its IHDR chunk.
.OUTPUTS
  A two-element array: width, height. Null when the bytes are not a PNG.
#>
function Get-PngSize([byte[]] $Png) {
  $signature = [byte[]](0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A)
  if ($Png.Length -lt 24) { return $null }
  for ($i = 0; $i -lt $signature.Length; $i++) {
    if ($Png[$i] -ne $signature[$i]) { return $null }
  }

  # IHDR starts at byte 8: length (4), type (4), then width and height as big-endian UInt32.
  $width = ([int]$Png[16] -shl 24) -bor ([int]$Png[17] -shl 16) -bor ([int]$Png[18] -shl 8) -bor [int]$Png[19]
  $height = ([int]$Png[20] -shl 24) -bor ([int]$Png[21] -shl 16) -bor ([int]$Png[22] -shl 8) -bor [int]$Png[23]
  return @($width, $height)
}

<#
.SYNOPSIS
  Reads the requested PNG entries from the archive.
.OUTPUTS
  PSCustomObject with Width, Height and Bytes, one per entry found, smallest first.
#>
function Read-PngFrame([string] $Path, [string[]] $Names) {
  Add-Type -AssemblyName System.IO.Compression.FileSystem

  $zip = [System.IO.Compression.ZipFile]::OpenRead($Path)
  try {
    $frames = foreach ($name in $Names) {
      $item = $zip.GetEntry($name)
      if (!$item) {
        Write-Warning "Icon image '$name' is not in '$Path'."
        continue
      }

      $buffer = New-Object System.IO.MemoryStream
      $stream = $item.Open()
      try { $stream.CopyTo($buffer) } finally { $stream.Dispose() }

      $bytes = $buffer.ToArray()
      $size = Get-PngSize $bytes
      if (!$size) {
        Write-Warning "Icon image '$name' in '$Path' is not a PNG."
        continue
      }

      [PSCustomObject]@{ Width = $size[0]; Height = $size[1]; Bytes = $bytes }
    }
  } finally {
    $zip.Dispose()
  }

  return @($frames | Sort-Object Width)
}

<#
.SYNOPSIS
  Writes frames as an .ico file: ICONDIR header, one ICONDIRENTRY per frame, then the PNG data.
#>
function Write-Ico([string] $Path, [object[]] $Frames) {
  $headerSize = 6
  $entrySize = 16

  $file = [System.IO.File]::Create($Path)
  $writer = New-Object System.IO.BinaryWriter($file)
  try {
    # ICONDIR: reserved, type 1 (icon), number of images.
    $writer.Write([UInt16]0)
    $writer.Write([UInt16]1)
    $writer.Write([UInt16]$Frames.Count)

    $offset = $headerSize + $entrySize * $Frames.Count
    foreach ($frame in $Frames) {
      # Width and height are one byte each; 0 means 256 (or more).
      $writer.Write([byte]($(if ($frame.Width -ge 256) { 0 } else { $frame.Width })))
      $writer.Write([byte]($(if ($frame.Height -ge 256) { 0 } else { $frame.Height })))
      $writer.Write([byte]0)        # colours in the palette: none
      $writer.Write([byte]0)        # reserved
      $writer.Write([UInt16]1)      # colour planes
      $writer.Write([UInt16]32)     # bits per pixel
      $writer.Write([UInt32]$frame.Bytes.Length)
      $writer.Write([UInt32]$offset)
      $offset += $frame.Bytes.Length
    }

    foreach ($frame in $Frames) { $writer.Write($frame.Bytes) }
  } finally {
    $writer.Dispose()
    $file.Dispose()
  }
}

if (!(Test-Path -LiteralPath $Archive)) { throw "Archive '$Archive' does not exist." }

# .NET resolves relative paths against the process directory, not PowerShell's current location.
$Archive = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($Archive)
$Destination = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($Destination)

# @() keeps a single frame an array: Windows PowerShell 5.1 in strict mode has no .Count on a lone object.
$frames = @(Read-PngFrame -Path $Archive -Names $Entry)
$found = $frames.Count

if ($found -eq 0) {
  Write-Warning "No icon image found in '$Archive'; writing a blank placeholder icon to '$Destination'."
  $frames = @([PSCustomObject]@{ Width = 1; Height = 1; Bytes = $placeholderPng })
}

Write-Ico -Path $Destination -Frames $frames
return $found

