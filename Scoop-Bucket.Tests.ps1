<#
.SYNOPSIS
  Entry point for Scoop's bucket tests.
.DESCRIPTION
  Scoop's file style tests read every file under the given path as text and require CRLF line endings.
  They only skip .exe, .zip and .dll, so the PNG files in icons/ and screenshots/ would always fail.
  Because of that, the tests run on bucket/ only: that is where the manifests live, and the schema
  validation looks there anyway.
#>

if (!$env:SCOOP_HOME) { $env:SCOOP_HOME = Resolve-Path (scoop prefix scoop) }
. "$env:SCOOP_HOME\test\Import-Bucket-Tests.ps1" -BucketPath "$PSScriptRoot\bucket"
