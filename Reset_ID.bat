@echo off

if exist "C:\Program Files\TeamViewer\TeamViewer.exe" (
    set "TVPath=C:\Program Files\TeamViewer"
) else if exist "C:\Program Files (x86)\TeamViewer\TeamViewer.exe" (
    set "TVPath=C:\Program Files (x86)\TeamViewer"
)

reg query "HKEY_LOCAL_MACHINE\SOFTWARE\TeamViewer" /v ClientID /reg:32 >nul 2>&1
if %errorlevel% equ 0 (
    set "REGPath=SOFTWARE\TeamViewer"
        set "REG=32"
) 

reg query "HKEY_LOCAL_MACHINE\SOFTWARE\TeamViewer" /v ClientID /reg:64 >nul 2>&1
if %errorlevel% equ 0 (
    set "REGPath=SOFTWARE\TeamViewer"
        set "REG=64"
) 

reg query "HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\TeamViewer" /v ClientID /reg:32 >nul 2>&1
if %errorlevel% equ 0 (
    set "REGPath=SOFTWARE\WOW6432Node\TeamViewer"
        set "REG=32"
) 

reg query "HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\TeamViewer" /v ClientID /reg:64 >nul 2>&1
if %errorlevel% equ 0 (
    set "REGPath=SOFTWARE\WOW6432Node\TeamViewer"
        set "REG=64"
) 

if exist "%TVPath%" powershell -Command "$key = [Microsoft.Win32.RegistryKey]::OpenBaseKey('LocalMachine', 'Registry%REG%').OpenSubKey('%REGPath%'); $value = $key.GetValue('ClientID'); $value | Out-File -FilePath '%TVPath%\Teamviewer_ID_Bak.txt'"

net stop TeamViewer
taskkill /IM "TeamViewer.exe" /F
taskkill /IM "TeamViewer_Service.exe" /F
taskkill /f /im tv*
taskkill /f /im Teamviewer*

SET currentPath=%~dp0
cd /d %currentPath:~0,-1%

wmic path win32_computersystemproduct GET UUID >> c:\windows\UUID_bak.txt

Powershell -executionpolicy remotesigned -File CreateReset_ID.ps1
mofcomp changeUUID.mof

reg delete HKEY_CURRENT_USER\SOFTWARE\TeamViewer /v SUID /f

reg delete HKLM\%REGPath% /v ClientID /f /reg:%REG%
reg delete HKLM\%REGPath% /v ClientIC /f /reg:%REG%
reg delete HKLM\%REGPath% /v ClientID_64 /f /reg:%REG%
reg delete HKLM\%REGPath% /v MIDInitiativeGUID /f /reg:%REG%
reg delete HKLM\%REGPath% /v MIDAttractionGUID /f /reg:%REG%
reg delete HKLM\%REGPath% /v LicenseType /f /reg:%REG%
reg delete HKLM\%REGPath% /v LastMACUsed /f /reg:%REG%

if exist "%TVPath%" powershell -Command "(Get-Item '%TVPath%').LastWriteTime = Get-Date"

sc config TeamViewer start= auto

net start TeamViewer

tasklist /FI "IMAGENAME eq TeamViewer.exe" 2>NUL | find /I /N "TeamViewer.exe" >NUL
if "%ERRORLEVEL%"=="0" (
    goto end
) else (
    start "" "%TVPath%\TeamViewer.exe"
)

:end

if exist "%TVPath%" powershell -Command "$key = [Microsoft.Win32.RegistryKey]::OpenBaseKey('LocalMachine', 'Registry%REG%').OpenSubKey('%REGPath%'); $value = $key.GetValue('ClientID'); $value | Out-File -FilePath '%TVPath%\Teamviewer_ID_New.txt'"

del %temp%\changeUUID.mof /s /q /f
del %temp%\CreateReset_ID.ps1 /s /q /f

DEL "%~f0" & EXIT
