@ECHO OFF
:: 3X-UI: starts the web panel in this window and waits for a key once it stops.
:: Copied into the app folder by the gesu Scoop bucket; the '3X-UI' shortcut in Scoop Apps opens it.
:: Start-3XUI.ps1 sets the data folders and copies Xray, mtg-multi and the geo files into bin first.
SETLOCAL
TITLE 3X-UI
ECHO 3X-UI: web panel for Xray-core. The panel runs while this window stays open;
ECHO Ctrl+C stops it.
ECHO.
ECHO Panel:  http://localhost:2053/ unless changed (3x-ui setting -show prints port and path).
ECHO Login:  on the very first start the log below prints a random user name and password,
ECHO         once. Lost them? Stop the panel, then: 3x-ui setting -username NAME -password PASS
ECHO Data:   %~dp0data
ECHO.
powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%~dp0Start-3XUI.ps1" run
ECHO.
ECHO 3X-UI has stopped.
PAUSE
