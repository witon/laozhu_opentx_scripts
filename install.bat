set dirs=TELEMETRY LAOZHU emutest test
del *.luac /S
for %%d IN (%dirs%) do xcopy /I /Y /E %%d %1\SCRIPTS\%%d
echo not init > %1\SCRIPTS\lzinstall.flag 
