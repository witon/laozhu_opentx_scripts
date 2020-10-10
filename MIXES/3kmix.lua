local inputs = {
                {"WTSwitch", SOURCE},
                {"VarSelect", SOURCE},
                {"ReadSwitch", SOURCE},
	 }
gLaunchALT = 0
gFlightState = 0 --0:preset 1:zoom 2:launched 3:landed
gFlightTime = 0
gRoundStartTime = getTime()
gFlightTimeArray = {}
gLaunchALTArray = {}
gLaunchDateTimeArray = {}

gCurAlt = 0

local launchTime = 0
local launchDatetime = getDateTime()
local flightResultIndex = 0 
local minUnit = 0
local altID = 0

local function getMaxALT()
	if (gCurAlt > gLaunchALT) then
		gLaunchALT = gCurAlt
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
        dofile("/SCRIPTS/LAOZHU/readVar.lua")
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

local function doFlightState(curTime, flightModeName)
        if gFlightState==0 then --preset
                if flightModeName == "zoom" then
                        newFlight()
                        gFlightState = 1
                        launchTime = curTime
                end
        elseif gFlightState==1 then --zoom
                if flightModeName ~= "zoom" and flightModeName ~= "preset" then
                        gFlightState = 2
                elseif flightModeName == "preset" then
                        gFlightState = 0
                end
                gFlightTime = curTime - launchTime

        elseif gFlightState==2 then --flight
                if gFlightTime < 800 then
                        getMaxALT()
                end
                gFlightTime = curTime - launchTime
                if flightModeName == "preset" then
                        addFlightResult()
                        gFlightState = 3
                end
        elseif gFlightState==3 then --landed
                if flightModeName == "zoom" then
                        gFlightState = 0
                end

        end

end

local function run(workTimeSwitch, varSelect, readSwitch)
        local curTime = getTime()
        local flightMode, flightModeName = getFlightMode()
        gCurAlt = getValue(altID)

        doFlightState(curTime, flightModeName)
        doReadVar(varSelect, readSwitch)


        if workTimeSwitch > 0 then
                gRoundStartTime = curTime
        end


end

return { input=inputs, run=run, init=init }
