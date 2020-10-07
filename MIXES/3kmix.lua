local inputs = {
                { "WTSwitch", SOURCE},
	 }
gLaunchALT = 0
gFlightState = 0 --0:preset 1:zoom 2:launched 3:landed
gFlightTime = 0
gRoundStartTime = getTime()
gFlightTimeArray = {}
gLaunchALTArray = {}
gLaunchDateTimeArray = {}


local launchTime = 0
local launchDatetime = getDateTime()
local flightResultIndex = 0 
local minUnit = 0
local altID = 0
local curAlt = 0

local function getMaxALT()
	if (curAlt > gLaunchALT) then
		gLaunchALT = curAlt
	end
end


local function addFlightResult()
	flightResultIndex = flightResultIndex + 1
	if flightResultIndex > 25 then
		flightResultIndex = 1
	end
	gFlightTimeArray[flightResultIndex] = gFlightTime
	gLaunchALTArray[flightResultIndex] = gLaunchALT
	gLaunchDateTimeArray[flightResultIndex] = launchDatetime
end

local function newFlight()
        gFlightState = 0
		gFlightTime = 0
		gLaunchALT = 0
		launchTime = 0
        launchDatetime = getDateTime()
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
    addFlightResult()
end


local function run(workTimeSwitch)
        local curTime = getTime()
        local flightMode, flightModeName = getFlightMode()

        curAlt = getValue(altID)


	if gFlightState==0 then
            if flightModeName == "zoom" then
                    newFlight()
                    gFlightState = 1
                    launchTime = curTime
            end
	elseif gFlightState==1 then
            if flightModeName ~= "zoom" and flightModeName ~= "preset" then
                    gFlightState = 2
            elseif flightModeName == "preset" then
                    gFlightState = 0
            end
            gFlightTime = curTime - launchTime

	elseif gFlightState==2 then
            if gFlightTime < 800 then
                    getMaxALT()
            end
            gFlightTime = curTime - launchTime
            if flightModeName == "preset" then
                    addFlightResult()
                    gFlightState = 3
            end
        elseif gFlightState==3 then
            if flightModeName == "zoom" then
                    gFlightState = 0
            end

	end
    if workTimeSwitch > 0 then
            gRoundStartTime = curTime
    end


end

return { input=inputs, run=run, init=init }
