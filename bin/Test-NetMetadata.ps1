#Requires -Version 7
<#
.SYNOPSIS
  Takes a metadata snapshot of .NET assemblies and compares it with an approved baseline, to spot a
  release that suddenly gains capabilities its previous version did not have.

.DESCRIPTION
  Some apps in this bucket are closed builds that upstream uploads by hand, with no source for the
  latest version and no signature (EVE-IPH). A compromised upload would look exactly like a normal
  one, so this script looks inside: for every .NET assembly it records what the code can reach.

    AssemblyRefs  libraries the assembly links against
    ModuleRefs    native DLLs it imports from
    PInvokes      native functions it calls (DllImport)
    TypeRefs      types it uses from other assemblies
    MemberRefs    methods and fields it uses from other assemblies (Type::Member)
    Strings       string literals in the code (#US heap)
    Methods       IL size of every method body (Type::Method -> bytes)

  A file without .NET metadata (a native DLL) is recorded by SHA-256 only.

  With -Baseline, the current snapshot is compared with the approved one and every finding gets a level:

    red     the new build links a new library or native DLL, calls a new native function, starts using
            networking, processes, the registry, dynamic code loading or code generation, or contains a
            new string that looks like a URL, an IP address, a command or a registry path;
    yellow  more methods changed than -MaxChangedMethods, a native file changed, or a file appeared
            or disappeared;
    info    anything else that is new (plain strings, harmless types).

  What it cannot see: malicious logic added inside an existing method without any new string or
  reference. The yellow method-count threshold is the only signal for that.

  Requires PowerShell 7: System.Reflection.Metadata is part of .NET, not of Windows PowerShell 5.1.

.PARAMETER Path
  The files to inspect. The snapshot keys them by file name, so names must be unique.

.PARAMETER Baseline
  JSON snapshot of the approved build. Without it the script only takes a snapshot.

.PARAMETER SnapshotFile
  Where to write the snapshot of -Path as JSON (to become the next baseline once approved).

.PARAMETER ReportFile
  Where to write a Markdown report of the comparison, for an issue or a pull request body.

.PARAMETER MaxChangedMethods
  How many methods may be added, removed or change their IL size, per assembly, before it turns yellow.

.OUTPUTS
  Exit code 0 when nothing is red (yellow and info are reported only), 1 when something is red,
  2 on usage errors.

.EXAMPLE
  ./bin/Test-NetMetadata.ps1 -Path 'app/EVE Isk per Hour.exe', 'app/EVEIPH Updater.exe' `
    -Baseline scripts/eve-iph/baseline.snapshot -SnapshotFile new.json -ReportFile report.md
#>

[CmdletBinding()]
param(
  [Parameter(Mandatory)]
  [string[]] $Path,

  [string] $Baseline,

  [string] $SnapshotFile,

  [string] $ReportFile,

  [int] $MaxChangedMethods = 5
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# Any unexpected error ends with exit code 2, so it is never mistaken for a red finding (1) or a pass (0).
trap {
  [Console]::Error.WriteLine("Test-NetMetadata failed: $_")
  exit 2
}

# References that give code new reach: network, processes, registry, loading or generating code.
$riskyTypePattern = '^(System\.Net(\.|$)|System\.Diagnostics\.Process|Microsoft\.Win32\.Registry|' +
  'System\.Reflection\.Emit|System\.Runtime\.Loader|System\.Management|System\.DirectoryServices|' +
  'System\.Security\.Cryptography\.ProtectedData|Microsoft\.VisualBasic\.Interaction)'
$riskyMemberPattern = '(::Load(From|File)?$|::UnsafeLoadFrom$|^System\.Activator::CreateInstance|' +
  '^System\.Diagnostics\.Process::Start$|^System\.Runtime\.InteropServices\.Marshal::GetDelegateForFunctionPointer$|' +
  '^Microsoft\.VisualBasic\.Interaction::Shell$)'
$riskyStringPattern = '(?i)(\b(https?|ftp|wss?)://|\b\d{1,3}(\.\d{1,3}){3}\b|\b(cmd|powershell|pwsh|rundll32|regsvr32|' +
  'mshta|certutil|bitsadmin|schtasks|wscript|cscript)(\.exe)?\b|^HKEY_|\\(Software|CurrentVersion\\Run)\\|' +
  '\.(ps1|vbs|bat|cmd|scr|hta)\b)'

# Which list in a snapshot is judged by which rule. Lists not named here are reported as info.
$redWhenNew = @{
  AssemblyRefs = { $true }
  ModuleRefs   = { $true }
  PInvokes     = { $true }
  TypeRefs     = { param($item) $item -match $riskyTypePattern }
  MemberRefs   = { param($item) $item -match $riskyMemberPattern -or ($item -split '::')[0] -match $riskyTypePattern }
  Strings      = { param($item) $item -match $riskyStringPattern }
}

<#
.SYNOPSIS
  Full name of a TypeReference or TypeDefinition handle, nested types as Outer/Inner.
#>
function Get-TypeName($Reader, $Handle) {
  # Typed handles (TypeDefinitionHandle and so on) convert implicitly; only EntityHandle has .Kind.
  $Handle = [System.Reflection.Metadata.EntityHandle]$Handle
  switch ($Handle.Kind) {
    'TypeReference' {
      $type = $Reader.GetTypeReference([System.Reflection.Metadata.TypeReferenceHandle]$Handle)
      $name = $Reader.GetString($type.Name)
      if ($type.ResolutionScope.Kind -eq 'TypeReference') {
        return "$(Get-TypeName $Reader $type.ResolutionScope)/$name"
      }
      $namespace = $Reader.GetString($type.Namespace)
      return $(if ($namespace) { "$namespace.$name" } else { $name })
    }
    'TypeDefinition' {
      $type = $Reader.GetTypeDefinition([System.Reflection.Metadata.TypeDefinitionHandle]$Handle)
      $name = $Reader.GetString($type.Name)
      $outer = $type.GetDeclaringType()
      if (!$outer.IsNil) { return "$(Get-TypeName $Reader $outer)/$name" }
      $namespace = $Reader.GetString($type.Namespace)
      return $(if ($namespace) { "$namespace.$name" } else { $name })
    }
    'TypeSpecification' { return '(generic)' }
    default { return "($($Handle.Kind))" }
  }
}

<#
.SYNOPSIS
  Reads every metadata list of one assembly. Returns $null when the file has no .NET metadata.
#>
function Read-Assembly([string] $File) {
  $stream = [System.IO.File]::OpenRead($File)
  $pe = [System.Reflection.PortableExecutable.PEReader]::new($stream)
  try {
    if (!$pe.HasMetadata) { return $null }
    $md = [System.Reflection.Metadata.PEReaderExtensions]::GetMetadataReader($pe)
    $tokens = [System.Reflection.Metadata.Ecma335.MetadataTokens]

    $assemblyRefs = foreach ($h in $md.AssemblyReferences) {
      $ref = $md.GetAssemblyReference($h)
      '{0} {1}' -f $md.GetString($ref.Name), $ref.Version
    }

    $moduleCount = [System.Reflection.Metadata.Ecma335.MetadataReaderExtensions]::GetTableRowCount($md, [System.Reflection.Metadata.Ecma335.TableIndex]::ModuleRef)
    $moduleRefs = for ($i = 1; $i -le $moduleCount; $i++) {
      $md.GetString($md.GetModuleReference($tokens::ModuleReferenceHandle($i)).Name)
    }

    $typeRefs = foreach ($h in $md.TypeReferences) { Get-TypeName $md $h }

    $memberRefs = foreach ($h in $md.MemberReferences) {
      $ref = $md.GetMemberReference($h)
      $parent = if ($ref.Parent.Kind -in 'TypeReference', 'TypeDefinition') { Get-TypeName $md $ref.Parent } else { "($($ref.Parent.Kind))" }
      "${parent}::$($md.GetString($ref.Name))"
    }

    $strings = [System.Collections.Generic.List[string]]::new()
    $handle = $tokens::UserStringHandle(1)
    while (!$handle.IsNil -and $tokens::GetHeapOffset($handle) -lt [System.Reflection.Metadata.Ecma335.MetadataReaderExtensions]::GetHeapSize($md, [System.Reflection.Metadata.Ecma335.HeapIndex]::UserString)) {
      $strings.Add($md.GetUserString($handle))
      $handle = [System.Reflection.Metadata.Ecma335.MetadataReaderExtensions]::GetNextHandle($md, $handle)
    }

    $pinvokes = [System.Collections.Generic.List[string]]::new()
    $methods = [ordered]@{}
    foreach ($typeHandle in $md.TypeDefinitions) {
      $typeName = Get-TypeName $md $typeHandle
      foreach ($methodHandle in $md.GetTypeDefinition($typeHandle).GetMethods()) {
        $method = $md.GetMethodDefinition($methodHandle)
        $key = "${typeName}::$($md.GetString($method.Name))"

        $import = $method.GetImport()
        if (!$import.Module.IsNil) {
          $pinvokes.Add("$($md.GetString($md.GetModuleReference($import.Module).Name))!$($md.GetString($import.Name))")
        }
        if ($method.RelativeVirtualAddress -eq 0) { continue }

        # Overloads share a name; number them in metadata order so keys stay unique.
        $unique = $key
        for ($n = 2; $methods.Contains($unique); $n++) { $unique = "$key#$n" }
        $methods[$unique] = [System.Reflection.Metadata.PEReaderExtensions]::GetMethodBody($pe, $method.RelativeVirtualAddress).Size
      }
    }

    return [ordered]@{
      AssemblyRefs = @($assemblyRefs | Sort-Object -Unique)
      ModuleRefs   = @($moduleRefs | Sort-Object -Unique)
      PInvokes     = @($pinvokes | Sort-Object -Unique)
      TypeRefs     = @($typeRefs | Sort-Object -Unique)
      MemberRefs   = @($memberRefs | Sort-Object -Unique)
      Strings      = @($strings | Sort-Object -Unique)
      Methods      = $methods
    }
  } finally {
    $pe.Dispose()
    $stream.Dispose()
  }
}

<#
.SYNOPSIS
  Snapshot of one file: the metadata lists, or the SHA-256 of a native file.
#>
function Get-FileSnapshot([string] $File) {
  $assembly = Read-Assembly $File
  if ($assembly) { return [ordered]@{ Kind = 'managed' } + $assembly }
  return [ordered]@{ Kind = 'native'; Sha256 = (Get-FileHash -LiteralPath $File -Algorithm SHA256).Hash.ToLowerInvariant() }
}

<#
.SYNOPSIS
  Finding record used by the comparison and the report.
#>
function New-Finding([string] $Level, [string] $File, [string] $Area, [string] $Text) {
  [PSCustomObject]@{ Level = $Level; File = $File; Area = $Area; Text = $Text }
}

<#
.SYNOPSIS
  Methods added, removed or with a different IL size between two method tables.
#>
function Compare-MethodTable($Old, $New) {
  $oldMethods = @{}; foreach ($p in $Old.PSObject.Properties) { $oldMethods[$p.Name] = [int]$p.Value }
  $newMethods = @{}; foreach ($p in $New.GetEnumerator()) { $newMethods[$p.Key] = [int]$p.Value }

  $changes = foreach ($name in $newMethods.Keys) {
    if (!$oldMethods.ContainsKey($name)) { "added: $name ($($newMethods[$name]) bytes)"; continue }
    if ($oldMethods[$name] -ne $newMethods[$name]) { "changed: $name ($($oldMethods[$name]) -> $($newMethods[$name]) bytes)" }
  }
  $removed = foreach ($name in $oldMethods.Keys) {
    if (!$newMethods.ContainsKey($name)) { "removed: $name" }
  }
  return @(@($changes) + @($removed) | Where-Object { $_ } | Sort-Object)
}

<#
.SYNOPSIS
  Compares the snapshot of one managed file with its baseline entry.
#>
function Compare-ManagedFile([string] $Name, $Old, $New) {
  foreach ($area in $redWhenNew.Keys) {
    $before = [System.Collections.Generic.HashSet[string]]::new([string[]]@($Old.$area))
    foreach ($item in $New[$area]) {
      if ($before.Contains($item)) { continue }
      $level = if (& $redWhenNew[$area] $item) { 'red' } else { 'info' }
      New-Finding $level $Name $area "new: $item"
    }
  }

  $methodChanges = @(Compare-MethodTable $Old.Methods $New.Methods)
  if ($methodChanges.Count -eq 0) { return }
  $level = if ($methodChanges.Count -gt $MaxChangedMethods) { 'yellow' } else { 'info' }
  New-Finding $level $Name 'Methods' "$($methodChanges.Count) method(s) added, removed or resized (limit $MaxChangedMethods)"
  foreach ($change in $methodChanges) { New-Finding 'info' $Name 'Methods' $change }
}

<#
.SYNOPSIS
  Compares the whole snapshot with the baseline and returns the findings.
#>
function Compare-Snapshot($Old, $New) {
  $oldNames = @($Old.PSObject.Properties.Name)
  foreach ($name in $New.Keys) {
    if ($name -notin $oldNames) { New-Finding 'yellow' $name 'File' 'new file, no baseline to compare with'; continue }
    $before = $Old.$name
    $after = $New[$name]

    if ($before.Kind -ne $after.Kind) { New-Finding 'red' $name 'File' "kind changed: $($before.Kind) -> $($after.Kind)"; continue }
    if ($after.Kind -eq 'native') {
      if ($before.Sha256 -ne $after.Sha256) { New-Finding 'yellow' $name 'File' 'native file changed' }
      continue
    }
    Compare-ManagedFile $name $before $after
  }
  foreach ($name in $oldNames) {
    if (!$New.Contains($name)) { New-Finding 'yellow' $name 'File' 'file disappeared' }
  }
}

<#
.SYNOPSIS
  Markdown report: red and yellow first, then info, grouped by file.
#>
function Format-Report($Findings) {
  $order = @{ red = 0; yellow = 1; info = 2 }
  $mark = @{ red = ':red_circle:'; yellow = ':yellow_circle:'; info = ':white_circle:' }
  $counts = $Findings | Group-Object Level -AsHashTable -AsString
  $summary = foreach ($level in 'red', 'yellow', 'info') { "$level $(if ($counts -and $counts[$level]) { $counts[$level].Count } else { 0 })" }

  $lines = [System.Collections.Generic.List[string]]::new()
  $lines.Add("**Metadata check:** $($summary -join ', ')")
  $lines.Add('')
  foreach ($f in $Findings | Sort-Object { $order[$_.Level] }, File, Area) {
    $lines.Add("- $($mark[$f.Level]) ``$($f.File)`` $($f.Area): $($f.Text -replace '\r?\n', ' ')")
  }
  return $lines -join "`n"
}

<#
.SYNOPSIS
  Reports a usage error and ends the script with exit code 2.
#>
function Stop-Usage([string] $Message) {
  [Console]::Error.WriteLine($Message)
  exit 2
}

# --- main ---

$snapshot = [ordered]@{}
foreach ($file in $Path) {
  if (!(Test-Path -LiteralPath $file -PathType Leaf)) { Stop-Usage "File '$file' does not exist." }
  $name = Split-Path $file -Leaf
  if ($snapshot.Contains($name)) { Stop-Usage "Two files are named '$name'; snapshot keys must be unique." }
  $snapshot[$name] = Get-FileSnapshot (Resolve-Path -LiteralPath $file).ProviderPath
}

if ($SnapshotFile) {
  $snapshot | ConvertTo-Json -Depth 6 | Set-Content -LiteralPath $SnapshotFile -Encoding utf8NoBOM
  Write-Host "Snapshot written to $SnapshotFile"
}

if (!$Baseline) { exit 0 }
if (!(Test-Path -LiteralPath $Baseline)) { Stop-Usage "Baseline '$Baseline' does not exist." }

$approved = Get-Content -Raw -LiteralPath $Baseline | ConvertFrom-Json
$findings = @(Compare-Snapshot $approved $snapshot)
$report = Format-Report $findings

if ($ReportFile) { $report | Set-Content -LiteralPath $ReportFile -Encoding utf8NoBOM }
Write-Host $report

if ($findings | Where-Object Level -EQ 'red') { exit 1 }
exit 0

