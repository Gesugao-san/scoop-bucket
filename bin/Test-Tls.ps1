<#
.SYNOPSIS
  Checks the TLS connection to every host that the bucket's manifests and mirrors.psd1 use.

.DESCRIPTION
  Collects the URLs of each manifest (homepage, url, architecture URLs, checkver and autoupdate)
  and of its mirrors in mirrors.psd1, groups them by host, and for each host opens a TCP connection
  and a TLS handshake through the system's TLS stack (Schannel on Windows, as Scoop itself uses).
  No HTTP request is sent.

  Each host gets a status:
    FAIL  no connection, no handshake, an expired certificate or one Windows does not trust
    WARN  plain HTTP, TLS older than 1.2, or a certificate that expires within -WarnDays days
    OK    everything else

  The results are written to the pipeline. On GitHub Actions they also go to the job summary as a
  table and as annotations, so failures show up on the run page.

  Where the check runs matters: a GitHub runner is outside Russia, so a host that fails there is
  broken on its own side, while a host that only fails on a home PC is blocked or filtered on the
  way there.

.PARAMETER App
  Manifest names to check, wildcards allowed. Defaults to all manifests in bucket/.

.PARAMETER TimeoutSec
  Seconds to wait for the TCP connection and, separately, for the TLS handshake.

.PARAMETER WarnDays
  Warn when a certificate expires within this many days.

.PARAMETER FailOnError
  Exit with code 1 when any host has the status FAIL.

.EXAMPLE
  .\bin\Test-Tls.ps1
  Checks every host and prints a table.

.EXAMPLE
  .\bin\Test-Tls.ps1 -App TrueConf, Radmin-VPN | Format-List
  Checks only the hosts of these two apps and shows all the details.

.NOTES
  Revocation is not checked: CRL and OCSP servers are often unreachable from CI and would make
  the results flaky.
#>
[CmdletBinding()]
param (
  [Parameter(Position = 0)]
  [string[]] $App = '*',

  [ValidateRange(1, 300)]
  [int] $TimeoutSec = 15,

  [ValidateRange(0, 3650)]
  [int] $WarnDays = 21,

  [switch] $FailOnError
)

Set-StrictMode -Version 3
$ErrorActionPreference = 'Stop'

$bucketDir = Join-Path $PSScriptRoot '..\bucket'
$mirrorsFile = Join-Path $PSScriptRoot '..\mirrors.psd1'

# The probe is C# because the certificate validation callback may run on a thread without a
# PowerShell runspace, where a script block callback would crash the process.
# C# 5 syntax only: Windows PowerShell 5.1 compiles it with the .NET Framework compiler.
if (-not ('GesuTlsProbe' -as [type])) {
  # -IgnoreWarnings: Add-Type treats compiler warnings as errors, and newer .NET versions may mark APIs obsolete.
  Add-Type -IgnoreWarnings -TypeDefinition @'
using System;
using System.Collections.Generic;
using System.Net.Security;
using System.Net.Sockets;
using System.Security.Authentication;
using System.Security.Cryptography.X509Certificates;

/// <summary>Result of one TLS probe.</summary>
public class GesuTlsProbeResult {
  public bool Handshake;
  public string Protocol = "";
  public string Subject = "";
  public string Issuer = "";
  public DateTime NotAfter = DateTime.MinValue;
  public string PolicyErrors = "";
  public string ChainStatus = "";
  public string Error = "";
}

/// <summary>Opens a TCP connection and a TLS handshake and reports what happened.</summary>
public static class GesuTlsProbe {
  /// <summary>Probes host:port; never throws, errors go to Result.Error.</summary>
  public static GesuTlsProbeResult Probe(string host, int port, int timeoutMs) {
    var result = new GesuTlsProbeResult();
    using (var tcp = new TcpClient()) {
      try {
        if (!tcp.ConnectAsync(host, port).Wait(timeoutMs)) {
          result.Error = "TCP: no connection within " + timeoutMs / 1000 + " s";
          return result;
        }
      } catch (Exception e) {
        result.Error = "TCP: " + Innermost(e);
        return result;
      }

      // Accept every certificate so that an untrusted one is still read and reported.
      RemoteCertificateValidationCallback accept = (sender, certificate, chain, errors) => {
        result.PolicyErrors = errors.ToString();
        result.ChainStatus = DescribeChain(chain);
        return true;
      };

      using (var ssl = new SslStream(tcp.GetStream(), false, accept)) {
        ssl.ReadTimeout = timeoutMs;
        ssl.WriteTimeout = timeoutMs;
        try {
          // SslProtocols.None lets the OS pick the protocols, as Scoop's downloads do.
          if (!ssl.AuthenticateAsClientAsync(host, null, SslProtocols.None, false).Wait(timeoutMs)) {
            result.Error = "TLS: no handshake within " + timeoutMs / 1000 + " s";
            return result;
          }
        } catch (Exception e) {
          result.Error = "TLS: " + Innermost(e);
          return result;
        }

        result.Handshake = true;
        result.Protocol = ssl.SslProtocol.ToString();
        if (ssl.RemoteCertificate == null) return result;

        var certificate = ssl.RemoteCertificate as X509Certificate2 ?? new X509Certificate2(ssl.RemoteCertificate);
        result.Subject = certificate.GetNameInfo(X509NameType.SimpleName, false);
        result.Issuer = certificate.GetNameInfo(X509NameType.SimpleName, true);
        result.NotAfter = certificate.NotAfter.ToUniversalTime();
      }
    }
    return result;
  }

  /// <summary>Lists the chain's problems, or returns "" when there are none.</summary>
  static string DescribeChain(X509Chain chain) {
    if (chain == null) return "";
    var problems = new List<string>();
    foreach (var status in chain.ChainStatus) problems.Add(status.Status.ToString());
    return string.Join(", ", problems);
  }

  /// <summary>Returns the innermost exception's type and message.</summary>
  static string Innermost(Exception e) {
    while (e.InnerException != null) e = e.InnerException;
    return e.GetType().Name + ": " + e.Message;
  }
}
'@
}

<#
.SYNOPSIS
  Returns the URLs of one manifest as objects with Field and Url.
#>
function Get-ManifestUrl {
  param (
    [Parameter(Mandatory = $true)] $Manifest
  )

  if ($Manifest.PSObject.Properties['homepage']) {
    [pscustomobject]@{ Field = 'homepage'; Url = $Manifest.homepage }
  }
  Get-DownloadUrl $Manifest 'url'
  Get-CheckverUrl $Manifest
  if ($Manifest.PSObject.Properties['autoupdate']) {
    Get-DownloadUrl $Manifest.autoupdate 'autoupdate'
  }
}

<#
.SYNOPSIS
  Returns the 'url' of a manifest (or of its autoupdate block) and of each architecture.
#>
function Get-DownloadUrl {
  param (
    [Parameter(Mandatory = $true)] $Node,
    [Parameter(Mandatory = $true)] [string] $Field
  )

  if ($Node.PSObject.Properties['url']) {
    foreach ($url in @($Node.url)) { [pscustomobject]@{ Field = $Field; Url = $url } }
  }
  if (-not $Node.PSObject.Properties['architecture']) { return }

  foreach ($arch in $Node.architecture.PSObject.Properties) {
    if (-not $arch.Value.PSObject.Properties['url']) { continue }
    foreach ($url in @($arch.Value.url)) {
      [pscustomobject]@{ Field = "$Field ($($arch.Name))"; Url = $url }
    }
  }
}

# Scoop's checkver shorthands and the host each one queries (see Scoop's bin/checkver.ps1).
$checkverHosts = [ordered]@{
  github      = 'https://api.github.com/'
  sourceforge = 'https://sourceforge.net/'
}

<#
.SYNOPSIS
  Returns the URL that checkver queries, unless it is the homepage, which is already listed.
#>
function Get-CheckverUrl {
  param (
    [Parameter(Mandatory = $true)] $Manifest
  )

  if (-not $Manifest.PSObject.Properties['checkver']) { return }
  $checkver = $Manifest.checkver

  # A string is either 'github' or a regex applied to the homepage.
  if ($checkver -is [string]) {
    if ($checkver -eq 'github') { [pscustomobject]@{ Field = 'checkver'; Url = $checkverHosts.github } }
    return
  }

  if ($checkver.PSObject.Properties['url']) {
    [pscustomobject]@{ Field = 'checkver'; Url = $checkver.url }
    return
  }
  foreach ($shorthand in $checkverHosts.Keys) {
    if ($checkver.PSObject.Properties[$shorthand]) {
      [pscustomobject]@{ Field = 'checkver'; Url = $checkverHosts[$shorthand] }
    }
  }
}

<#
.SYNOPSIS
  Returns the URLs of an app's mirrors in mirrors.psd1.
#>
function Get-MirrorUrl {
  param (
    [Parameter(Mandatory = $true)] [string] $Name,
    $Mirrors
  )

  if ($null -eq $Mirrors) { return }
  # Hashtable keys from a .psd1 match case-insensitively, as app names do in Scoop.
  if (-not $Mirrors.ContainsKey($Name)) { return }

  foreach ($mirror in $Mirrors[$Name]) {
    foreach ($key in '64bit', '32bit', 'arm64', 'url') {
      if (-not $mirror.ContainsKey($key)) { continue }
      foreach ($url in @($mirror[$key])) {
        [pscustomobject]@{ Field = "mirror $($mirror.name)"; Url = $url }
      }
    }
  }
}

<#
.SYNOPSIS
  Turns a manifest URL into a Uri, or returns nothing if it has no usable host.
#>
function ConvertTo-Endpoint {
  param (
    [Parameter(Mandatory = $true)] [string] $Url
  )

  # Scoop's '#/name.ext' suffix only renames the downloaded file.
  $clean = ($Url -split '#', 2)[0]
  $uri = $null
  if (-not [Uri]::TryCreate($clean, [UriKind]::Absolute, [ref] $uri)) { return }
  if ($uri.Scheme -notin 'http', 'https') { return }
  # Autoupdate URLs may hold variables such as $version; a variable in the host cannot be checked.
  if ($uri.Host -match '\$') { return }
  $uri
}

<#
.SYNOPSIS
  Groups all URLs of the selected manifests by scheme, host and port.
#>
function Get-Endpoint {
  $mirrors = if (Test-Path $mirrorsFile) { Import-PowerShellDataFile $mirrorsFile } else { $null }
  $endpoints = @{}

  $files = Get-ChildItem $bucketDir -Filter '*.json' |
    Where-Object { $name = $_.BaseName; @($App | Where-Object { $name -like $_ }).Count -gt 0 }

  foreach ($file in $files) {
    $manifest = Get-Content $file.FullName -Raw | ConvertFrom-Json
    $urls = @(Get-ManifestUrl $manifest) + @(Get-MirrorUrl $file.BaseName $mirrors)

    foreach ($entry in $urls) {
      $uri = ConvertTo-Endpoint ([string] $entry.Url)
      if ($null -eq $uri) { continue }

      $key = '{0}://{1}:{2}' -f $uri.Scheme, $uri.Host, $uri.Port
      if (-not $endpoints.ContainsKey($key)) {
        $endpoints[$key] = [pscustomobject]@{
          Scheme = $uri.Scheme
          Host   = $uri.Host
          Port   = $uri.Port
          Uses   = [System.Collections.Generic.SortedSet[string]]::new()
        }
      }
      [void] $endpoints[$key].Uses.Add("$($file.BaseName) ($($entry.Field))")
    }
  }
  $endpoints.Values | Sort-Object Host, Port
}

# Rules that turn a probe result into findings, checked in order; the worst status wins.
# Each test gets the probe result as $_ and the time left until the certificate expires as $daysLeft.
$rules = @(
  @{ Status = 'FAIL'; Test = { -not $_.Handshake }; Note = { $_.Error } }
  @{ Status = 'FAIL'; Test = { $_.Handshake -and $daysLeft -lt 0 }; Note = { 'certificate expired' } }
  @{
    Status = 'FAIL'
    Test   = { $_.Handshake -and $_.PolicyErrors -ne 'None' }
    Note   = { "not trusted: $($_.PolicyErrors) $($_.ChainStatus)".Trim() }
  }
  @{ Status = 'WARN'; Test = { $_.Protocol -in 'Ssl2', 'Ssl3', 'Tls', 'Tls11' }; Note = { "old protocol $($_.Protocol)" } }
  @{
    Status = 'WARN'
    Test   = { $_.Handshake -and $daysLeft -ge 0 -and $daysLeft -lt $WarnDays }
    Note   = { "certificate expires in $daysLeft days" }
  }
)

$severity = @{ OK = 0; WARN = 1; FAIL = 2 }

<#
.SYNOPSIS
  Probes one endpoint and returns its row for the report.
#>
function Test-Endpoint {
  param (
    [Parameter(Mandatory = $true)] $Endpoint
  )

  $row = [ordered]@{
    Status  = 'OK'
    Host    = $Endpoint.Host
    Port    = $Endpoint.Port
    TLS     = ''
    Issuer  = ''
    Expires = ''
    Note    = ''
    Apps    = @($Endpoint.Uses) -join '; '
  }

  # Plain HTTP has no TLS to check; a download over it is only protected by the manifest's hash.
  if ($Endpoint.Scheme -eq 'http') {
    $row.Status = 'WARN'
    $row.Note = 'plain HTTP'
    return [pscustomobject] $row
  }

  $probe = [GesuTlsProbe]::Probe($Endpoint.Host, $Endpoint.Port, $TimeoutSec * 1000)
  $daysLeft = [int] [Math]::Floor(($probe.NotAfter - [DateTime]::UtcNow).TotalDays)

  $row.TLS = $probe.Protocol
  $row.Issuer = $probe.Issuer
  if ($probe.Handshake) { $row.Expires = '{0:yyyy-MM-dd} ({1} d)' -f $probe.NotAfter, $daysLeft }

  $notes = foreach ($rule in $rules) {
    $hit = $probe | ForEach-Object $rule.Test
    if (-not $hit) { continue }
    if ($severity[$rule.Status] -gt $severity[$row.Status]) { $row.Status = $rule.Status }
    $probe | ForEach-Object $rule.Note
  }
  $row.Note = @($notes) -join '; '
  [pscustomobject] $row
}

<#
.SYNOPSIS
  Escapes text for a GitHub Actions workflow command (annotation).
#>
function ConvertTo-AnnotationText {
  param (
    [string] $Text,
    [switch] $Property
  )

  $escaped = $Text -replace '%', '%25' -replace "`r", '%0D' -replace "`n", '%0A'
  if (-not $Property) { return $escaped }
  $escaped -replace ':', '%3A' -replace ',', '%2C'
}

<#
.SYNOPSIS
  Writes the results to the GitHub Actions job summary and as annotations.
#>
function Write-GitHubReport {
  param (
    [Parameter(Mandatory = $true)] [object[]] $Results
  )

  if (-not $env:GITHUB_ACTIONS) { return }

  $annotationLevel = @{ FAIL = 'error'; WARN = 'warning' }
  foreach ($result in $Results) {
    if (-not $annotationLevel.ContainsKey($result.Status)) { continue }
    $title = ConvertTo-AnnotationText "TLS: $($result.Host)" -Property
    $message = ConvertTo-AnnotationText "$($result.Note). Used by: $($result.Apps)"
    Write-Host "::$($annotationLevel[$result.Status]) title=$title::$message"
  }

  if (-not $env:GITHUB_STEP_SUMMARY) { return }

  $cell = { param($text) ([string] $text) -replace '\|', '\|' }
  $lines = @(
    '## TLS check'
    ''
    "Checked from a GitHub-hosted runner ($env:RUNNER_OS), outside Russia: a host that fails here is broken on its own side;"
    'a host that fails only on your PC is blocked or filtered on the way. Revocation is not checked.'
    ''
    '| Status | Host | TLS | Issuer | Expires | Note | Used by |'
    '|---|---|---|---|---|---|---|'
  )
  foreach ($result in $Results) {
    $hostPort = if ($result.Port -in 80, 443) { $result.Host } else { "$($result.Host):$($result.Port)" }
    $lines += '| {0} | `{1}` | {2} | {3} | {4} | {5} | {6} |' -f $result.Status, $hostPort,
      $result.TLS, (& $cell $result.Issuer), $result.Expires, (& $cell $result.Note), (& $cell $result.Apps)
  }
  $lines | Out-File $env:GITHUB_STEP_SUMMARY -Append -Encoding utf8
}

$endpoints = @(Get-Endpoint)
if ($endpoints.Count -eq 0) {
  Write-Warning "No URLs found for: $($App -join ', ')"
  return
}

$results = @(
  @(
    foreach ($endpoint in $endpoints) {
      Write-Verbose "Checking $($endpoint.Scheme)://$($endpoint.Host):$($endpoint.Port)"
      Test-Endpoint $endpoint
    }
  ) | Sort-Object @{ Expression = { $severity[$_.Status] }; Descending = $true }, Host
)

Write-GitHubReport $results
$results

$failed = @($results | Where-Object Status -EQ 'FAIL').Count
if ($FailOnError -and $failed -gt 0) {
  Write-Host "$failed host(s) failed the TLS check."
  exit 1
}
