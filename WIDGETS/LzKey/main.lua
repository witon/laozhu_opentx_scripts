local name = "LzKey"

local options = {
	{ "Color", COLOR, COLOR_THEME_SECONDARY1 },
}

-- 主界面请用「App mode」布局放置本 widget；需先 **长按 ENTER**（或长按触摸）把输入交给 widget 后，`event` 才非 nil，按键才会进历史。
-- 调试：见 LAOZHU/DBGTools/dbg.lua；ERROR_LOG 控制 DBG_err，DEBUG_LOG 控制 DBG_dbg；SHOW_LOG_SCREEN 开时对应级别写入缓冲供覆盖层绘制。
local DBG_OPTS = {
	printTag = "[LzKey]",
	ERROR_LOG = true,
	DEBUG_LOG = true,
	SHOW_LOG_SCREEN = false,
	LOG_MAX = 20,
}



local function update(widget, newOptions)
	widget.options = newOptions
end

local function addEventToHistory(widget, rawEvent, mappedEvent)
	local currentTime = getTime()
	local timeStr = string.format("%02d:%02d", math.floor(currentTime / 6000) % 60, math.floor(currentTime / 100) % 60)

	local eventEntry = {
		raw = rawEvent,
		mapped = mappedEvent,
		time = timeStr,
	}

	for i = widget.maxHistorySize, 2, -1 do
		widget.eventHistory[i] = widget.eventHistory[i - 1]
	end
	widget.eventHistory[1] = eventEntry

	for i = widget.maxHistorySize + 1, #widget.eventHistory do
		widget.eventHistory[i] = nil
	end

	DBG_dbg(string.format("history+1 raw=%s map=%s n=%s", tostring(rawEvent), tostring(mappedEvent), tostring(#widget.eventHistory)))
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
		}
	end
	fun()

	LZ_runModule(gSDCardDir .. "LAOZHU/DBGTools/dbg.lua")
	DBG_init(DBG_OPTS)
	LZ_runModule(gSDCardDir .. "LAOZHU/DBGTools/DBGWidgetLog.lua")

	local ver0, radio0 = getVersion()
	DBG_dbg("create", "fw=" .. string.sub(tostring(ver0), 1, 8), "radio=" .. tostring(radio0), "zone", zone and zone.w or "?", zone and zone.h or "?")
	DBG_dbg("LoadModule ok")

	LZ_runModule(gSDCardDir .. "LAOZHU/uilib/keyMap.lua")
	local keyMap = KMgetKeyMap()
	KMunload()
	DBG_dbg("keyMap ok")

	return {
		zone = zone,
		options = options,
		keyMap = keyMap,
		eventHistory = {},
		maxHistorySize = 12,
	}
end

local function background(widget)
end

local function refresh(widget, event, touchState)
	local z = widget.zone
	local TXT = LZ_ui.font + LEFT + LZ_ui.themeText
	local rowH = LZ_ui.rowStep
	local ox = z.x + 2
	local oy = z.y + 2

	local logLinesTop = oy + rowH
	local logHintY = z.y + z.h - rowH - 2
	if logHintY < logLinesTop + rowH then
		logHintY = logLinesTop + rowH
	end
	local logAvailH = logHintY - logLinesTop - 2
	local maxVisLog = math.max(1, math.floor(logAvailH / rowH))

	widget._dbgN = (widget._dbgN or 0) + 1
	if event ~= nil then
		if event ~= 0 then
			local m = widget.keyMap[event]
			DBG_dbg("KEY", "raw=" .. tostring(event), "mapped=" .. tostring(m or event), "hasMap=" .. tostring(m ~= nil))
		end
	elseif widget._dbgN % 120 == 1 then
		DBG_dbg(string.format("refresh#%d evt=nil (未交权给 widget)", widget._dbgN))
	end

	-- 仅刷新本 widget 区域，不用全屏 lcd.clear()
	local zoneBg = _G["COLOR_THEME_SECONDARY2"] or ERASE
	lcd.drawFilledRectangle(z.x, z.y, z.w, z.h, zoneBg)

	local ver, radio = getVersion()
	lcd.drawText(ox, oy, "Ver:" .. string.sub(ver, 1, 4) .. " " .. radio, TXT)

	lcd.drawText(ox, oy + rowH, "ENT/EXT " .. tostring(EVT_ENTER_BREAK) .. "/" .. tostring(EVT_EXIT_BREAK), TXT)

	if event ~= nil and event ~= 0 then
		local mappedEvent = widget.keyMap[event] or event
		DBG_logOnMappedKey(mappedEvent)
		addEventToHistory(widget, event, mappedEvent)
	end

	DBG_logClampScroll(maxVisLog)

	local headerColor = COLOR_THEME_SECONDARY1
	if widget.options and widget.options.Color ~= nil then
		headerColor = widget.options.Color
	end
	lcd.setColor(CUSTOM_COLOR, headerColor)
	lcd.drawText(ox, oy + rowH * 2, "Raw->Map T", LZ_ui.font + LEFT + CUSTOM_COLOR)

	local headerBottom = oy + rowH * 3
	local hintY = z.y + z.h - rowH - 2
	if hintY < headerBottom + rowH then
		hintY = headerBottom + rowH
	end
	local availH = hintY - headerBottom - 2
	local maxVis = math.max(1, math.min(10, math.floor(availH / rowH)))

	for i = 1, math.min(#widget.eventHistory, maxVis) do
		local entry = widget.eventHistory[i]
		local y = headerBottom + (i - 1) * rowH
		local text = string.format("%s %s %s", tostring(entry.raw), tostring(entry.mapped), entry.time)
		lcd.drawText(ox, y, text, TXT)
	end

	if #widget.eventHistory == 0 then
		lcd.drawText(ox, headerBottom, "无记录", TXT)
	end

	lcd.drawText(ox, hintY, "App:长按ENT交权", TXT)

	DBGW_drawLogOverlay(z, zoneBg, TXT)
end

return {
	name = name,
	options = options,
	create = create,
	update = update,
	background = background,
	refresh = refresh,
}
