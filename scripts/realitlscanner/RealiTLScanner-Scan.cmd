@ECHO OFF
:: RealiTLScanner-Scan: scans one IPv4 range with RealiTLScanner once and saves the results as
:: results\<date>_<time>_<range>.csv. Scoop keeps that folder across updates (persist), in
:: %USERPROFILE%\scoop\persist\RealiTLScanner\results.
::
:: Usage:
::   RealiTLScanner-Scan.cmd                  asks for the range; Enter takes the last one,
::                                            or the /24 around your public IPv4 address
::   RealiTLScanner-Scan.cmd 203.0.113.0/24   scans this range
::   RealiTLScanner-Scan.cmd 203.0.113.10     scans 203.0.113.0/24, the /24 around this address
::
:: A single IP or a domain would start the scanner's infinite mode, which walks on until Ctrl+C.
:: This script always passes a range, so every run ends by itself: a bare IPv4 address is widened
:: to its /24, and domains are refused (run realitlscanner directly for those).
::
:: Runs the scanner through RealiTLScanner.ps1, so GEO_CODE comes from gesu/Loyalsoldier-GeoIP.
:: Copied into the app folder by the gesu Scoop bucket (scripts/realitlscanner).

SETLOCAL EnableExtensions

:: Settings. -v also logs failed and unsuitable targets; set VERBOSE= for a quieter run.
SET "THREADS=10"
SET "TIMEOUT=10"
SET "PORT=443"
SET "VERBOSE=-v"

SET "APPDIR=%~dp0"
SET "RESULTS=%APPDIR%results"
SET "LASTFILE=%RESULTS%\last-target.txt"
SET "WRAPPER=%APPDIR%RealiTLScanner.ps1"
SET "PS=powershell.exe -NoProfile -ExecutionPolicy Bypass"

IF NOT EXIST "%WRAPPER%" (
  ECHO RealiTLScanner.ps1 is missing next to this script. Reinstall: scoop install gesu/RealiTLScanner
  GOTO :finish
)
IF NOT EXIST "%RESULTS%\" MD "%RESULTS%"

SET "TARGET=%~1"
IF NOT DEFINED TARGET CALL :ask_target
IF NOT DEFINED TARGET (
  ECHO No range given, nothing to scan.
  GOTO :finish
)

CALL :to_range
IF NOT DEFINED RANGE (
  ECHO "%TARGET%" is not an IPv4 address or range. Give e.g. 203.0.113.0/24 or 203.0.113.10.
  ECHO For a domain or the infinite mode, run realitlscanner directly.
  GOTO :finish
)
>"%LASTFILE%" ECHO %RANGE%

:: Locale-independent and sortable, unlike DATE /T and TIME /T.
FOR /F "usebackq delims=" %%T IN (`%PS% -Command "Get-Date -Format yyyy-MM-dd_HH-mm-ss"`) DO SET "STAMP=%%T"
SET "OUT=%RESULTS%\%STAMP%_%RANGE:/=-%.csv"

ECHO Scanning %RANGE% once: port %PORT%, %THREADS% threads, %TIMEOUT% s timeout.
ECHO Press Ctrl+C to stop early.
ECHO.
%PS% -File "%WRAPPER%" -addr %RANGE% -port %PORT% -thread %THREADS% -timeout %TIMEOUT% %VERBOSE% -out "%OUT%"
ECHO.

IF NOT EXIST "%OUT%" (
  ECHO The scanner wrote no results file; see its messages above.
  GOTO :finish
)
:: The first line of the CSV is the header.
FOR /F %%N IN ('TYPE "%OUT%" ^| FIND /C /V ""') DO SET /A "FOUND=%%N-1"
ECHO Suitable servers found: %FOUND%
ECHO Results: %OUT%

:finish
IF "%~1"=="" PAUSE
ENDLOCAL
GOTO :EOF

:: Asks for the target. Offers the last range scanned, or else the /24 around the public IPv4.
:ask_target
SET "DEFAULT="
IF EXIST "%LASTFILE%" SET /P DEFAULT=<"%LASTFILE%"
IF NOT DEFINED DEFAULT CALL :public_range
ECHO Enter an IPv4 range like 203.0.113.0/24, or an address like 203.0.113.10 (scanned as its /24).
IF DEFINED DEFAULT ECHO Press Enter for %DEFAULT%
SET /P "TARGET=Range: "
IF NOT DEFINED TARGET SET "TARGET=%DEFAULT%"
GOTO :EOF

:: Sets DEFAULT to the /24 around the public IPv4 address, as Cloudflare (or ipify) sees it.
:: The PowerShell command avoids ^, | and %, which cmd would treat specially.
:: Behind a VPN or a proxy on the router that is the exit's address, not your provider's.
:public_range
SET "PUBLICIP="
FOR /F "usebackq delims=" %%I IN (`%PS% -Command "[Net.ServicePointManager]::SecurityProtocol = 'Tls12'; foreach ($u in 'https://1.1.1.1/cdn-cgi/trace', 'https://api.ipify.org') { try { $r = ([string] (Invoke-RestMethod $u -TimeoutSec 5)).Trim(); if ($r -match 'ip=(\d{1,3}(?:\.\d{1,3}){3})') { $Matches[1]; break }; if ($r -match '\A\d{1,3}(?:\.\d{1,3}){3}\z') { $r; break } } catch {} }"`) DO SET "PUBLICIP=%%I"
IF NOT DEFINED PUBLICIP GOTO :EOF
SET "TARGET=%PUBLICIP%"
CALL :to_range
SET "TARGET="
SET "DEFAULT=%RANGE%"
ECHO Your public IPv4 address: %PUBLICIP%
GOTO :EOF

:: Sets RANGE from TARGET: a range with / is kept, a bare IPv4 address becomes its /24,
:: anything else leaves RANGE empty.
:to_range
SET "RANGE="
IF NOT "%TARGET:/=%"=="%TARGET%" (
  SET "RANGE=%TARGET%"
  GOTO :EOF
)
ECHO %TARGET%| FINDSTR /R /X "[0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*" >NUL || GOTO :EOF
FOR /F "tokens=1-3 delims=." %%a IN ("%TARGET%") DO SET "RANGE=%%a.%%b.%%c.0/24"
GOTO :EOF
