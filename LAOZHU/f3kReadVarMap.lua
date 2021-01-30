
local function readCurAlt()
    playNumber(gCurAlt, 9)
end

local function readFlightTime()
    playDuration(gFlightState.getFlightTime())
end

local function readRssi()
    local rssi, alarm_low, alarm_crit = getRSSI()
    playNumber(rssi, 17)
end

local function readLaunchAlt()
    playNumber(gFlightState.getLaunchAlt(), 9)
end

return {readFlightTime, readCurAlt, readRssi, readLaunchAlt}

