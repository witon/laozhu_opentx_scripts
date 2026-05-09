gSDCardDir = "/"
gConfigFileName = "3k.cfg"
local fun, err = loadScript(gSDCardDir .. "LAOZHU/uilib/LoadModule.lua", "bt")
fun()
gF3kCore = nil

f3kCfg = nil

local displayIndex = 1
local flightPagePages = {"3k/FlightPageNew.lua", "3k/SmallFontFlightListPage.lua"}
local setupPages = {"3k/RoundSetupPage.lua", "3k/SetupPage.lua"}
local pages = flightPagePages
local curPage = nil
local lastEvent = 0


LZ_runModule(gSDCardDir .. "LAOZHU/uilib/keyMap.lua")
local keyMap = KMgetKeyMap();
KMunload();


local function init()
	LZ_runModule(gSDCardDir .. "LAOZHU/LuaUtils.lua")
	LZ_runModule(gSDCardDir .. "LAOZHU/OTUtils.lua")
	
	LZ_runModule(gSDCardDir .. "LAOZHU/comm/OTSound.lua")

	if LZ_isNeedCompile() then
		curPage = LZ_runModule(gSDCardDir .. "LAOZHU/uilib/comp.lua")
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
		LZ_runModule(gSDCardDir .. "LAOZHU/CfgO.lua")
		f3kCfg = CFGC:new()
		f3kCfg:readFromFile(gConfigFileName)
		gF3kCore = LZ_runModule(gSDCardDir .. "LAOZHU/3k/f3kCore.lua")
		gF3kCore.init()
	end
	local pagePath = "LAOZHU/" .. pages[displayIndex]
	curPage = LZ_runModule(gSDCardDir .. pagePath)
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

	e = keyMap[event];
	if false then
		if event ~= 0 then
			lcd.clear()
			lcd.drawText(10, 10, "event:", LZ_ui.font)
			lcd.drawNumber(10, 20, event, LZ_ui.font)
			lcd.drawText(10, 30, "e:", LZ_ui.font)
			if e ~= nil then
				lcd.drawNumber(10, 40, e, LZ_ui.font)
			end
		end
		return
	else
		lcd.clear()
	end

	if e ~= nil then
		event = e;
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
	return true;


end

return { run=run, init=init, background=background }
