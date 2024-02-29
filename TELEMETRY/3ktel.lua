gScriptDir = "/SCRIPTS/"
gConfigFileName = "3k.cfg"
local fun, err = loadScript(gScriptDir .. "TELEMETRY/common/LoadModule.lua", "bt")
fun()
gF3kCore = nil

f3kCfg = nil

local displayIndex = 1
local flightPagePages = {"3k/FlightPageNew.lua", "3k/SmallFontFlightListPage.lua"}
local setupPages = {"3k/RoundSetupPage.lua", "3k/SetupPage.lua"}
local pages = flightPagePages
local curPage = nil
local lastEvent = 0


LZ_runModule("TELEMETRY/common/keyMap.lua")
local keyMap = KMgetKeyMap();
KMunload();


local function init()
	LZ_runModule("LAOZHU/LuaUtils.lua")
	LZ_runModule("LAOZHU/OTUtils.lua")
	
	LZ_runModule("LAOZHU/comm/OTSound.lua")

	if LZ_isNeedCompile() then
		local pagePath = "TELEMETRY/common/comp.lua"
		curPage = LZ_runModule(pagePath)
		--curPage.init()
		return
	else
		LZ_isNeedCompile = nil
		LZ_markCompiled = nil
	end
	collectgarbage();
end


local function loadPage()
	if gF3kCore == nil then
		LZ_runModule("LAOZHU/CfgO.lua")
		f3kCfg = CFGC:new()
		f3kCfg:readFromFile(gConfigFileName)
		gF3kCore = LZ_runModule("TELEMETRY/3k/f3kCore.lua")
		gF3kCore.init()
	end
	local pagePath = "TELEMETRY/" .. pages[displayIndex]
	curPage = LZ_runModule(pagePath)
	--curPage.init()
end

local function background()
	if gF3kCore == nil then
		return
	end
	gF3kCore.run()
end

local function unloadCurPage()
	if curPage.destroy then
		curPage.destroy()
	end
	LZ_clearTable(curPage)
	curPage = nil
	collectgarbage()
end
local function run(event)
	lcd.clear()

	if event ~= 0 then
		print("before:", event, EVT_EXIT_BREAK, EVT_PAGE_LONG, EVT_ENTER_LONG)
	end
	e = keyMap[event];
	if e ~= nil then
		event = e;
	end
	if event ~= 0 then
		print("after:", event)
	end

	local curTime = getTime()
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
		if gF3kCore == nil then	--compiling page
			unloadCurPage()
		end
	end

	if event==38 then 
		displayIndex = displayIndex - 1
		if displayIndex < 1 then
			displayIndex = #pages
		end
		unloadCurPage()
	elseif event == 37 then
		if lastEvent == 133 then	--because system will trigger event 37 once after event 133
			lastEvent = event
		else
			displayIndex = displayIndex + 1
			if displayIndex > #pages then
				displayIndex = 1
			end
			unloadCurPage()
		end
	end

	if event == 133 then --进入设置界面
		lastEvent = 133
		if pages == flightPagePages then
			unloadCurPage()
			pages = setupPages
			displayIndex = 1
		end
	end
	lcd.drawText(128, 58, getAvailableMemory(), SMLSIZE + RIGHT)
	return true;


end

return { run=run, init=init, background=background }
