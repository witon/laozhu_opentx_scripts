gScriptDir = "/SCRIPTS/"

gFlightState = nil
f3kCfg = nil

local displayIndex = 1

local altID = 0
local readVar = nil
local pages = {"3k/FlightPage.lua", "3k/LargeFontFlightListPage.lua", "3k/SmallFontFlightListPage.lua", "3k/SetupPage.lua"}
local function init()
	dofile(gScriptDir .. "LAOZHU/utils.lua")
	gFlightState = dofile(gScriptDir .. "LAOZHU/F3kState.lua")

	f3kCfg = dofile(gScriptDir .. "/LAOZHU/F3kCfg.lua")
	f3kCfg.readFromFile()

	for i = 1, 4 do
		local page = pages[i]
		local pagePath = gScriptDir .. "TELEMETRY/" .. page
		pages[i] = dofile(pagePath)
		pages[i].init()
	end 


	altID = getTelemetryId("Alt")

	readVar = dofile(gScriptDir .. "LAOZHU/readVar.lua")
	local f3kReadVarMap = dofile(gScriptDir .. "LAOZHU/f3kReadVarMap.lua")
	readVar.setVarMap(f3kReadVarMap)
end

local function drawSetupPage(event, time)
	setupPage.run(event, time)
end

local function DrawLargeFontFlightList(event, time)
	largeFontFlightListPage.run(event, time)
end


local function DrawSmallFontFlightList(event, time)
	smallFontFlightListPage.run(event, time)

end

local function run(event)
	local curTime = getTime()
	local flightMode, flightModeName = getFlightMode()
	gCurAlt = getValue(altID)

	gFlightState.setAlt(gCurAlt)
	gFlightState.doFlightState(curTime, flightModeName)

	readVar.doReadVar(getValue(f3kCfg.getVarSelectorSlider()), getValue(f3kCfg.getVarReadSwitch()), curTime)



	lcd.clear()
	pages[displayIndex].run(event, curTime)
	if event==38 then 
		displayIndex = displayIndex - 1
		if displayIndex < 1 then
			displayIndex = 4 
		end
	elseif event == 37 then
		displayIndex = displayIndex + 1
		if displayIndex > 4 then
			displayIndex = 1
		end

	end
	
end

return { run=run, init=init }
