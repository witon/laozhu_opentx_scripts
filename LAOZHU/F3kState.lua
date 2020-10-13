
local flightState = 0 --0:preset 1:zoom 2:launched 3:landed
local launchTime = 0
local launchAlt = 0
local curAlt = 0
local flightTime = 0
local launchDatetime = 0
local flightStateStartTime = 0

local function setAlt(alt)
    curAlt = alt
end

local function getLaunchAlt()
    return launchAlt
end

local function getCurFlightStateName()
    if flightState == 0 then
        return "Preset"
    elseif flightState == 1 then
        return "Zoom"
    elseif flightState == 2 then
        return "Flight"
    else
        return "Landed"
    end
end

local function getFlightState()
    return flightState
end

local function getFlightTime()
    return flightTime
end

local function newFlight(curTime)
    flightState = 0
    flightTime = 0
    launchAlt = 0
    launchTime = 0
    launchDatetime = getDateTime()
    launchTime = curTime
end

local function getMaxLaunchAlt()
    if curAlt > launchAlt then
        launchAlt = curAlt
    end
end

local function doStateZoom(curTime, flightModeName)
    if flightModeName == "preset" then
        flightState = 0
    elseif flightModeName == "zoom" then
    else
        flightState = 2
        flightStateStartTime = curTime
    end
    flightTime = curTime - launchTime
    getMaxLaunchAlt()
end

local function doStateLaunched(curTime, flightModeName)
    if flightModeName == "preset" then
        flightState = 3
    end
    flightTime = curTime - launchTime
    if curTime - flightStateStartTime < 150 then --still update launch alt in 1.5's after zoom
        getMaxLaunchAlt()
    end
end

local function doStateLanded(curTime, flightModeName)
    if flightModeName == "zoom" then
        flightState = 0
        newFlight(curTime)
    end
end

local function getLaunchDateTime()
    return launchDatetime
end

local function getLaunchTime()
    return launchTime
end

local function doStatePreset(curTime, flightModeName)
    if flightModeName == "zoom" then
        newFlight(curTime)
        flightState = 1
    end

end

local function doFlightState(curTime, flightModeName)
    if flightState == 0 then
        doStatePreset(curTime, flightModeName)
    elseif flightState == 1 then
        doStateZoom(curTime, flightModeName)
    elseif flightState == 2 then
        doStateLaunched(curTime, flightModeName)
    elseif flightState == 3 then
        doStateLanded(curTime, flightModeName)
    end
end


return {newFlight = newFlight,
    doFlightState = doFlightState,
    getFlightState = getFlightState,
    getLaunchDateTime = getLaunchDateTime,
    getLaunchTime = getLaunchTime,
    getFlightTime = getFlightTime,
    getCurFlightStateName = getCurFlightStateName,
    setAlt = setAlt,
    getLaunchAlt = getLaunchAlt
}