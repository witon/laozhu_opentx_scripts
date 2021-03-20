gScriptDir = "/SCRIPTS/"
gConfigFileName = "3k.cfg"
local fun, err = loadScript(gScriptDir .. "TELEMETRY/common/LoadModule.lua", "bt")
fun()

gF3kCore = nil

f3kCfg = nil

local displayIndex = 1
local pages = {"3k/FlightPage.lua", "3k/SmallFontFlightListPage.lua", "3k/SetupPage.lua"}
local curPage = nil


local function init()
	LZ_runModule(gScriptDir .. "LAOZHU/utils.lua")
	if LZ_isNeedCompile() then
		local pagePath = gScriptDir .. "TELEMETRY/common/comp.lua"
		curPage = LZ_runModule(pagePath)
		curPage.init()
		return
	end
end


local function loadPage()
	if gF3kCore == nil then
		LZ_runModule(gScriptDir .. "LAOZHU/Cfg.lua")
		f3kCfg = CFGnewCfg()
		CFGreadFromFile(f3kCfg, gConfigFileName)
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
		if curPage.destroy then
			curPage.destroy()
		end
		LZ_clearTable(curPage)
		curPage = nil
		collectgarbage()
	end

	if event==38 then 
		displayIndex = displayIndex - 1
		if displayIndex < 1 then
			displayIndex = #pages
		end
		if curPage.destroy then
			curPage.destroy()
		end
		LZ_clearTable(curPage)
		curPage = nil
		collectgarbage()
	elseif event == 37 then
		displayIndex = displayIndex + 1
		if displayIndex > #pages then
			displayIndex = 1
		end
		if curPage.destroy then
			curPage.destroy()
		end
		LZ_clearTable(curPage)
		curPage = nil
		collectgarbage()
	end

end

return { run=run, init=init, background=background }
