-- 彩屏 Widget 版调机工具：行为对齐 SCRIPTS/TELEMETRY/adjust.lua（菜单 / 子页 / background）。
-- App 布局请用「App mode」；需先 **长按 ENTER**（或长按触摸）交权后 `event` 才非 nil。
-- 现有 LAOZHU/adjust 页面使用约 128×64 绝对坐标，建议全屏或大区域放置。

local name = "LzAdjust"

local options = {
	{ "Color", COLOR, COLOR_THEME_SECONDARY1 },
}

local DBG_OPTS = {
	printTag = "[LzAdjust]",
	ERROR_LOG = true,
	DEBUG_LOG = false,
	SHOW_LOG_SCREEN = false,
	LOG_MAX = 20,
}

local function update(widget, newOptions)
	widget.options = newOptions
end

local function telInit(widget)
	widget.adjustFramework.initFramework()
end

local function background(widget)
	if not widget.loadOk then
		return
	end
	widget.adjustFramework.background()
end

local function refresh(widget, event, _touchState)
	local z = widget.zone
	local zoneBg = _G["COLOR_THEME_SECONDARY2"] or ERASE
	lcd.drawFilledRectangle(z.x, z.y, z.w, z.h, zoneBg)

	if not widget.loadOk then
		lcd.drawText(z.x + 2, z.y + 2, "LzAdjust: LoadModule失败", LEFT + SMLSIZE)
		return
	end

	if not widget.telInitDone then
		telInit(widget)
		widget.telInitDone = true
	end

	widget.adjustFramework.run(event, { clearScreen = false })
end

local function create(zone, options)
	gSDCardDir = "/"

	local fun, err = loadScript(gSDCardDir .. "LAOZHU/uilib/LoadModule.lua", "bt")
	if not fun then
		print("[LzAdjust] LoadModule FAIL:", tostring(err))
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

	local adjustFramework = LZ_runModule(gSDCardDir .. "LAOZHU/adjust/adjustFramework.lua")

	return {
		zone = zone,
		options = options,
		loadOk = true,
		telInitDone = false,
		adjustFramework = adjustFramework,
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
