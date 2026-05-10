-- F3K 遥测 / Widget 共用：编译门控、按索引加载页面、卸载、全局翻页与进出设置。
-- handleNavAfterPage 的 mappedEvent 须为 keyMap 映射后的值（与 curPage.run 一致）。
local M = {}

M.FLIGHT_PAGE_PATHS = { "3k/FlightPageNew.lua", "3k/SmallFontFlightListPage.lua" }
M.SETUP_PAGE_PATHS = { "3k/RoundSetupPage.lua", "3k/SetupPage.lua" }

function M.telInit(state)
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

function M.loadPage(state)
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

function M.unloadCurPage(state)
	if state.curPage and state.curPage.destroy then
		state.curPage.destroy()
	end
	if state.curPage then
		LZ_clearTable(state.curPage)
	end
	state.curPage = nil
	collectgarbage()
end

function M.handleNavAfterPage(state, mappedEvent)
	if mappedEvent == EVT_EXIT_BREAK then
		if state.pages == M.SETUP_PAGE_PATHS then
			state.pages = M.FLIGHT_PAGE_PATHS
			state.displayIndex = 1
			M.unloadCurPage(state)
		end
		if gF3kCore == nil then
			M.unloadCurPage(state)
		end
	end

	if mappedEvent == 38 then
		state.displayIndex = state.displayIndex - 1
		if state.displayIndex < 1 then
			state.displayIndex = #state.pages
		end
		M.unloadCurPage(state)
	elseif mappedEvent == 37 then
		if state.lastEvent == 133 then
			state.lastEvent = mappedEvent
		else
			state.displayIndex = state.displayIndex + 1
			if state.displayIndex > #state.pages then
				state.displayIndex = 1
			end
			M.unloadCurPage(state)
		end
	end

	if mappedEvent == 133 then
		state.lastEvent = 133
		if state.pages == M.FLIGHT_PAGE_PATHS then
			M.unloadCurPage(state)
			state.pages = M.SETUP_PAGE_PATHS
			state.displayIndex = 1
		end
	end
end

return M
