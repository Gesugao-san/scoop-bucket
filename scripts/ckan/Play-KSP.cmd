@ECHO OFF
:: Play-KSP.cmd - launches Kerbal Space Program through Steam and waits for it to exit.
::
:: Why: Steam counts play time only when it starts the game itself,
:: CKAN counts play time only while the process it started is alive.
:: This wrapper satisfies both: Steam starts the game, CKAN tracks this script,
:: and the script lives exactly as long as KSP_x64.exe does.
::
:: Shipped with gesu/CKAN and gesu/CKAN-NetFx, which add it to the PATH as a shim.
:: Use: in CKAN, Play -> Edit command lines..., add the line: Play-KSP.cmd
:: (CKAN cannot take a path with spaces there: it splits the command line on spaces.)

SETLOCAL

SET "APP_ID=220200"
SET "GAME_EXE=KSP_x64.exe"
:: How long to wait for the game to appear: 150 checks x 2 s = 5 minutes
:: (enough for Steam start-up and the Private Division launcher, if it shows up).
SET "START_CHECKS=150"

:: Steam stores its own path in the registry; fall back to the default location.
SET "STEAM_EXE="
FOR /F "tokens=2,*" %%A IN ('REG QUERY "HKCU\Software\Valve\Steam" /v SteamExe 2^>NUL') DO SET "STEAM_EXE=%%B"
IF NOT DEFINED STEAM_EXE SET "STEAM_EXE=%ProgramFiles(x86)%\Steam\steam.exe"

START "" "%STEAM_EXE%" -applaunch %APP_ID%

SET /A CHECKS=0

:WAIT_FOR_START
TIMEOUT /T 2 /NOBREAK >NUL
TASKLIST /NH /FI "IMAGENAME EQ %GAME_EXE%" | FIND /I "%GAME_EXE%" >NUL && GOTO WAIT_FOR_EXIT
SET /A CHECKS+=1
IF %CHECKS% LSS %START_CHECKS% GOTO WAIT_FOR_START
ECHO %GAME_EXE% did not start in time, giving up.
EXIT /B 1

:WAIT_FOR_EXIT
TIMEOUT /T 5 /NOBREAK >NUL
TASKLIST /NH /FI "IMAGENAME EQ %GAME_EXE%" | FIND /I "%GAME_EXE%" >NUL && GOTO WAIT_FOR_EXIT
EXIT /B 0
