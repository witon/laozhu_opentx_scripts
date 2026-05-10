-- 调机工具：遥测 adjust.lua 与 Widget LzAdjust 共用；管理菜单、页加载、background 与编译门控。
local M = {}

local state = {
	focusIndex = 1,
	pages = { "adjust/GlobalVar.lua", "adjust/output.lua", "adjust/SinkRate/SinkRate.lua", "adjust/LD/LD.lua", "adjust/Launch/Launch.lua" },
	curPage = nil,
	bgFlag = false,
	keyMap = nil,
	frameworkInitDone = false,
}

local function loadPage(index)
	local pagePath = "LAOZHU/" .. state.pages[index]
	state.curPage = LZ_runModule(gSDCardDir .. pagePath)
end

function M.initFramework()
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
		state.curPage = LZ_runModule(gSDCardDir .. "LAOZHU/uilib/comp.lua")
	else
		LZ_isNeedCompile = nil
		LZ_markCompiled = nil
	end
	collectgarbage()
end

function M.background()
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
			LZ_clearTable(state.curPage)
			state.curPage = nil
			collectgarbage()
		end
		return
	end
	local pages = state.pages
	for i = 1, #pages, 1 do
		if state.focusIndex == i then
			lcd.drawText(2, i * 11, pages[i], INVERS)
		else
			lcd.drawText(2, i * 11, pages[i])
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
