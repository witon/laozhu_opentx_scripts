-- 彩屏 Widget 版 F5J：行为对齐 SCRIPTS/TELEMETRY/5jtel.lua（页面 / gF5jCore / 按键逻辑）。
-- App 布局请用「App mode」；需先 **长按 ENTER**（或长按触摸）交权后 `event` 才非 nil。
-- 现有 LAOZHU/5j 页面使用约 128×64 绝对坐标，建议全屏或大区域放置。

local name = "Lz5j"

local options = {
	{ "Color", COLOR, COLOR_THEME_SECONDARY1 },
}

local DBG_OPTS = {
	printTag = "[Lz5j]",
	ERROR_LOG = true,
	DEBUG_LOG = false,
	SHOW_LOG_SCREEN = false,
	LOG_MAX = 20,
}

local function update(widget, newOptions)
	widget.options = newOptions
end

local function telInit(widget)
	widget.f5jFramework.initFramework()
end

-- Widget：不可见时只调 background，可见时只调 refresh；须两处都推进 core（与 TELEMETRY 全程 background 不同）。
local function tickF5jCore()
	if gF5jCore == nil then
		return
	end
	gF5jCore.run()
end

local function background(widget)
	tickF5jCore()
end

local function refresh(widget, event, _touchState)
	local z = widget.zone
	local zoneBg = _G["COLOR_THEME_SECONDARY2"] or ERASE
	lcd.drawFilledRectangle(z.x, z.y, z.w, z.h, zoneBg)

	if not widget.loadOk then
		lcd.drawText(z.x + 2, z.y + 2, "Lz5j: LoadModule失败", LEFT + SMLSIZE)
		return
	end

	if not widget.telInitDone then
		telInit(widget)
		widget.telInitDone = true
	end

	widget.f5jFramework.run(event, { beforePageRun = tickF5jCore, clearScreen = false })
end

local function create(zone, options)
	gSDCardDir = "/"
	gConfigFileName = "5j.cfg"
	gFlightState = nil
	f5jCfg = nil
	gF5jCore = nil

	local fun, err = loadScript(gSDCardDir .. "LAOZHU/uilib/LoadModule.lua", "bt")
	if not fun then
		print("[Lz5j] LoadModule FAIL:", tostring(err))
		return {
			zone = zone,
			options = options,
			loadOk = false,
			telInitDone = false,
		}
	end
	fun()

	LZ_runModule(gSDCardDir .. "LAOZHU/DBGTools/dbg.lua")
	DBG_init(DBG_OPTS)
	LZ_runModule(gSDCardDir .. "LAOZHU/DBGTools/DBGLogListView.lua")

	local ver0, radio0 = getVersion()
	DBG_dbg("create", "fw=" .. string.sub(tostring(ver0), 1, 8), "radio=" .. tostring(radio0), "zone", zone and zone.w or "?", zone and zone.h or "?")

	local f5jFramework = LZ_runModule(gSDCardDir .. "LAOZHU/5j/f5jFramework.lua")

	return {
		zone = zone,
		options = options,
		loadOk = true,
		telInitDone = false,
		f5jFramework = f5jFramework,
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
