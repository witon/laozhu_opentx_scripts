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


local launchTime = 0
local launchDatetime = getDateTime()
local flightResultIndex = 0 
local minUnit = 0
local altID = 0
local curAlt = 0
local curVar = -1 -- -1:init 0:flight time 1:cur alt 2:rssi 3:launch alt
local curReadSwitchState = 0

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

local function readVar()
        if curVar == 0 then --flight time
                playDuration(gFlightTime/100, 0)
        elseif curVar == 1 then --cur alt
                playNumber(curAlt, 9)
        elseif curVar ==2 then --rssi
                local rssi, alarm_low, alarm_crit = getRSSI() 
                playNumber(rssi, 17)
        elseif curVar ==3 then --launch alt
                playNumber(gLaunchALT, 9)
        end
end

local function getSelectedVar(varSelect)
        local v = 0
        if varSelect < -750 then
                v = 0
        elseif varSelect >= -750 and varSelect < 0 then
                v = 1
        elseif varSelect >=0 and varSelect < 750 then
                v = 2
        elseif varSelect >= 750 then
                v = 3
        end
        return v
end



local function doReadVar(varSelect, readSwitch)
        local v = getSelectedVar(varSelect)
        if curVar == -1 then
                curVar = v
        elseif curVar ~= v then
                curVar = v
                readVar()
        end

        if readSwitch ~= curReadSwitchState then
                if readSwitch < 0 then
                        readVar()
                end
                curReadSwitchState = readSwitch 
        end
end

local function run(workTimeSwitch, varSelect, readSwitch)
        local curTime = getTime()
        local flightMode, flightModeName = getFlightMode()
        curAlt = getValue(altID)

        doFlightState(curTime, flightModeName)
        doReadVar(varSelect, readSwitch)


        if workTimeSwitch > 0 then
                gRoundStartTime = curTime
        end


end

return { input=inputs, run=run, init=init }
