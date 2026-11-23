@ECHO OFF
:: zapret-discord-youtube: opens Flowseal's service manager (service.bat) with administrator rights.
:: Copied into the app folder by the gesu Scoop bucket; the 'zapret-discord-youtube' shortcut in
:: Scoop Apps opens it. ZapretDiscordYoutube.ps1 copies winws.exe, cygwin1.dll and WinDivert from
:: their gesu packages into bin first, then starts service.bat in an administrator window.
SETLOCAL
TITLE zapret-discord-youtube
ECHO zapret-discord-youtube (Flowseal): DPI bypass strategies for Discord, YouTube and more,
ECHO run by winws.exe from bol-van/zapret through the WinDivert driver.
ECHO.
ECHO Service manager: Install Service (pick a strategy), Remove Services, Check Status,
ECHO Game Filter, IPSet Filter, Run Diagnostics, Run Tests (finds a working strategy).
ECHO.
ECHO Folder: %~dp0
ECHO Command line: zapret-discord-youtube status ^| stop ^| start ^| update ^| sync ^| bundled on/off ^| folder
ECHO Before 'scoop update', stop the bypass, or run: zapret-discord-youtube update
ECHO.
powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%~dp0ZapretDiscordYoutube.ps1" menu
ECHO.
PAUSE
