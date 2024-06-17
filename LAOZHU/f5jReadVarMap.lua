local this = {}
local f5jState = nil

local function readCurAlt()
    playNumber(f5jState.getAlt(), 9)
end

local function readFlightTime()
    playDuration(f5jState.getFlightTime()/100)
end

local function readRssi()
    local rssi, alarm_low, alarm_crit = getRSSI()
    playNumber(rssi, 17)
end

local function readLaunchAlt()
    playNumber(f5jState.getLaunchAlt(), 9)
end

local function setF5jState(flightState)
    f5jState = flightState
end

this[1] = readCurAlt
this[2] = readCurAlt
this[3] = readRssi
this[4] = readRssi 
this.setF5jState = setF5jState
return this

