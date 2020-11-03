
local flightState = 0 --0:begin 1:power 2:power off 3:10's after power off 4:landed
local launchTime = 0
local launchDatetime = 0
local flightTime = 0
local launchAlt = 0
local lastCountNum = 0
local lastPlayFlightTimeCount = 0
local waitTime = 0
local powerOnTimeRemain = 0
local powerOnAgain = false

local function isPowerOn(throttle, throttleThreshold) 
	return throttle >= 10 * throttleThreshold
end

local function resetFlight(curTime)
	flightState = 0
	flightTime = 0
	launchALT = 0
	lastCountNum = 31
	lastPlayFlightTimeCount = 0
	waitTime = 0
	launchTime = 0
	powerOnTimeRemain = 3000
	powerOnAgain = false

end


local function doFlightState(curTime, resetSwitch, throttle, throttleThreshold)
    if flightState == 0 then
        doStateBegin(curTime, throttle, throttleThreshold)
    elseif flightState == 1 then
        doStatePower(curTime, throttle, throttleThreshold)
    elseif flightState == 2 then
        doStatePowerOff(curTime, throttle, throttleThreshold)
    elseif flightState == 3 then
        doState10SAfterPower(curTime, throttle, throttleThreshold)
    elseif flightState == 4 then
        doStateLanded(curTime, throttle, throttleThreshold)
    end
 	if resetSwitch>0 then
		resetFlight(curTime)
	end

end

local function doStateBegin(curTime, throttle, throttleThreshold)
    if isPowerOn(throttle, throttleThreshold) then
        gFlightState = 1
        launchTime = curTime
        launchDatetime = getDateTime()
    end
end

local function changeSate1To2()
	gFlightState = 2
	powerOffTime = getTime()
	lastCountNum = 11
end

local function getMaxLaunchAlt()
    if curAlt > launchAlt then
        launchAlt = curAlt
    end
end


local function doStatePower(curTime, throttle, throttleThreshold)
    if not isPowerOn(throttle, throttleThreshold) then
        changeSate1To2()
    else
        gFlightTime = curTime - launchTime
        powerOnTimeRemain = 3000 - (curTime - launchTime)
        if powerOnTimeRemain<0 then
            powerOnTimeRemain = 0
            changeSate1To2()
        else
            local c = math.ceil(powerOnTimeRemain/100) - 1
            if c<lastCountNum and (c==20 or c<10) then
                playNumber(c, 0)
                lastCountNum = c
            end
            getMaxLaunchAlt()
        end
    end
end

local function doStatePowerOff(curTime, throttle, throttleThreshold)
    if isPowerOn(throttleChannel, thresholdValue) then
        powerOnAgain = true
    end
    if flightSwitch>0 then
        gFlightTime = curTime - launchTime
        local c = math.ceil(gFlightTime / 100)
        if c>lastPlayFlightTimeCount and c%30 == 0 then
            lastPlayFlightTimeCount = c
            local minute = math.floor(c/60)
            if minute ~= 0 then
                playNumber(minute, minUnit)
            end
            local sec = c%60
            if sec ~= 0 then
                playNumber(sec, minUnit + 1)
            end
            
        end
    else
        --addFlightResult()
        gFlightState = 4
    end
end


local function doState10SAfterPower(curTime, throttle, throttleThreshold)
    if isPowerOn(throttleChannel, thresholdValue) then
        powerOnAgain = true
    end
end
