set dirs=TELEMETRY LAOZHU emutest test
for %%d IN (%dirs%) do xcopy /I /Y /E %%d %1\SCRIPTS\%%d
