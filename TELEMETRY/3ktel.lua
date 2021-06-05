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

local function init()
	LZ_runModule(gScriptDir .. "LAOZHU/LuaUtils.lua")
	LZ_runModule(gScriptDir .. "LAOZHU/OTUtils.lua")
	
	LZ_runModule(gScriptDir .. "LAOZHU/comm/OTSound.lua")

	if LZ_isNeedCompile() then
		local pagePath = gScriptDir .. "TELEMETRY/common/comp.lua"
		curPage = LZ_runModule(pagePath)
		curPage.init()
		return
	end
end


local function loadPage()
	if gF3kCore == nil then
		LZ_runModule(gScriptDir .. "LAOZHU/CfgO.lua")
		f3kCfg = CFGC:new()
		f3kCfg:readFromFile(gConfigFileName)
		gF3kCore = LZ_runModule(gScriptDir .. "TELEMETRY/3k/f3kCore.lua")
		gF3kCore.init()
	end
	local pagePath = gScriptDir .. "TELEMETRY/" .. pages[displayIndex]
	curPage = LZ_runModule(pagePath)
	curPage.init()
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
	local curTime = getTime()
	if curPage == nil then
		loadPage()
	end
	local eventProcessed = curPage.run(event, curTime)
	if eventProcessed then
		return
	end
	if event == EVT_EXIT_BREAK then
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
		if lastEvent == 69 then	--because system will trigger event 37 once after event 69
			lastEvent = event
		else
			displayIndex = displayIndex + 1
			if displayIndex > #pages then
				displayIndex = 1
			end
			unloadCurPage()
		end
	end

	if event == 69 then
		lastEvent = 69
		if pages == flightPagePages then
			unloadCurPage()
			pages = setupPages
			displayIndex = 1
		end
	end

end

return { run=run, init=init, background=background }
