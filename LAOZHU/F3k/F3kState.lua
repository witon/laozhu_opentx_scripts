
LZ_runModule(gScriptDir .. "LAOZHU/F3k/F3kFlightRecord.lua")

local flightState = 0 --0:preset 1:zoom 2:launched 3:landed
local launchTime = 0
local launchAlt = 0
local curAlt = 0
local launchRtcTime = 0
local flightStateStartTime = 0
local f3kFlightRecord = F3KFRnewFlightRecord()
f3kFlightRecord.maxNum = 25
local destFlightTime = 0
local flightTimer = Timer:new()
local landedCallback = nil



local function setLandedCallback(callback)
    landedCallback = callback
end

local function getFlightRecord()
    return f3kFlightRecord
end

local function setAlt(alt)
    curAlt = alt
end

local function getCurAlt()
    return curAlt
end

local function setDestFlightTime(time)
    destFlightTime = time
    flightTimer:setDuration(time)
end

local function getDestFlightTime()
    return destFlightTime
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
    return flightTimer:getRunTime()
end

local function newFlight(curTime, curRtcTime)
    flightState = 0
    flightTimer:resetTimer(destFlightTime)
    flightTimer:setDowncount(15)
    flightTimer:start()
    launchAlt = 0
    launchTime = 0
    launchRtcTime = curRtcTime
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
    getMaxLaunchAlt()
end

local function doStateLaunched(curTime, flightModeName)
    if flightModeName == "preset" then
        flightTimer:stop()
        flightState = 3
        F3KFRaddFlight(f3kFlightRecord, flightTimer:getRunTime(), launchAlt, launchRtcTime)
        if landedCallback then
            landedCallback(flightTimer:getRunTime(), launchAlt, launchRtcTime)
        end
    end
    if curTime - flightStateStartTime < 150 then --still update launch alt in 1.5's after zoom
        getMaxLaunchAlt()
    end
end

local function doStateLanded(curTime, flightModeName, curRtcTime)
    if flightModeName == "zoom" then
        flightState = 0
        newFlight(curTime, curRtcTime)
    end
end

local function getLaunchRtcTime()
    return launchRtcTime
end

local function getLaunchTime()
    return launchTime
end

local function doStatePreset(curTime, flightModeName, curRtcTime)
    if flightModeName == "zoom" then
        newFlight(curTime, curRtcTime)
        flightState = 1
    end

end

local function doFlightState(curTime, flightModeName, curRtcTime)

    flightTimer:setCurTime(curTime)
    flightTimer:run()
 
    if flightState == 0 then
        doStatePreset(curTime, flightModeName, curRtcTime)
    elseif flightState == 1 then
        doStateZoom(curTime, flightModeName)
    elseif flightState == 2 then
        doStateLaunched(curTime, flightModeName)
    elseif flightState == 3 then
        doStateLanded(curTime, flightModeName, curRtcTime)
    end
end


return {newFlight = newFlight,
    doFlightState = doFlightState,
    getFlightState = getFlightState,
    getLaunchRtcTime = getLaunchRtcTime,
    getLaunchTime = getLaunchTime,
    getFlightTime = getFlightTime,
    getCurFlightStateName = getCurFlightStateName,
    setAlt = setAlt,
    getCurAlt = getCurAlt,
    getLaunchAlt = getLaunchAlt,
    getFlightRecord = getFlightRecord,
    setDestFlightTime = setDestFlightTime,
    getDestFlightTime = getDestFlightTime,
    setLandedCallback = setLandedCallback
}