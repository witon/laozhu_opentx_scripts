@echo off
set scriptdir=script
set dirs=TELEMETRY LAOZHU emutest test
set files=CompileFiles.lua
del %scriptdir%\*.luac /S
set disk=%1%
if "%disk%" == "" (
    echo input the disk to install, such as "f:"
    set /p disk=
)
if "%disk%" == "" (
    exit
)
@echo on
for %%d IN (%dirs%) do xcopy /I /Y /E %scriptdir%\%%d %disk%\SCRIPTS\%%d
for %%f IN (%files%) do copy /Y %scriptdir%\%%f %disk%\SCRIPTS\
rem mkdir %disk%\SCRIPTS\data
echo not init > %disk%\SCRIPTS\lzinstall.flag 
