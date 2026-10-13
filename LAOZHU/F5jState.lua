
local flightState = 0 --0:begin; 1:power on; 2:10's after power off; 3: flight; 4:landed
local launchTime = 0
local launchDatetime = 0
local flightTime = 0
local launchAlt = 0
local powerOnAgain = false
local throttleThreshold = 0
local curAlt = 0


local curTime = 0
local throttle = 0
local resetSwitch = 0
local flightSwitch = 0

dofile(gSDCardDir .. "LAOZHU/comm/Timer.lua")

local workTime = 600
local worktimeTimer = Timer:new()
worktimeTimer:resetTimer(workTime)
local stateTimer = Timer:new()


local function getCurFlightStateName()
    if flightState == 0 then
        return "Prepare"
    elseif flightState == 1 then
        return "PwOn"
    elseif flightState == 2 then
        return "PwOff"
    elseif flightState == 3 then
        return "Flight"
    else
        return "Landed"
    end
end


local function updateLaunchAlt()
    if curAlt > launchAlt then
        launchAlt = curAlt
    end
end

local function getFlightState()
    return flightState
end

local function setAlt(alt)
    curAlt = alt
end

local function setWorkTime(seconds)
	if seconds == workTime then
		return
	end
	workTime = seconds
	if worktimeTimer.startTime == 0 then
		worktimeTimer:setDuration(workTime)
	end
end

local function resetWorktimeTimer()
	worktimeTimer:resetTimer(workTime)
	worktimeTimer:setForward(true)
	worktimeTimer:setDowncount(20)
end

local function getWorktimeTimer()
    return worktimeTimer
end

local function getFlightTime()
    return math.floor(flightTime / 100)
end

local function getStateTimer()
    return stateTimer
end


local function setThrottleThreshold(threshold)
    throttleThreshold = threshold * 1024 / 100
end

local function isPowerOn() 
	return throttle >= throttleThreshold
end

local function resetFlight()
	flightState = 0
	flightTime = 0
	launchAlt = 0
	launchTime = 0
    powerOnAgain = false
    worktimeTimer:stop()
    worktimeTimer:resetTimer(workTime)
    stateTimer:stop()
end

local function startPoweronTimer()
    stateTimer:resetTimer(30)
    stateTimer:setIntegralInterval(5)
    stateTimer:setForward(true)
    stateTimer:setDowncount(10)
    stateTimer:start(curTime)
end

local function startWorktimeTimer()
    worktimeTimer:resetTimer(workTime)
    worktimeTimer:setForward(false)
    worktimeTimer:setDowncount(20)
    worktimeTimer:start(curTime)
end

local function doStatePrepare()
    if isPowerOn() and flightSwitch > 0 then
        flightState = 1
        launchTime = curTime
        launchDatetime = getDateTime()
        startPoweronTimer()
        startWorktimeTimer()
    end
end

local function doState10sAfterPowerOff()
    flightTime = curTime - launchTime
    if isPowerOn() then
        powerOnAgain = true
    end
    
    if flightSwitch < 0 then
        stateTimer:stop()
        flightState = 4
        return
        --addFlightResult()
    end

    updateLaunchAlt()

    if stateTimer:getRemainTime() <= 0 then
        flightState = 3
    end

end

local function startPoweroffTimer()
    stateTimer:resetTimer(10)
    stateTimer:setIntegralInterval(30)
    stateTimer:setForward(false)
    stateTimer:setDowncount(9)
    stateTimer:start(curTime)
end

local function changeSateFromPowerOnToPowerOff()
	flightState = 2
    startPoweroffTimer()
    doState10sAfterPowerOff()
end


local function doStatePowerOn()
    flightTime = curTime - launchTime
    updateLaunchAlt()

    if flightSwitch < 0 then
        flightState = 4
        return
    end

    if not isPowerOn() then
        changeSateFromPowerOnToPowerOff()
        return
    end

    if stateTimer:getRemainTime() <= 0 then
        changeSateFromPowerOnToPowerOff()
    end
end

local function doStateFlight()
    flightTime = curTime - launchTime
    if isPowerOn() then
        powerOnAgain = true
    end
    if flightSwitch < 0 then
        flightState = 4
    end
end

local function doStateLanded()

end


local function doFlightState(time, resetSwitchValue, throttleValue, flightSwitchValue)
    curTime = time
    resetSwitch = resetSwitchValue
    throttle = throttleValue
    flightSwitch = flightSwitchValue

    worktimeTimer:setCurTime(time)
    worktimeTimer:run()
    stateTimer:setCurTime(time)
    stateTimer:run()

    if flightState == 0 then
        doStatePrepare()
    elseif flightState == 1 then
        doStatePowerOn()
    elseif flightState == 2 then
        doState10sAfterPowerOff()
    elseif flightState == 3 then
        doStateFlight()
    elseif flightState == 4 then
        doStateLanded()
    end
 	if resetSwitch>0 then
		resetFlight()
	end

end

local function getLaunchAlt()
    return launchAlt
end

local function getAlt()
    return curAlt
end

local function isPowerOnAgain()
    return powerOnAgain
end

return {resetFlight = resetFlight,
        getFlightState = getFlightState,
        setThrottleThreshold = setThrottleThreshold,
        setWorkTime = setWorkTime,
        doFlightState = doFlightState,
        setAlt = setAlt,
        getLaunchAlt = getLaunchAlt,
        getAlt = getAlt,
        getStateTimer = getStateTimer,
        getWorktimeTimer = getWorktimeTimer,
        getFlightTime = getFlightTime,
        getCurFlightStateName = getCurFlightStateName,
        isPowerOnAgain = isPowerOnAgain
    }