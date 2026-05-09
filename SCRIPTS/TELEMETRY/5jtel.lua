gSDCardDir = "/"
gConfigFileName = "5j.cfg"
local fun, err = loadScript(gSDCardDir .. "LAOZHU/uilib/LoadModule.lua", "bt")
fun()
gFlightState = nil
f5jCfg = nil
local gcTime = 0

local displayIndex = 1
local flightPagePages = {"5j/FlightPage.lua"}
local setupPages = {"5j/SetupPage.lua"}
local pages = flightPagePages
local curPage = nil
local lastEvent = 0
local readVar = nil

LZ_runModule(gSDCardDir .. "LAOZHU/uilib/keyMap.lua")
local keyMap = KMgetKeyMap();
KMunload();

local function loadPage()
	if gFlightState == nil then
		gFlightState = LZ_runModule(gSDCardDir .. "LAOZHU/F5jState.lua")
		LZ_runModule(gSDCardDir .. "LAOZHU/Cfg.lua")
		f5jCfg = CFGnewCfg()
		CFGreadFromFile(f5jCfg, gConfigFileName)
		altID = getTelemetryId("Alt")
		readVar = LZ_runModule(gSDCardDir .. "LAOZHU/readVar.lua")
		local f5jReadVarMap = LZ_runModule(gSDCardDir .. "LAOZHU/f5jReadVarMap.lua")
		f5jReadVarMap.setF5jState(gFlightState)
		readVar.setVarMap(f5jReadVarMap)
	end
	local pagePath = "TELEMETRY/" .. pages[displayIndex]
	curPage = LZ_runModule(gSDCardDir .. "SCRIPTS/" .. pagePath)
	curPage.init()
end

local function unloadCurPage()
	if curPage.destroy then
		curPage.destroy()
	end
	LZ_clearTable(curPage)
	curPage = nil
	collectgarbage()
end

local function init()
	LZ_runModule(gSDCardDir .. "LAOZHU/LuaUtils.lua")
	LZ_runModule(gSDCardDir .. "LAOZHU/OTUtils.lua")
	LZ_runModule(gSDCardDir .. "LAOZHU/comm/OTSound.lua")

	LZ_runModule(gSDCardDir .. "LAOZHU/uilib/Fields.lua")
	initFieldsInfo()
	LZ_runModule(gSDCardDir .. "LAOZHU/uilib/InputView.lua")
	LZ_runModule(gSDCardDir .. "LAOZHU/uilib/InputSelector.lua")
	LZ_runModule(gSDCardDir .. "LAOZHU/uilib/NumEdit.lua")

	if LZ_isNeedCompile() then
		curPage = LZ_runModule(gSDCardDir .. "LAOZHU/uilib/comp.lua")
		return
	else
		LZ_isNeedCompile = nil
		LZ_markCompiled = nil
	end
	collectgarbage();

	loadPage()
end

local function stateRun(curTime)
	local curAlt = getValue(altID)
	local resetSwitchValue = getValue(CFGgetNumberField(f5jCfg, 'RsSw'))
	local flightSwitchValue = getValue(CFGgetNumberField(f5jCfg, 'FlSw'))
	local throttleValue = getValue(CFGgetNumberField(f5jCfg, 'ThCh'))
	gFlightState.setThrottleThreshold(CFGgetNumberField(f5jCfg, "ThThreshold"))
	gFlightState.setAlt(curAlt)
	gFlightState.doFlightState(curTime, resetSwitchValue, throttleValue, flightSwitchValue)
	local varSelectorSliderValue = getValue(CFGgetNumberField(f5jCfg, 'SelSlider'))
	local varReadSwitchValue = getValue(CFGgetNumberField(f5jCfg, 'ReadSw'))
	readVar.doReadVar(varSelectorSliderValue, varReadSwitchValue, curTime)
end

local function background()
	if gFlightState == nil then
		return
	end
	local curTime = getTime()
	stateRun(curTime)
end

local function run(event)
	local curTime = getTime()
	lcd.clear()
	e = keyMap[event];
	if e ~= nil then
		event = e;
	end

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

	if event == EVT_EXIT_BREAK then --退出设置界面
		if pages == setupPages then
			pages = flightPagePages
			displayIndex = 1
			unloadCurPage()
		end
		if gFlightState == nil then	--compiling page
			unloadCurPage()
		end
	end

	if event==38 then 
		displayIndex = displayIndex - 1
		if displayIndex < 1 then
			displayIndex = #pages
		end
		unloadCurPage()
		gcTime = curTime
	elseif event == 37 then
		displayIndex = displayIndex + 1
		if displayIndex > #pages then
			displayIndex = 1
		end
		unloadCurPage()
		gcTime = curTime
	end
	if event == 133 then --进入设置界面
		lastEvent = 133
		if pages == flightPagePages then
			unloadCurPage()
			pages = setupPages
			displayIndex = 1
		end
	end

end

return { run=run, init=init, background=background }

