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

local function update(widget, newOptions)
	widget.options = newOptions
end

local function telInit(widget)
	widget.f3kNav.telInit(widget.f3kState)
end

local function loadPage(widget)
	widget.f3kNav.loadPage(widget.f3kState)
end

local function unloadCurPage(widget)
	widget.f3kNav.unloadCurPage(widget.f3kState)
end

-- Widget：不可见时只调 background，可见时只调 refresh；须两处都推进 core（与 TELEMETRY 全程 background 不同）。
local function tickF3kCore()
	if gF3kCore == nil then
		return
	end
	gF3kCore.run()
end

local function background(widget)
	tickF3kCore()
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

	local st = widget.f3kState
	local curTime = getTime()
	if st.curPage == nil then
		loadPage(widget)
	end

	tickF3kCore()

	local eventProcessed = st.curPage.run(mappedEvent, curTime)
	if eventProcessed then
		return
	end

	widget.f3kNav.handleNavAfterPage(st, mappedEvent)

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

	local Nav = LZ_runModule(gSDCardDir .. "LAOZHU/3k/f3kTelNav.lua")

	return {
		zone = zone,
		options = options,
		keyMap = keyMap,
		loadOk = true,
		telInitDone = false,
		f3kNav = Nav,
		f3kState = {
			pages = Nav.FLIGHT_PAGE_PATHS,
			displayIndex = 1,
			curPage = nil,
			lastEvent = 0,
		},
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
