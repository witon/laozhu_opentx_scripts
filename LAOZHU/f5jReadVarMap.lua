
local function readCurAlt()
    playNumber(gCurAlt, 9)
end

local function readFlightTime()
    playDuration(gFlightTime/100)
end

local function readRssi()
    local rssi, alarm_low, alarm_crit = getRSSI()
    playNumber(rssi, 17)
end

local function readLaunchAlt()
    playNumber(gLaunchALT, 9)
end

return {readFlightTime, readCurAlt, readRssi, readLaunchAlt}

