local inputs = {
                 { "ResetSwitch", SOURCE},
		 { "ZoomSwitch", SOURCE},
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

local function newFlight(nowTime)
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

local function run(resetSwitch, zoomSwitch, workTimeSwitch)
	local nowTime = getTime()
	curAlt = getValue(altID)

	if gFlightState==0 then
            if resetSwitch <= 0 and zoomSwitch > 0 then
                    newFlight(nowTime)
                    gFlightState = 1
                    launchTime = nowTime
            end
	elseif gFlightState==1 then
            if zoomSwitch <= 0 then
                    gFlightState = 2
            elseif resetSwitch > 0 then
                    gFlightState = 0
            end
            gFlightTime = nowTime - launchTime

	elseif gFlightState==2 then
            if gFlightTime < 800 then
                    getMaxALT()
            end
            gFlightTime = nowTime - launchTime
            if resetSwitch > 0 then
                    addFlightResult()
                    gFlightState = 3
            end
    elseif gFlightState==3 then
            if zoomSwitch > 0 then
                    gFlightState = 0
            end

	end
    if workTimeSwitch > 0 then
            gRoundStartTime = nowTime
    end


end

return { input=inputs, run=run, init=init }
