
local function getCurAlt()
    return gCurAlt, 9
end

local function getFlightTime()
    return gFlightTime/100, 0
end

local function getRssi()
    local rssi, alarm_low, alarm_crit = getRSSI()
    return rssi, 17
end

local function getLaunchAlt()
    return gLaunchALT, 9
end

return {getFlightTime, getCurAlt, getRssi, getLaunchAlt}

