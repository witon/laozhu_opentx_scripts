-- 彩屏 Widget 版 F3K：行为对齐 SCRIPTS/TELEMETRY/3ktel.lua（页面 / gF3kCore / 按键逻辑）。
-- App 布局请用「App mode」；需先 **长按 ENTER**（或长按触摸）交权后 `event` 才非 nil。
-- 现有 LAOZHU/3k 页面使用约 128×64 绝对坐标，建议全屏或大区域放置；详见仓库 F3K Widget 计划说明。

local name = "Lz3k"

local options = {
	{ "Color", COLOR, COLOR_THEME_SECONDARY1 },
}

local DBG_OPTS = {
	printTag = "[Lz3k]",
	ERROR_LOG = true,
	DEBUG_LOG = false,
	SHOW_LOG_SCREEN = false,
	LOG_MAX = 20,
}

local flightPagePages = { "3k/FlightPageNew.lua", "3k/SmallFontFlightListPage.lua" }
local setupPages = { "3k/RoundSetupPage.lua", "3k/SetupPage.lua" }

local function update(widget, newOptions)
	widget.options = newOptions
end

local function telInit(widget)
	LZ_runModule(gSDCardDir .. "LAOZHU/LuaUtils.lua")
	LZ_runModule(gSDCardDir .. "LAOZHU/OTUtils.lua")
	LZ_runModule(gSDCardDir .. "LAOZHU/comm/OTSound.lua")

	if LZ_isNeedCompile() then
		widget.curPage = LZ_runModule(gSDCardDir .. "LAOZHU/uilib/comp.lua")
		return
	else
		LZ_isNeedCompile = nil
		LZ_markCompiled = nil
	end
	collectgarbage()
end

local function loadPage(widget)
	if gF3kCore == nil then
		LZ_runModule(gSDCardDir .. "LAOZHU/CfgO.lua")
		f3kCfg = CFGC:new()
		f3kCfg:readFromFile(gConfigFileName)
		gF3kCore = LZ_runModule(gSDCardDir .. "LAOZHU/3k/f3kCore.lua")
		gF3kCore.init()
	end
	local pagePath = "LAOZHU/" .. widget.pages[widget.displayIndex]
	widget.curPage = LZ_runModule(gSDCardDir .. pagePath)
end

local function unloadCurPage(widget)
	if widget.curPage and widget.curPage.destroy then
		widget.curPage.destroy()
	end
	if widget.curPage then
		LZ_clearTable(widget.curPage)
	end
	widget.curPage = nil
	collectgarbage()
end

local function background(widget)
	if gF3kCore == nil then
		return
	end
	gF3kCore.run()
end

local function refresh(widget, event, _touchState)
	local z = widget.zone
	local zoneBg = _G["COLOR_THEME_SECONDARY2"] or ERASE
	lcd.drawFilledRectangle(z.x, z.y, z.w, z.h, zoneBg)

	if not widget.loadOk then
		lcd.drawText(z.x + 2, z.y + 2, "Lz3k: LoadModule失败", LEFT + SMLSIZE)
		return
	end

	if not widget.telInitDone then
		telInit(widget)
		widget.telInitDone = true
	end

	local rawEv = event or 0
	local e = widget.keyMap[rawEv]
	local mappedEvent = rawEv
	if e ~= nil then
		mappedEvent = e
	end

	local curTime = getTime()
	if widget.curPage == nil then
		loadPage(widget)
	end

	local eventProcessed = widget.curPage.run(mappedEvent, curTime)
	if eventProcessed then
		return
	end

	if mappedEvent == EVT_EXIT_BREAK then
		if widget.pages == setupPages then
			widget.pages = flightPagePages
			widget.displayIndex = 1
			unloadCurPage(widget)
		end
		if gF3kCore == nil then
			unloadCurPage(widget)
		end
	end

	if mappedEvent == 38 then
		widget.displayIndex = widget.displayIndex - 1
		if widget.displayIndex < 1 then
			widget.displayIndex = #widget.pages
		end
		unloadCurPage(widget)
	elseif mappedEvent == 37 then
		if widget.lastEvent == 133 then
			widget.lastEvent = mappedEvent
		else
			widget.displayIndex = widget.displayIndex + 1
			if widget.displayIndex > #widget.pages then
				widget.displayIndex = 1
			end
			unloadCurPage(widget)
		end
	end

	if mappedEvent == 133 then
		widget.lastEvent = 133
		if widget.pages == flightPagePages then
			unloadCurPage(widget)
			widget.pages = setupPages
			widget.displayIndex = 1
		end
	end

	if gF3kCore ~= nil and LZ_ui then
		local rowH = LZ_ui.rowStep
		local hintY = z.y + z.h - rowH - 2
		if hintY >= z.y + 2 then
			local TXT = LZ_ui.font + LEFT + LZ_ui.themeText
			lcd.drawText(z.x + 2, hintY, "App:长按ENT交权", TXT)
		end
	end
end

local function create(zone, options)
	gSDCardDir = "/"
	gConfigFileName = "3k.cfg"
	gF3kCore = nil
	f3kCfg = nil

	local fun, err = loadScript(gSDCardDir .. "LAOZHU/uilib/LoadModule.lua", "bt")
	if not fun then
		print("[Lz3k] LoadModule FAIL:", tostring(err))
		return {
			zone = zone,
			options = options,
			keyMap = {},
			loadOk = false,
			telInitDone = false,
			displayIndex = 1,
			pages = flightPagePages,
			curPage = nil,
			lastEvent = 0,
		}
	end
	fun()

	LZ_runModule(gSDCardDir .. "LAOZHU/DBGTools/dbg.lua")
	DBG_init(DBG_OPTS)
	LZ_runModule(gSDCardDir .. "LAOZHU/DBGTools/DBGWidgetLog.lua")

	local ver0, radio0 = getVersion()
	DBG_dbg("create", "fw=" .. string.sub(tostring(ver0), 1, 8), "radio=" .. tostring(radio0), "zone", zone and zone.w or "?", zone and zone.h or "?")

	LZ_runModule(gSDCardDir .. "LAOZHU/uilib/keyMap.lua")
	local keyMap = KMgetKeyMap()
	KMunload()
	DBG_dbg("keyMap ok")

	return {
		zone = zone,
		options = options,
		keyMap = keyMap,
		loadOk = true,
		telInitDone = false,
		displayIndex = 1,
		pages = flightPagePages,
		curPage = nil,
		lastEvent = 0,
	}
end

return {
	name = name,
	options = options,
	create = create,
	update = update,
	background = background,
	refresh = refresh,
}
