gScriptDir = "/SCRIPTS/"
gConfigFileName = "5j.cfg"

gFlightState = nil
f5jCfg = nil
local gcTime = 0

local displayIndex = 1
local pages = {"5j/FlightPage.lua", "5j/SetupPage.lua"}
local curPage = nil

local function loadPage()
	local pagePath = gScriptDir .. "TELEMETRY/" .. pages[displayIndex]
	curPage = dofile(pagePath)
	curPage.init()
end

local function init()
	dofile(gScriptDir .. "LAOZHU/utils.lua")
	dofile(gScriptDir .. "TELEMETRY/common/Fields.lua")
	initFieldsInfo()
	dofile(gScriptDir .. "TELEMETRY/common/InputSelector.lua")

	gFlightState = dofile(gScriptDir .. "LAOZHU/F5jState.lua")

	f5jCfg = dofile(gScriptDir .. "/LAOZHU/Cfg.lua")
	f5jCfg.readFromFile(gConfigFileName)
	altID = getTelemetryId("Alt")
	loadPage()
end

local function run(event)
	local curTime = getTime()
	local curAlt = getValue(altID)
	local resetSwitchValue = getValue(f5jCfg.getNumberField('RsSw'))
	local flightSwitchValue = getValue(f5jCfg.getNumberField('FlSw'))
	local throttleValue = getValue(f5jCfg.getNumberField('ThCh'))
	gFlightState.setAlt(curAlt)
	gFlightState.doFlightState(curTime, resetSwitchValue, throttleValue, flightSwitchValue)


	lcd.clear()
	if curTime - gcTime < 5 then
		return
	end

	if curPage == nil then
		loadPage()
	end
	local eventProcessed = curPage.run(event, curTime)
	if eventProcessed then
		return
	end
	if event==38 then 
		displayIndex = displayIndex - 1
		if displayIndex < 1 then
			displayIndex = #pages
		end
		curPage = nil
		collectgarbage()
		gcTime = curTime
	elseif event == 37 then
		displayIndex = displayIndex + 1
		if displayIndex > #pages then
			displayIndex = 1
		end
		curPage = nil
		collectgarbage()
		gcTime = curTime
	end

end

return { run=run, init=init }

