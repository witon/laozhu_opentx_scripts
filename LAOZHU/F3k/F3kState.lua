
local this = nil

local flightState = 0 --0:preset 1:zoom 2:launched 3:landed
local flightStateStartTime = 0
local flightTimer = Timer:new()

local function setDestFlightTime(time)
    this.destFlightTime = time
    flightTimer:setDuration(time)
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
    flightTimer:resetTimer(this.destFlightTime)
    flightTimer:setDowncount(15)
    flightTimer:start()
    this.launchAlt = 0
    this.minAlt = 99
    this.launchRtcTime = curRtcTime
    this.launchTime = curTime
end

local function getMaxLaunchAlt()
    if this.curAlt < this.minAlt then
        this.minAlt = this.curAlt
    end
    if this.curAlt - this.minAlt > this.launchAlt then
        this.launchAlt = this.curAlt - this.minAlt
    end
end

local function doStateZoom(curTime, flightModeName)
    if flightModeName == "preset" then
        flightState = 0
    elseif flightModeName == "zoom" then
    else
        flightState = 2
        flightStateStartTime = curTime
        if this.launchedCallback then
            this.launchedCallback(this.launchRtcTime, this.launchAlt)
        end
    end
    getMaxLaunchAlt()
end

local function doStateLaunched(curTime, flightModeName)
    if flightModeName == "preset" then
        flightTimer:stop()
        flightState = 3
        if this.landedCallback then
            this.landedCallback(flightTimer:getRunTime(), this.launchAlt, this.launchRtcTime)
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

this = {newFlight = newFlight,
    doFlightState = doFlightState,
    getFlightState = getFlightState,
    getFlightTime = getFlightTime,
    getCurFlightStateName = getCurFlightStateName,
    setDestFlightTime = setDestFlightTime,
    destFlightTime = 0,
    launchAlt = 0,
    launchRtcTime = 0,
    launchTime = 0,
    curAlt = 0,
    landedCallback = nil,
    launchedCallback = nil
}
return this