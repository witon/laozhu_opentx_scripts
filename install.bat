@echo off
set dirs=TELEMETRY LAOZHU data emutest test
set files=CompileFiles.lua
del *.luac /S
set disk=%1%
if "%disk%" == "" (
    echo input the disk to install, such as "f:"
    set /p disk=
)
if "%disk%" == "" (
    exit
)
@echo on
for %%d IN (%dirs%) do xcopy /I /Y /E %%d %disk%\SCRIPTS\%%d
for %%f IN (%files%) do copy /Y %%f %disk%\SCRIPTS\
rem mkdir %disk%\SCRIPTS\data
echo not init > %disk%\SCRIPTS\lzinstall.flag 
