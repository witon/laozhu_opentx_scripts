local inputs = {
                 { "ResetSwitch", SOURCE},
		 { "FlightSwitch", SOURCE},
		 { "ThChannel", SOURCE},
		 { "Threshold", VALUE, -100, 100}
	 }

gLaunchALT = 0
gFlightState = 0 --0:begin 1:power 2:power off 3:10's after power off 4:landed
local launchTime = 0
gFlightTime = 0
gWaitTime = 0
gPowerOnTimeRemain = 3000
gRoundStartTime = 0
gPowerOffTime = 0
gFlightTimeArray = {}
gLaunchALTArray = {}
gLaunchDateTimeArray = {}
gPowerOnAgainArray = {}
gPowerOnAgain = false

gOneFlightAltArray = {}

local launchDatetime
local lastCountNum = 31
local powerOffTime = 0
local flightResultIndex = 0 
local lastPlayFlightTimeCount = 0
local minUnit = 0
local altID = 0
local curAlt = 0

local function getMaxALT()
	if (curAlt > gLaunchALT) then
		gLaunchALT = curAlt
	end
end

local function changeSate1To2()
	gFlightState = 2
	powerOffTime = getTime()
	lastCountNum = 11
end

local function addFlightResult()
	flightResultIndex = flightResultIndex + 1
	if flightResultIndex > 25 then
		flightResultIndex = 1
	end
	gFlightTimeArray[flightResultIndex] = gFlightTime
	gLaunchALTArray[flightResultIndex] = gLaunchALT
	gLaunchDateTimeArray[flightResultIndex] = launchDatetime
	gPowerOnAgainArray[flightResultIndex] = gPowerOnAgain
end
local function init()
	dofile("/SCRIPTS/LAOZHU/utils.lua")
	local version = getVersion()
	if version < "2.1" then
		minUnit = 16  -- unit for minutes in OpenTX 2.0
	elseif version < "2.2" then
		minUnit = 23  -- unit for minutes in OpenTX 2.1
	else
		minUnit = 25  -- unit for minutes in OpenTX 2.2
	end
	altID = getTelemetryId("Alt")
end

local function resetFlight(curTime)
	gFlightState = 0
	gFlightTime = 0
	gLaunchALT = 0
	lastCountNum = 31
	lastPlayFlightTimeCount = 0
	gWaitTime = 0
	launchTime = 0
	gPowerOnTimeRemain = 3000
	gRoundStartTime =curTime 
	gPowerOnAgain = false

end

local function isPowerOn(throttleChannel, thresholdValue) 
	return throttleChannel >= 10*thresholdValue 
end


local function run(resetSwitch, flightSwitch, throttleChannel, thresholdValue)
	local curTime = getTime()
	curAlt = getValue(altID)
	if gFlightState==0 then
		if isPowerOn(throttleChannel, thresholdValue) then
			gFlightState = 1
			launchTime = curTime
			launchDatetime = getDateTime()
		end
	elseif gFlightState==1 then
		if not isPowerOn(throttleChannel, thresholdValue) then
			changeSate1To2()
		else
			gFlightTime = curTime - launchTime
			gPowerOnTimeRemain = 3000 - (curTime - launchTime)
			if gPowerOnTimeRemain<0 then
				gPowerOnTimeRemain = 0
				changeSate1To2()
			else
				local c = math.ceil(gPowerOnTimeRemain/100) - 1
				if c<lastCountNum and (c==20 or c<10) then
					playNumber(c, 0)
					lastCountNum = c
				end
				getMaxALT()
			end
		end

	elseif gFlightState==2 then
		gFlightTime = curTime - launchTime
		if isPowerOn(throttleChannel, thresholdValue) then
			gPowerOnAgain = true
		end
		if curTime - powerOffTime > 1000 then
			gFlightState = 3
		elseif flightSwitch<0 then
			addFlightResult()
			gFlightState = 4
		else
			getMaxALT()
			gFlightTime = curTime - launchTime 
			gWaitTime = 1100 - (curTime - powerOffTime) 
			local c = math.ceil(gWaitTime/100) - 1
			if c<lastCountNum and c>0 then
				playNumber(c, 0)
				lastCountNum = c
			end
			
		end

	elseif gFlightState==3 then
		if isPowerOn(throttleChannel, thresholdValue) then
			gPowerOnAgain = true
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
			addFlightResult()
			gFlightState = 4
		end
	elseif gFlightState==4 then
		if isPowerOn(throttleChannel, thresholdValue) then
			gPowerOnAgain = true
		end
	end

	if resetSwitch>0 then
		resetFlight(curTime)
	end
end

return { input=inputs, run=run, init=init }
