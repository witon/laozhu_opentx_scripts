local inputs = {
                {"WTSwitch", SOURCE},
                {"VarSelect", SOURCE},
                {"ReadSwitch", SOURCE},
	 }
gRoundStartTime = getTime()

gCurAlt = 0
gScriptDir = "/SCRIPTS/"

local minUnit = 0
local altID = 0
local readVar = nil

gFlightState = dofile(gScriptDir .. "LAOZHU/F3kState.lua")
readVar = dofile(gScriptDir .. "LAOZHU/readVar.lua")

local function init()
        dofile(gScriptDir .. "LAOZHU/utils.lua")
        local f3kReadVarMap = dofile(gScriptDir .. "LAOZHU/f3kReadVarMap.lua")
        readVar.setVarMap(f3kReadVarMap)

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

local function run(workTimeSwitch, varSelect, readSwitch)
        local curTime = getTime()
        local flightMode, flightModeName = getFlightMode()
        gCurAlt = getValue(altID)

        gFlightState.setAlt(gCurAlt)
        gFlightState.doFlightState(curTime, flightModeName)
        readVar.doReadVar(varSelect, readSwitch)


        if workTimeSwitch > 0 then
                gRoundStartTime = curTime
        end


end

return { input=inputs, run=run, init=init }
