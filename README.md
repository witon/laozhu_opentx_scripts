Introduction:
======
Laozhu opentx scripts are some scripts for RC thermal glider training.
3ktel.lua is the telemetry script and 3kmix.lua is the mixes script. They work togethor for f3k.
5jtel.lua is the telemetry script and 5jmix.lua is the mixes script. They work togethor for f5j.
utils.lua provides common functions for those scipts.

Compatibility:
======
These scripts passed the tests on the FRSKY XLite Pro with OpenTX 2.3.

Install:
======
Copy the three directories "LAOZHU", "MIXES", "TELEMETRY" to the scripts directory on the SD card.


For f3k:
======
Setup:
------
In the "CUSTOM SCRIPTS" menu, setup a LUA script. Select "3kmix" in the "script" item, input a name in the "Name" item such as "f3km". In the "Inputs" item, "WTSwitch" is the switch to reset or turn on the work time timer, "VarSelect" is the slider to select the variable to be read, "ReadSwitch" is the switch to read the variable which you have selected when you turn on then turn off it once.
In the "DISPLAY" menu, setup a screen with the type of "Script", and select the "3ktel" script.

Usage:
------
Turn to the telemetry view, you can switch pages by the left and right keys. The first page shows a lot of information for f3k flight such as "work time", "RSSI", "flight time", "current altitude", "launch altitude" etc. The second page is the flight list with large font and the third is the flight list with small font.
Reset or turn on the work time timer by the switch you had set before.
There are four variables can be read by the transmitter: "flight time", "current altitude", "RSSI" and "launch altitude".  Slide the "VarSelect" slider to select the variable, Turn on then turn off the "ReadSwitch" to read it.
