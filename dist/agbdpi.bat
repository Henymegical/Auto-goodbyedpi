@echo off


:: VAR
set root_path="%~dp0%"
cd /d %root_path%
set /p bpath=< YourBrowserPath.txt
set /p cfg=< Config.txt
::for /D %%D in ("%bpath%") do set "lastfolder=%%~dpD"
set "browsers=msedge yandex opera chrome firefox brave vivaldi maxthon tor epic"
set "output_file=YourBrowserPath.txt"


:: LOCK
set "lockfile=%temp%\mybatchfile.lock"
if exist "%lockfile%" (
    start "" "stop.lnk"
    powershell -nop -c "& {sleep -m 2500}"
)
echo > "%lockfile%"


:: SHORTCUTS
echo Set objShell = CreateObject("WScript.Shell") > %TEMP%\CreateShortcut.vbs
echo Set objLink = objShell.CreateShortcut("%USERPROFILE%\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup\AGBDPI.lnk") >> %TEMP%\CreateShortcut.vbs
::echo objLink.Iconlocation = "%root_path:~1,-1%ICO.ico" >> %TEMP%\CreateShortcut.vbs
::echo objLink.Description = "Browser + GoodbyeDPI" >> %TEMP%\CreateShortcut.vbs
echo objLink.TargetPath = "%root_path:~1,-1%agbdpi.vbs" >> %TEMP%\CreateShortcut.vbs
echo objLink.Save >> %TEMP%\CreateShortcut.vbs
echo Set objLink = objShell.CreateShortcut("%root_path:~1,-1%stop.lnk") >> %TEMP%\CreateShortcut.vbs
echo objLink.TargetPath = "%root_path:~1,-1%STOP.vbs" >> %TEMP%\CreateShortcut.vbs
echo objLink.Save >> %TEMP%\CreateShortcut.vbs
cscript %TEMP%\CreateShortcut.vbs
del %TEMP%\CreateShortcut.vbs
attrib +h "%root_path:~1,-1%stop.lnk"


:: DPATH
:DPATH
if not defined bpath (
    if exist "STOP.txt" (
        taskkill /f /im:"goodbyedpi.exe"
        del "%lockfile%"
        exit /b
    )
    setlocal enabledelayedexpansion
    for %%a in (!browsers!) do (
        for /f "delims=" %%i in ('powershell -command "Get-Process | Where-Object { $_.ProcessName -eq '%%a' -and $_.MainWindowHandle -ne 0 }"') do (
            for /f "tokens=2 delims==" %%i in ('wmic process where "name='%%a.exe'" get executablepath /value ^| find "="') do (
                > "!output_file!" echo %%i
            )
        )
    )
    endlocal
    set /p bpath=< YourBrowserPath.txt
) else (
    for %%f in ("%bpath%") do set "exename=%%~nxf"
    set "flag=true"
    goto loop
)
goto DPATH


:: LOOPING
:LOOPING
powershell -nop -c "& {sleep -m %cfg%}"
:loop
if exist "STOP.txt" (
    taskkill /f /im:"goodbyedpi.exe"
    del "%lockfile%"
    exit /b
)
set "set_active=false"
for /f "delims=" %%i in ('powershell -command "Get-Process | Where-Object { $_.ProcessName -eq '%exename:~0,-4%' -and $_.MainWindowHandle -ne 0 }"') do (
    set "set_active=true"
)
if "%set_active%" == "false" (
    taskkill /f /im:"goodbyedpi.exe"
    set "flag=true"
    goto LOOPING
)
tasklist /NH /FI "IMAGENAME eq goodbyedpi.exe" 2>nul | find /I /N "goodbyedpi.exe">nul
if "%ERRORLEVEL%"=="1" (
    if "%set_active%" == "true" (
        if "%flag%" == "true" (
            setlocal enabledelayedexpansion
            cd ..
            cd gbdpi
            set _arch=x86
            IF "%PROCESSOR_ARCHITECTURE%"=="AMD64" (set _arch=x86_64)
            IF DEFINED PROCESSOR_ARCHITEW6432 (set _arch=x86_64)
            cd !_arch!
            start "" /min cmd /c "!cd!\goodbyedpi.exe" -9 --dns-addr 77.88.8.8 --dns-port 1253 --dnsv6-addr 2a02:6b8::feed:0ff --dnsv6-port 1253 --blacklist ..\russia-blacklist.txt --blacklist ..\russia-youtube.txt
            POPD
            endlocal
            set "flag=false"
        )
    )
) 
goto LOOPING
