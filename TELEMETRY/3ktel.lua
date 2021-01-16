gScriptDir = "/SCRIPTS/"
gConfigFileName = "3k.cfg"
local fun, err = loadScript(gScriptDir .. "TELEMETRY/common/LoadModule.lua", "c")
fun()

LZ_runModule(gScriptDir .. "LAOZHU/Timer.lua")
gWorktimeTimer = Timer_new()
gWorktimeTimer.mute = true
gWorktimeArray = {
	420,
	600,
	900
}
gSelectWorktimeIndex = 2
Timer_setForward(gWorktimeTimer, false)

	
gFlightState = nil
gFLightStatic = nil

f3kCfg = nil

gCurAlt = 0

local displayIndex = 1

local altID = 0
local rxbtID = 0

local readVar = nil
local pages = {"3k/FlightPage.lua", "3k/FlightStaticPage.lua", "3k/SmallFontFlightListPage.lua", "3k/SetupPage.lua"}
local curPage = nil

local function init()
	LZ_runModule(gScriptDir .. "LAOZHU/utils.lua")
	gFlightState = LZ_runModule(gScriptDir .. "LAOZHU/F3kState.lua")
	gFLightStatic = LZ_runModule(gScriptDir .. "LAOZHU/FlightStatic.lua")

	LZ_runModule(gScriptDir .. "TELEMETRY/common/Fields.lua")
	initFieldsInfo()
	LZ_runModule(gScriptDir .. "TELEMETRY/common/InputSelector.lua")
	LZ_runModule(gScriptDir .. "TELEMETRY/common/NumEdit.lua")

	Timer_resetTimer(gWorktimeTimer, gWorktimeArray[gSelectWorktimeIndex])


	f3kCfg = LZ_runModule(gScriptDir .. "/LAOZHU/Cfg.lua")
	f3kCfg.readFromFile(gConfigFileName)


	altID = getTelemetryId("Alt")
	rxbtID = getTelemetryId("RxBt")

	readVar = LZ_runModule(gScriptDir .. "LAOZHU/readVar.lua")
	local f3kReadVarMap = LZ_runModule(gScriptDir .. "LAOZHU/f3kReadVarMap.lua")
	readVar.setVarMap(f3kReadVarMap)
end

local function loadPage()
	local pagePath = gScriptDir .. "TELEMETRY/" .. pages[displayIndex]
	curPage = LZ_runModule(pagePath)
	curPage.init()
end


local function run(event)
	local curTime = getTime()
	local flightMode, flightModeName = getFlightMode()
	gCurAlt = getValue(altID)

	gFlightState.setAlt(gCurAlt)
	gFlightState.doFlightState(curTime, flightModeName)

	gFLightStatic.update(getValue(rxbtID), getRSSI(), gCurAlt)


	local workTimeSwitchValue = getValue(f3kCfg.getNumberField('WtSw'))
	if workTimeSwitchValue > 0 then
		Timer_resetTimer(gWorktimeTimer, gWorktimeArray[gSelectWorktimeIndex])
		Timer_setCurTime(gWorktimeTimer, curTime)
		Timer_start(gWorktimeTimer)
	end
	Timer_setCurTime(gWorktimeTimer, curTime)
	Timer_run(gWorktimeTimer)

	local varSelectorSliderValue = getValue(f3kCfg.getNumberField('SelSlider'))
	local varReadSwitchValue = getValue(f3kCfg.getNumberField('ReadSw'))
	
	readVar.doReadVar(varSelectorSliderValue, varReadSwitchValue, curTime)

	lcd.clear()

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
