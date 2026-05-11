-- 按键调试：遥测 / Widget 共用（对齐 LAOZHU/3k/f3kFramework：仅对外 run / 薄封装）
-- 与 f3kFramework.run(rawEvent, opts) 一致：rawEvent or 0，无 Widget 专用分支；不加载 DBG / 无叠加层。
local M = {}

local keyMap

local telEventHistory = {}
local telMaxHistorySize = 12

local PAD = 2

function M.ensureKeyMap()
	if keyMap == nil then
		LZ_runModule(gSDCardDir .. "LAOZHU/uilib/keyMap.lua")
		keyMap = KMgetKeyMap()
		KMunload()
	end
	return keyMap
end

--- 环形历史；timeStr 省略时用 getTime()（单元测试可传入固定字符串）
function M.pushEventHistory(eventHistory, maxHistorySize, rawEvent, mappedEvent, timeStr)
	if timeStr == nil then
		local currentTime = getTime()
		timeStr = string.format("%02d:%02d", math.floor(currentTime / 6000) % 60, math.floor(currentTime / 100) % 60)
	end
	local eventEntry = {
		raw = rawEvent,
		mapped = mappedEvent,
		time = timeStr,
	}
	for i = maxHistorySize, 2, -1 do
		eventHistory[i] = eventHistory[i - 1]
	end
	eventHistory[1] = eventEntry
	for i = maxHistorySize + 1, #eventHistory do
		eventHistory[i] = nil
	end
end

--- 仅绘制文字（背景由 run 内清屏 / 填 zone 完成）
local function paintKeyDebug(zone, eventHistory)
	local bottomReserve = 0
	local rowH = LZ_ui.rowStep
	local TXT = LZ_ui.font + LEFT + (LZ_ui.themeText or 0)

	local ox = zone.x + PAD
	local oy = zone.y + PAD
	local headerBottom = oy + rowH * 3
	local availH = zone.y + zone.h - headerBottom - PAD - bottomReserve
	-- 比严格可容纳行数多画一行，底部可裁切（滚动区域略挤）
	local maxVis = math.max(1, math.min(11, math.floor(availH / rowH) + 1))

	local ver, radio = getVersion()
	lcd.drawText(ox, oy, "Ver:" .. string.sub(ver, 1, 4) .. " Radio:" .. radio, TXT)
	lcd.drawText(ox, oy + rowH, "ENTER:" .. tostring(EVT_ENTER_BREAK) .. " EXIT:" .. tostring(EVT_EXIT_BREAK), TXT)
	lcd.drawText(ox, oy + rowH * 2, "Raw -> Mapped  Time", TXT)

	for i = 1, math.min(#eventHistory, maxVis) do
		local entry = eventHistory[i]
		local y = headerBottom + (i - 1) * rowH
		local text = string.format("%s -> %s     %s", tostring(entry.raw), tostring(entry.mapped), entry.time)
		lcd.drawText(ox, y, text, TXT)
	end

	if #eventHistory == 0 then
		lcd.drawText(ox, headerBottom, "无记录", TXT)
	end
end

--- 与 f3kFramework.run 相同形态：opts 仅扩展绘制区域与历史表（Widget 传 zone + eventHistory；遥测省略则用默认全屏 + 模块历史）
--- opts.zone：有则只刷新该区域（先填 opts.zoneBg）；无则 lcd.clear() 后按全屏绘制
--- opts.exitOnBreak：为 true 且 mapped 为 EVT_EXIT_BREAK 时 return 2（仅遥测入口使用）
function M.run(rawEvent, opts)
	opts = opts or {}
	local raw = rawEvent or 0
	M.ensureKeyMap()

	local hist = opts.eventHistory or telEventHistory
	local maxS = opts.maxHistorySize or telMaxHistorySize

	if raw ~= 0 then
		local mapped = keyMap[raw] or raw
		M.pushEventHistory(hist, maxS, raw, mapped)
	end

	local zone
	if opts.zone ~= nil then
		local zb = opts.zoneBg or ERASE
		lcd.drawFilledRectangle(opts.zone.x, opts.zone.y, opts.zone.w, opts.zone.h, zb)
		zone = opts.zone
	else
		lcd.clear()
		zone = { x = 0, y = 0, w = LCD_W, h = LCD_H }
	end

	paintKeyDebug(zone, hist)

	if opts.exitOnBreak and raw == EVT_EXIT_BREAK then
		return 2
	end
end

function M.runTelemetry(event)
	return M.run(event, { exitOnBreak = true })
end

--- Widget create：仅挂接 zone 与独立历史表；无 DBG（与遥测能力一致）
function M.widgetCreate(zone, options)
	M.ensureKeyMap()
	return {
		zone = zone,
		options = options,
		keyMap = keyMap,
		eventHistory = {},
		maxHistorySize = telMaxHistorySize,
		loadOk = true,
		keyFramework = M,
	}
end

return M
