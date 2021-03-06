local this = {}
local f3kState = nil

local function readCurAlt()
    playNumber(f3kState.getCurAlt(), 9)
end

local function readFlightTime()
    playDuration(f3kState.getFlightTime())
end

local function readRssi()
    local rssi, alarm_low, alarm_crit = getRSSI()
    playNumber(rssi, 17)
end

local function readLaunchAlt()
    playNumber(f3kState.getLaunchAlt(), 9)
end

local function setF3kState(flightState)
    f3kState = flightState
end

this[1] = readFlightTime
this[2] = readCurAlt
this[3] = readRssi
this[4] = readLaunchAlt
this.setF3kState = setF3kState

return this

