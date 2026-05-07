local name = "LzKey"

local options = {
	{ "Color", COLOR, COLOR_THEME_SECONDARY1 },
}

-- 主界面请用「App mode」布局放置本 widget；需先 **长按 ENTER**（或长按触摸）把输入交给 widget 后，`event` 才非 nil，按键才会进历史。
-- USB 调试口 / 模拟器控制台看 print；不用时改 false。
local DEBUG_LOG = true

local function dbg(...)
	if DEBUG_LOG then
		print("[LzKey]", ...)
	end
end

local function touchBrief(ts)
	if ts == nil then
		return "-"
	end
	local x = ts.x or ts.X
	local y = ts.y or ts.Y
	if x ~= nil and y ~= nil then
		local sw = ""
		if ts.swipe ~= nil then
			sw = " sw=" .. tostring(ts.swipe)
		end
		return string.format("xy=%s,%s%s", tostring(x), tostring(y), sw)
	end
	return "touch=" .. tostring(ts)
end

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

	dbg(string.format("history+1 raw=%s map=%s n=%s", tostring(rawEvent), tostring(mappedEvent), tostring(#widget.eventHistory)))
end

local function create(zone, options)
	gScriptDir = "/SCRIPTS/"

	local ver0, radio0 = getVersion()
	dbg("create", "fw=" .. string.sub(tostring(ver0), 1, 8), "radio=" .. tostring(radio0), "zone", zone and zone.w or "?", zone and zone.h or "?")

	local fun, err = loadScript(gScriptDir .. "TELEMETRY/common/LoadModule.lua", "bt")
	if fun then
		fun()
		dbg("LoadModule ok")
	else
		dbg("LoadModule FAIL:", tostring(err))
	end

	LZ_runModule("TELEMETRY/common/keyMap.lua")
	local keyMap = KMgetKeyMap()
	KMunload()
	dbg("keyMap ok")

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
	local TXT = SMLSIZE + LEFT + COLOR_THEME_PRIMARY1
	local rowH = 14
	local ox = z.x + 2
	local oy = z.y + 2

	widget._dbgN = (widget._dbgN or 0) + 1
	if DEBUG_LOG then
		local evtStr = event == nil and "nil" or tostring(event)
		if event ~= nil then
			if event ~= 0 or (widget._dbgN % 45 == 1) then
				dbg(
					string.format(
						"refresh#%d evt=%s hist=%d touch=%s",
						widget._dbgN,
						evtStr,
						#widget.eventHistory,
						touchBrief(touchState)
					)
				)
			end
			if event ~= 0 then
				local m = widget.keyMap[event]
				dbg("KEY", "raw=" .. tostring(event), "mapped=" .. tostring(m or event), "hasMap=" .. tostring(m ~= nil))
			end
		elseif widget._dbgN % 120 == 1 then
			dbg(string.format("refresh#%d evt=nil (未交权给 widget)", widget._dbgN))
		end
	end

	-- 仅刷新本 widget 区域，不用全屏 lcd.clear()
	local zoneBg = _G["COLOR_THEME_SECONDARY2"] or ERASE
	lcd.drawFilledRectangle(z.x, z.y, z.w, z.h, zoneBg)

	local ver, radio = getVersion()
	lcd.drawText(ox, oy, "Ver:" .. string.sub(ver, 1, 4) .. " " .. radio, TXT)

	lcd.drawText(ox, oy + rowH, "ENT/EXT " .. tostring(EVT_ENTER_BREAK) .. "/" .. tostring(EVT_EXIT_BREAK), TXT)

	if event ~= nil and event ~= 0 then
		local mappedEvent = widget.keyMap[event] or event
		addEventToHistory(widget, event, mappedEvent)
	end

	local headerColor = COLOR_THEME_SECONDARY1
	if widget.options and widget.options.Color ~= nil then
		headerColor = widget.options.Color
	end
	lcd.setColor(CUSTOM_COLOR, headerColor)
	lcd.drawText(ox, oy + rowH * 2, "Raw->Map T", SMLSIZE + LEFT + CUSTOM_COLOR)

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
end

return {
	name = name,
	options = options,
	create = create,
	update = update,
	background = background,
	refresh = refresh,
}
