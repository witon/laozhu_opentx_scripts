-- F5J 遥测 / Widget 共用：对外 initFramework、run；内部管理分页、设置进出、编译门控。
local M = {}

local FLIGHT_PAGE_PATHS = { "5j/FlightPage.lua" }
local SETUP_PAGE_PATHS = { "5j/SetupPage.lua" }

local state = {
	pages = FLIGHT_PAGE_PATHS,
	displayIndex = 1,
	curPage = nil,
	lastEvent = 0,
	gcTime = 0,
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
	if gF5jCore == nil then
		gF5jCore = LZ_runModule(gSDCardDir .. "LAOZHU/5j/f5jCore.lua")
		gF5jCore.init()
	end
	local pagePath = "LAOZHU/" .. state.pages[state.displayIndex]
	state.curPage = LZ_runModule(gSDCardDir .. pagePath)
	if state.curPage.init then
		state.curPage.init()
	end
end

local function handleNavAfterPage(mappedEvent)
	if mappedEvent == EVT_EXIT_BREAK then
		if state.pages == SETUP_PAGE_PATHS then
			state.pages = FLIGHT_PAGE_PATHS
			state.displayIndex = 1
			unloadCurPage()
		end
		if gF5jCore == nil then
			unloadCurPage()
		end
	end

	if mappedEvent == 38 then
		state.displayIndex = state.displayIndex - 1
		if state.displayIndex < 1 then
			state.displayIndex = #state.pages
		end
		unloadCurPage()
		state.gcTime = getTime()
	elseif mappedEvent == 37 then
		if state.lastEvent == 68 then
			state.lastEvent = mappedEvent
		else
			state.displayIndex = state.displayIndex + 1
			if state.displayIndex > #state.pages then
				state.displayIndex = 1
			end
			unloadCurPage()
			state.gcTime = getTime()
		end
	end

	if mappedEvent == 68 then
		state.lastEvent = 68
		if state.pages == FLIGHT_PAGE_PATHS then
			unloadCurPage()
			state.pages = SETUP_PAGE_PATHS
			state.displayIndex = 1
		end
	end
end

function M.initFramework()
	LZ_runModule(gSDCardDir .. "LAOZHU/CfgO.lua")
	if keyMap == nil then
		LZ_runModule(gSDCardDir .. "LAOZHU/uilib/keyMap.lua")
		keyMap = KMgetKeyMap()
		KMunload()
	end

	LZ_runModule(gSDCardDir .. "LAOZHU/LuaUtils.lua")
	LZ_runModule(gSDCardDir .. "LAOZHU/OTUtils.lua")
	LZ_runModule(gSDCardDir .. "LAOZHU/comm/OTSound.lua")

	LZ_runModule(gSDCardDir .. "LAOZHU/uilib/Fields.lua")
	initFieldsInfo()
	LZ_runModule(gSDCardDir .. "LAOZHU/uilib/InputView.lua")
	LZ_runModule(gSDCardDir .. "LAOZHU/uilib/InputSelector.lua")
	LZ_runModule(gSDCardDir .. "LAOZHU/uilib/NumEdit.lua")

	if LZ_isNeedCompile() then
		state.curPage = LZ_runModule(gSDCardDir .. "LAOZHU/uilib/comp.lua")
		return
	else
		LZ_isNeedCompile = nil
		LZ_markCompiled = nil
	end
	collectgarbage()
end

-- opts.beforePageRun：Widget 在 curPage.run 前调用 gF5jCore.run。
-- opts.clearScreen：默认 true；Widget 传 false，由分区背景代替。
function M.run(rawEvent, opts)
	opts = opts or {}
	local raw = rawEvent or 0
	local mapped = keyMap and keyMap[raw]
	local event = mapped ~= nil and mapped or raw
	local curTime = getTime()

	if opts.clearScreen ~= false then
		lcd.clear()
	end

	if curTime - state.gcTime < 5 then
		return true
	end

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
