<#
.SYNOPSIS
  Entry point for Scoop's bucket tests.
.DESCRIPTION
  Scoop's file style tests read every file under the given path as text and require CRLF line endings.
  They only skip .exe, .zip and .dll, so the PNG files in icons/ and screenshots/ would always fail.
  Because of that, the style tests run on bucket/ only: that is where the manifests live.

  The schema check is done here instead of by Scoop's Import-Bucket-Tests.ps1. In CI, Scoop's version
  checks the *.json files changed in the last commit only, anywhere in the repository: it misses
  manifests changed earlier in the same push and treats data files outside bucket/ as manifests.
  This one checks the manifests in bucket/ that changed since $env:BASE_SHA (set by ci.yml to the
  commit before the push, or to the base of a pull request). Without a usable BASE_SHA, for example
  when run locally or by hand, it checks every manifest.
#>

if (!$env:SCOOP_HOME) { $env:SCOOP_HOME = Resolve-Path (scoop prefix scoop) }

. "$env:SCOOP_HOME\test\Scoop-00File.Tests.ps1" -TestPath "$PSScriptRoot\bucket"

Describe 'Manifest validates against the schema' {
  BeforeDiscovery {
    $bucketDir = Join-Path $PSScriptRoot 'bucket'
    $allManifests = (Get-ChildItem $bucketDir -Filter '*.json').FullName

    # A push that creates a branch has an all-zero "before"; there is nothing to compare with then.
    $base = $env:BASE_SHA
    $hasBase = $base -and ($base -notmatch '^0+$') -and (git -C $PSScriptRoot cat-file -t $base 2>$null) -eq 'commit'
    if (!$hasBase) {
      $manifestFiles = $allManifests
      return
    }

    # Changed, added or renamed manifests; deleted ones have nothing left to check.
    $changed = git -C $PSScriptRoot diff --name-only --diff-filter=d $base HEAD -- 'bucket/*.json'
    $manifestFiles = @($changed | ForEach-Object { Join-Path $PSScriptRoot $_ } | Where-Object { Test-Path $_ })
  }

  BeforeAll {
    Add-Type -Path "$env:SCOOP_HOME\supporting\validator\bin\Scoop.Validator.dll"
    # Could not use backslash '\' in Linux/macOS for .NET object 'Scoop.Validator'
    $validator = New-Object Scoop.Validator("$env:SCOOP_HOME/schema.json", $true)
    $global:quotaExceeded = $false
  }

  # Nothing changed in bucket/: no schema tests at all.
  if ($manifestFiles.Count -gt 0) {
    It '<_>' -ForEach $manifestFiles {
      if ($global:quotaExceeded) {
        Set-ItResult -Skipped -Because 'Schema validation limit exceeded.'
        return
      }
      $file = $_ # exception handling may overwrite $_
      try {
        $validator.Validate($file)
        if ($validator.Errors.Count -gt 0) {
          Write-Host "  [-] $file has $($validator.Errors.Count) error(s):" -ForegroundColor Red
          Write-Host $validator.ErrorsAsString -ForegroundColor Yellow
        }
        $validator.Errors.Count | Should -Be 0
      } catch {
        if ($_.Exception.Message -notlike '*The free-quota limit of 1000 schema validations per hour has been reached.*') { throw }
        $global:quotaExceeded = $true
        Set-ItResult -Skipped -Because 'Schema validation limit exceeded.'
      }
    }
  }
}
