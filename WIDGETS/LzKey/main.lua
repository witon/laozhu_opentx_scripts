-- 彩屏 Widget 版按键调试：与 SCRIPTS/TELEMETRY/key.lua 共用 M.run（仅多传 zone / 实例历史表）。
-- App 布局请用「App mode」；需先 **长按 ENTER**（或长按触摸）交权后 `event` 才非 nil。
local name = "LzKey"

local options = {}

local function update(widget, newOptions)
	widget.options = newOptions
end

local function create(zone, options)
	gSDCardDir = "/"
	local fun, err = loadScript(gSDCardDir .. "LAOZHU/uilib/LoadModule.lua", "bt")
	if not fun then
		print("[LzKey] LoadModule FAIL:", tostring(err))
		return {
			zone = zone,
			options = options,
			keyMap = {},
			eventHistory = {},
			maxHistorySize = 12,
			loadOk = false,
		}
	end
	fun()
	local keyFramework = LZ_runModule(gSDCardDir .. "LAOZHU/key/keyFramework.lua")
	return keyFramework.widgetCreate(zone, options)
end

local function background(widget)
end

local function refresh(widget, event, touchState)
	local z = widget.zone
	if not widget.loadOk then
		lcd.drawFilledRectangle(z.x, z.y, z.w, z.h, _G["COLOR_THEME_SECONDARY2"] or ERASE)
		lcd.drawText(z.x + 2, z.y + 2, "LzKey: LoadModule failed", LEFT + SMLSIZE)
		return
	end
	widget.keyFramework.run(event, {
		eventHistory = widget.eventHistory,
		maxHistorySize = widget.maxHistorySize,
		zone = widget.zone,
		zoneBg = _G["COLOR_THEME_SECONDARY2"] or ERASE,
		touchState = touchState,
	})
end

return {
	name = name,
	options = options,
	create = create,
	update = update,
	background = background,
	refresh = refresh,
}
