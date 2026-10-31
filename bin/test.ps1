#Requires -Version 5.1
#Requires -Modules @{ ModuleName = 'BuildHelpers'; ModuleVersion = '2.0.1' }
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.2.0' }

<#
.SYNOPSIS
  Runs Scoop's bucket tests (manifest schema and file style) with Pester.
.DESCRIPTION
  Used by the CI workflow; can also be run locally with SCOOP_HOME pointing to Scoop's own folder.
  Exits with the number of failed tests, so a non-zero exit code means failure.
#>

$pesterConfig = New-PesterConfiguration -Hashtable @{
  Run    = @{
    Path     = "$PSScriptRoot/.."
    PassThru = $true
  }
  Output = @{
    Verbosity = 'Detailed'
  }
}
$result = Invoke-Pester -Configuration $pesterConfig
exit $result.FailedCount
