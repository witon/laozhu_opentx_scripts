@echo off
set dirs=TELEMETRY LAOZHU data emutest test
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
rem mkdir %disk%\SCRIPTS\data
echo not init > %disk%\SCRIPTS\lzinstall.flag 
