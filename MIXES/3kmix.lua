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

gF3kState = dofile(gScriptDir .. "LAOZHU/F3kState.lua")

local function init()
        dofile(gScriptDir .. "LAOZHU/utils.lua")
        dofile(gScriptDir .. "LAOZHU/readVar.lua")
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

        gF3kState.doFlightState(curTime, flightModeName)
        doReadVar(varSelect, readSwitch)


        if workTimeSwitch > 0 then
                gRoundStartTime = curTime
        end


end

return { input=inputs, run=run, init=init }
