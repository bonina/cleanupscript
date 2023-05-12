@echo off
echo ==========================
echo  Cleanup script v1.71
echo  for Windows(R) 7/8/10/11
::    @https://github.com/bonina/cleanupscript
echo ==========================
echo.

openfiles.exe >nul 2>&1
if %errorlevel% neq 0 (
echo ERROR please execute with admin privileges
goto :error
)

color 0A
if not "%safeboot_option%"=="" (
echo Safe mode detected & echo.
)

echo (new ActiveXObject("WScript.Shell")).AppActivate("Disk Cleanup"); > %temp%\focus.js

echo Cleanup setup - please select cleaning categories & cleanmgr.exe /sageset:1 && (echo Cleanup setup OK) || (echo Cleanup setup ERROR & goto :error)
echo. & echo Cleanup in progress...

start /b cmd /c "cleanmgr.exe /sagerun:1"

if %errorlevel% neq 0 (
echo Cleanup ERROR
goto :error
)

:repeat
timeout /t 1 >nul 2>&1
cscript //nologo %temp%\focus.js >nul 2>&1
tasklist | findstr "cleanmgr.exe" >nul 2>&1 && goto :repeat

echo Cleanup OK
del %temp%\focus.js >nul 2>&1 || (echo Cleanup ERROR - del temp ERROR & goto :error)

ver | find " 6." >nul 2>&1
if %errorlevel% equ 0 goto old

echo. & echo WinSxS folder cleanup in progress...
Dism.exe /online /Cleanup-Image /StartComponentCleanup /ResetBase >nul 2>&1 && (echo WinSxS folder cleanup OK) || (echo WinSxS folder cleanup ERROR & goto :error)

:old
echo. & echo Windows update cache cleanup in progress...
sc query wuauserv | find "STATE" | find "RUNNING" >nul 2>&1
if %errorlevel% equ 0 (
net stop wuauserv >nul 2>&1 || (echo Windows update cache cleanup - service stop ERROR & goto :error)
if exist %systemroot%\SoftwareDistribution\Download rd /s /q %systemroot%\SoftwareDistribution\Download && (net start wuauserv >nul 2>&1 & echo Windows update cache cleanup OK & goto :success) || (echo Windows update cache cleanup ERROR & goto :error)
) else (
if exist %systemroot%\SoftwareDistribution\Download rd /s /q %systemroot%\SoftwareDistribution\Download && (echo Windows update cache cleanup OK & goto :success) || (echo Windows update cache cleanup ERROR & goto :error)
)

:success
echo.
echo ================================
echo  Cleanup completed successfully 
echo ================================
:continue
echo.
echo PRESS ANY KEY TO CLOSE WINDOW
pause >nul
goto: eof

:error
color 0C
goto :continue
