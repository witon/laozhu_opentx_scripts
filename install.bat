@echo off
set scriptsdir=SCRIPTS
set laozhudir=LAOZHU
set widgetsdir=WIDGETS
set dirs=TELEMETRY emutest data
set files=CompileFiles.lua
del %scriptsdir%\*.luac /S
if exist %laozhudir% del %laozhudir%\*.luac /S
if exist %widgetsdir% del %widgetsdir%\*.luac /S
set disk=%1%
if "%disk%" == "" (
    echo input the disk to install, such as "f:"
    set /p disk=
)
if "%disk%" == "" (
    exit
)
@echo on
for %%d IN (%dirs%) do xcopy /I /Y /E %scriptsdir%\%%d %disk%\SCRIPTS\%%d
xcopy /I /Y /E test %disk%\SCRIPTS\test\
if exist %laozhudir% xcopy /I /Y /E %laozhudir% %disk%\LAOZHU\
if exist %widgetsdir% xcopy /I /Y /E %widgetsdir% %disk%\WIDGETS\
for %%f IN (%files%) do copy /Y %scriptsdir%\%%f %disk%\SCRIPTS\
mkdir %disk%\SCRIPTS\data 2>nul
echo not init > %disk%\SCRIPTS\lzinstall.flag 
