
local function getCurAlt()
    return gCurAlt, 9
end

local function getFlightTime()
    return gFlightState.getFlightTime()/100, 0
end

local function getRssi()
    local rssi, alarm_low, alarm_crit = getRSSI()
    return rssi, 17
end

local function getLaunchAlt()
    return gFlightState.getLaunchAlt(), 9
end

return {getFlightTime, getCurAlt, getRssi, getLaunchAlt}

