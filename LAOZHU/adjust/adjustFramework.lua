-- 调机工具：遥测 adjust.lua 与 Widget LzAdjust 共用；管理菜单、页加载、background 与编译门控。
local M = {}

local state = {
	focusIndex = 1,
	pages = { "adjust/GlobalVar.lua", "adjust/output.lua", "adjust/SinkRate/SinkRate.lua", "adjust/LD/LD.lua", "adjust/Launch/Launch.lua" },
	curPage = nil,
	bgFlag = false,
	keyMap = nil,
	frameworkInitDone = false,
	compiling = false,
	monitor = nil,
}

local function loadPage(index)
	local pagePath = "LAOZHU/" .. state.pages[index]
	state.curPage = LZ_runModule(gSDCardDir .. pagePath)
end

local function startMonitor()
	if state.monitor ~= nil then
		return
	end
	LZ_isNeedCompile = nil
	LZ_markCompiled = nil
	state.monitor = LZ_runModule(gSDCardDir .. "LAOZHU/Monitor.lua")
	state.monitor.init()
	state.monitor.bind()
end

function M.initFramework()
	LZ_runModule(gSDCardDir .. "LAOZHU/CfgO.lua")
	if state.keyMap == nil then
		LZ_runModule(gSDCardDir .. "LAOZHU/uilib/keyMap.lua")
		state.keyMap = KMgetKeyMap()
		KMunload()
	end
	if state.frameworkInitDone then
		return
	end
	state.frameworkInitDone = true
	LZ_runModule(gSDCardDir .. "LAOZHU/LuaUtils.lua")
	LZ_runModule(gSDCardDir .. "LAOZHU/OTUtils.lua")
	if LZ_isNeedCompile() then
		state.compiling = true
		state.curPage = LZ_runModule(gSDCardDir .. "LAOZHU/uilib/comp.lua")
	else
		startMonitor()
	end
	collectgarbage()
end

local function sampleLink()
	if state.monitor ~= nil then
		state.monitor.sample(getTime())
	end
end

function M.background()
	sampleLink()
	local curPage = state.curPage
	if curPage and curPage.pageState == 1 then
		LZ_clearTable(curPage)
		state.curPage = nil
	end
	if not state.bgFlag then
		state.bgFlag = true
		return
	else
		if state.curPage then
			state.curPage.bg()
		end
	end
end

-- opts.clearScreen：默认 true（遥测全屏清屏）；Widget 传 false，由分区背景代替。
function M.run(rawEvent, opts)
	opts = opts or {}
	sampleLink()
	state.bgFlag = false
	if opts.clearScreen ~= false then
		lcd.clear()
	end
	local event = rawEvent
	local mapped = state.keyMap[event]
	if mapped ~= nil then
		event = mapped
	end
	if state.curPage then
		local eventProcessed = state.curPage.run(event, getTime())
		if eventProcessed then
			return
		end
		if event == EVT_EXIT_BREAK then
			local startAfter = state.compiling
			LZ_clearTable(state.curPage)
			state.curPage = nil
			state.compiling = false
			collectgarbage()
			if startAfter then
				startMonitor()
			end
		end
		return
	end
	local rs = LZ_ui.rowStep
	local hh = LZ_ui.headerRowHeight
	lcd.drawFilledRectangle(0, 0, LCD_W, hh, FORCE)
	lcd.drawText(0, 0, "Adjust", LZ_ui.font + LEFT + INVERS)
	local pages = state.pages
	for i = 1, #pages, 1 do
		local y = hh + 1 + (i - 1) * rs
		if state.focusIndex == i then
			lcd.drawText(2, y, pages[i], LZ_ui.font + INVERS)
		else
			lcd.drawText(2, y, pages[i], LZ_ui.font)
		end
	end
	if event == EVT_ENTER_BREAK then
		loadPage(state.focusIndex)
	elseif event == 37 or event == 35 then
		state.focusIndex = state.focusIndex + 1
		if state.focusIndex > #pages then
			state.focusIndex = 1
		end
	elseif event == 38 or event == 36 then
		state.focusIndex = state.focusIndex - 1
		if state.focusIndex < 1 then
			state.focusIndex = #pages
		end
	end
end

return M
