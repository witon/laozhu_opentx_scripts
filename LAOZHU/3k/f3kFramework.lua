-- F3K 遥测 / Widget 共用：仅对外 initFramework、run；内部管理 state、keyMap、翻页与设置进出。
local M = {}

local FLIGHT_PAGE_PATHS = { "3k/FlightPageNew.lua", "3k/SmallFontFlightListPage.lua" }
local SETUP_PAGE_PATHS = { "3k/RoundSetupPage.lua", "3k/SetupPage.lua" }

local state = {
	pages = FLIGHT_PAGE_PATHS,
	displayIndex = 1,
	curPage = nil,
	lastEvent = 0,
}

local keyMap

local function unloadCurPage()
	if state.curPage and state.curPage.destroy then
		state.curPage.destroy()
	end
	if state.curPage then
		LZ_clearTable(state.curPage)
	end
	state.curPage = nil
	collectgarbage()
end

local function loadPage()
	if gF3kCore == nil then
		LZ_runModule(gSDCardDir .. "LAOZHU/CfgO.lua")
		f3kCfg = CFGC:new()
		f3kCfg:readFromFile(gConfigFileName)
		gF3kCore = LZ_runModule(gSDCardDir .. "LAOZHU/3k/f3kCore.lua")
		gF3kCore.init()
	end
	local pagePath = "LAOZHU/" .. state.pages[state.displayIndex]
	state.curPage = LZ_runModule(gSDCardDir .. pagePath)
end

local function handleNavAfterPage(mappedEvent)
	if mappedEvent == EVT_EXIT_BREAK then
		if state.pages == SETUP_PAGE_PATHS then
			state.pages = FLIGHT_PAGE_PATHS
			state.displayIndex = 1
			unloadCurPage()
		end
		if gF3kCore == nil then
			unloadCurPage()
		end
	end

	if mappedEvent == 38 then
		state.displayIndex = state.displayIndex - 1
		if state.displayIndex < 1 then
			state.displayIndex = #state.pages
		end
		unloadCurPage()
	elseif mappedEvent == 37 then
		if state.lastEvent == 133 then
			state.lastEvent = mappedEvent
		else
			state.displayIndex = state.displayIndex + 1
			if state.displayIndex > #state.pages then
				state.displayIndex = 1
			end
			unloadCurPage()
		end
	end

	if mappedEvent == 133 then
		state.lastEvent = 133
		if state.pages == FLIGHT_PAGE_PATHS then
			unloadCurPage()
			state.pages = SETUP_PAGE_PATHS
			state.displayIndex = 1
		end
	end
end

function M.initFramework()
	if keyMap == nil then
		LZ_runModule(gSDCardDir .. "LAOZHU/uilib/keyMap.lua")
		keyMap = KMgetKeyMap()
		KMunload()
	end

	LZ_runModule(gSDCardDir .. "LAOZHU/LuaUtils.lua")
	LZ_runModule(gSDCardDir .. "LAOZHU/OTUtils.lua")
	LZ_runModule(gSDCardDir .. "LAOZHU/comm/OTSound.lua")

	if LZ_isNeedCompile() then
		state.curPage = LZ_runModule(gSDCardDir .. "LAOZHU/uilib/comp.lua")
		return
	else
		LZ_isNeedCompile = nil
		LZ_markCompiled = nil
	end
	collectgarbage()
end

-- opts.beforePageRun：Widget 在 curPage.run 前调用 gF3kCore.run（与 TELEMETRY 用 background 推进 core 对齐）。
function M.run(rawEvent, opts)
	opts = opts or {}
	local raw = rawEvent or 0
	local mapped = keyMap and keyMap[raw]
	local event = mapped ~= nil and mapped or raw
	local curTime = getTime()
	if state.curPage == nil then
		loadPage()
	end
	if opts.beforePageRun then
		opts.beforePageRun()
	end
	local eventProcessed = state.curPage.run(event, curTime)
	if eventProcessed then
		return true
	end
	handleNavAfterPage(event)
	return true
end

return M
