gScriptDir = "/SCRIPTS/"
gConfigFileName = "5j.cfg"

gFlightState = nil
f5jCfg = nil
local gcTime = 0

local displayIndex = 1
local pages = {"5j/FlightPage.lua", "5j/SetupPage.lua"}
local curPage = nil

local fun, err = loadScript(gScriptDir .. "TELEMETRY/common/LoadModule.lua", "bt")
fun()

local function loadPage()
	local pagePath = gScriptDir .. "TELEMETRY/" .. pages[displayIndex]
	curPage = LZ_runModule(pagePath)
	curPage.init()
end

local function init()
	LZ_runModule(gScriptDir .. "LAOZHU/utils.lua")
	LZ_runModule(gScriptDir .. "TELEMETRY/common/Fields.lua")
	initFieldsInfo()

	LZ_runModule(gScriptDir .. "TELEMETRY/common/InputView.lua")
	LZ_runModule(gScriptDir .. "TELEMETRY/common/InputSelector.lua")
	LZ_runModule(gScriptDir .. "TELEMETRY/common/NumEdit.lua")

	gFlightState = LZ_runModule(gScriptDir .. "LAOZHU/F5jState.lua")

	LZ_runModule(gScriptDir .. "/LAOZHU/Cfg.lua")
	f5jCfg = CFGnewCfg()

	CFGreadFromFile(f5jCfg, gConfigFileName)
	altID = getTelemetryId("Alt")
	gFlightState.setThrottleThreshold(CFGgetNumberField(f5jCfg, "ThThreshold"))
	loadPage()
end

local function run(event)
	local curTime = getTime()
	local curAlt = getValue(altID)
	local resetSwitchValue = getValue(CFGgetNumberField(f5jCfg, 'RsSw'))
	local flightSwitchValue = getValue(CFGgetNumberField(f5jCfg, 'FlSw'))
	local throttleValue = getValue(CFGgetNumberField(f5jCfg, 'ThCh'))
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
		LZ_clearTable(curPage)
		curPage = nil
		collectgarbage()
		gcTime = curTime
	elseif event == 37 then
		displayIndex = displayIndex + 1
		if displayIndex > #pages then
			displayIndex = 1
		end
		LZ_clearTable(curPage)
		curPage = nil
		collectgarbage()
		gcTime = curTime
	end

end

return { run=run, init=init }

