-- 按键映射配置向导：基础五键 5 秒捕获 → 可导航主界面 → 扩展五键捕获。持久化经 CFGC（CfgO）写 SCRIPTS/keymap.cfg。
local M = {}

local KEYMAP_CFG_FILE = "keymap.cfg"
local CAPTURE_TICKS = 500

local BASIC_STEPS = {
	{ 36, "Up" },
	{ 35, "Down" },
	{ 38, "Left" },
	{ 37, "Right" },
	{ nil, "Back" },
}

local EXT_STEPS = {
	{ 68, "Long+Up" },
	{ 67, "Long+Dn" },
	{ 70, "Long+Lt" },
	{ 69, "Long+Rt" },
}

local WIZARD_CANONS = {}
for _, step in ipairs(BASIC_STEPS) do
	WIZARD_CANONS[#WIZARD_CANONS + 1] = step[1] or EVT_EXIT_BREAK
end
for _, step in ipairs(EXT_STEPS) do
	WIZARD_CANONS[#WIZARD_CANONS + 1] = step[1]
end

local phase
local basicIdx
local capDeadline
local lastRaw
local sessionBindings
local baseKeyAtEnter
local viewMatrix
local extPickIdx

local function loadBindingsFromFile()
	LZ_runModule(gSDCardDir .. "LAOZHU/CfgO.lua")
	local cfg = CFGC:new()
	local ok = cfg:readFromFile(KEYMAP_CFG_FILE)
	local t = {}
	if ok then
		for ks, v in pairs(cfg.kvs) do
			local c = tonumber(ks)
			if c ~= nil and type(v) == "number" then
				t[c] = v
			end
		end
	end
	return t
end

local function persistWizardBindings(bindings)
	LZ_runModule(gSDCardDir .. "LAOZHU/CfgO.lua")
	local cfg = CFGC:new()
	cfg:readFromFile(KEYMAP_CFG_FILE)
	for i = 1, #WIZARD_CANONS do
		local canon = WIZARD_CANONS[i]
		local raw = bindings[canon]
		if raw == nil then
			cfg.kvs[tostring(canon)] = nil
		else
			cfg.kvs[tostring(canon)] = raw
		end
	end
	cfg:writeToFile(KEYMAP_CFG_FILE)
end

local function startCaptureWindow()
	capDeadline = getTime() + CAPTURE_TICKS
	lastRaw = nil
end

local function mapSetupEvent(raw)
	if raw == nil or raw == 0 then
		return 0
	end
	for canon, r in pairs(sessionBindings) do
		if r == raw then
			return canon
		end
	end
	return baseKeyAtEnter[raw] or raw
end

local function clearViewMatrix()
	if viewMatrix ~= nil then
		viewMatrix = nil
	end
end

local function onExtButtonClick(idx)
	extPickIdx = idx
	phase = "ext_cap"
	startCaptureWindow()
end

local EXT_COLS = 2

local function onMainExtClick()
	clearViewMatrix()
	phase = "ext"
	local vm = ViewMatrix:new()
	viewMatrix = vm
	local n = #EXT_STEPS
	local i = 1
	while i <= n do
		local row = vm:addRow()
		local j1 = i
		local b1 = Button:new()
		b1.extKeyCanon = EXT_STEPS[j1][1]
		b1.extBaseLabel = EXT_STEPS[j1][2]
		b1.text = b1.extBaseLabel .. " :-"
		b1:setOnClick(function()
			onExtButtonClick(j1)
		end)
		row[1] = b1
		i = i + 1
		if i <= n then
			local j2 = i
			local b2 = Button:new()
			b2.extKeyCanon = EXT_STEPS[j2][1]
			b2.extBaseLabel = EXT_STEPS[j2][2]
			b2.text = b2.extBaseLabel .. " :-"
			b2:setOnClick(function()
				onExtButtonClick(j2)
			end)
			row[2] = b2
			i = i + 1
		end
	end
	vm:updateCurIVFocus()
end

local function buildMainView()
	clearViewMatrix()
	local vm = ViewMatrix:new()
	viewMatrix = vm
	local row = vm:addRow()
	local b = Button:new()
	b.text = "Ext Keys"
	b:setOnClick(onMainExtClick)
	row[1] = b
	vm:updateCurIVFocus()
end

local function drawHeader(zone, title)
	local ox = zone.x + 2
	local oy = zone.y + 2
	local TXT = LZ_ui.font + LEFT + (LZ_ui.themeText or 0)
	lcd.drawText(ox, oy, title, TXT)
	return oy + LZ_ui.rowStep + 2
end

local function paintBasicCap(zone)
	local step = BASIC_STEPS[basicIdx]
	if step == nil then
		return
	end
	local canon = step[1]
	if canon == nil then
		canon = EVT_EXIT_BREAK
	end
	local label = step[2]
	local oy0 = drawHeader(zone, "Key Map 1/2")
	local TXT = LZ_ui.font + LEFT + (LZ_ui.themeText or 0)
	local ox = zone.x + 2
	local remain = capDeadline - getTime()
	if remain < 0 then
		remain = 0
	end
	lcd.drawText(ox, oy0, "Press: " .. label .. " (" .. tostring(canon) .. ")", TXT)
	lcd.drawText(ox, oy0 + LZ_ui.rowStep, "Last key in 5s wins  T-" .. tostring(math.floor(remain / 100)) .. "." .. tostring(math.floor((remain % 100) / 10)), TXT)
	if lastRaw ~= nil then
		local mapped = mapSetupEvent(lastRaw)
		lcd.drawText(ox, oy0 + LZ_ui.rowStep * 2, tostring(lastRaw) .. " -> " .. tostring(mapped), TXT)
	end
end

local function paintExtCap(zone)
	local step = EXT_STEPS[extPickIdx]
	local canon = step[1]
	local label = step[2]
	local oy0 = drawHeader(zone, "Key Map Ext")
	local TXT = LZ_ui.font + LEFT + (LZ_ui.themeText or 0)
	local ox = zone.x + 2
	local remain = capDeadline - getTime()
	if remain < 0 then
		remain = 0
	end
	lcd.drawText(ox, oy0, "Press: " .. label .. " (" .. tostring(canon) .. ")", TXT)
	lcd.drawText(ox, oy0 + LZ_ui.rowStep, "Last key in 5s wins", TXT)
	lcd.drawText(ox, oy0 + LZ_ui.rowStep * 2, "T-" .. tostring(math.floor(remain / 100)) .. "." .. tostring(math.floor((remain % 100) / 10)), TXT)
	if lastRaw ~= nil then
		local mapped = mapSetupEvent(lastRaw)
		lcd.drawText(ox, oy0 + LZ_ui.rowStep * 3, tostring(lastRaw) .. " -> " .. tostring(mapped), TXT)
	end
end

local function paintMain(zone)
	local TXT = LZ_ui.font + LEFT + (LZ_ui.themeText or 0)
	local rs = LZ_ui.rowStep
	local oy0 = drawHeader(zone, "Key Map")
	for i = 1, #BASIC_STEPS do
		local step = BASIC_STEPS[i]
		local canon = step[1]
		if canon == nil then
			canon = EVT_EXIT_BREAK
		end
		local label = step[2]
		local r = sessionBindings ~= nil and sessionBindings[canon] or nil
		lcd.drawText(zone.x + 2, oy0 + (i - 1) * rs, label .. " :" .. (r ~= nil and tostring(r) or "-"), TXT)
	end
	local invers = math.floor(getTime() / 100) % 2 == 0
	local vm = viewMatrix
	if vm == nil or vm:isEmpty() then
		lcd.drawText(zone.x + 2, zone.y + zone.h - rs - 2, "EXIT: leave", TXT)
		return
	end
	local y = oy0
	for ri = 1, #vm.matrix do
		local row = vm.matrix[ri]
		for ci = 1, #row do
			local iv = row[ci]
			iv:draw(zone.x + zone.w - 4, y, invers, LZ_ui.font + RIGHT + (LZ_ui.themeText or 0))
		end
		y = y + rs
	end
	lcd.drawText(zone.x + 2, zone.y + zone.h - rs - 2, "EXIT: leave", TXT)
end

local function paintExt(zone)
	local oy0 = drawHeader(zone, "Ext Keys")
	local invers = math.floor(getTime() / 100) % 2 == 0
	local y = oy0
	local vm = viewMatrix
	if vm == nil or vm:isEmpty() then
		return
	end
	local colW = math.floor((zone.w - 4) / EXT_COLS)
	for ri = 1, #vm.matrix do
		local row = vm.matrix[ri]
		for ci = 1, #row do
			local iv = row[ci]
			if iv.extKeyCanon ~= nil and iv.extBaseLabel ~= nil and sessionBindings ~= nil then
				local r = sessionBindings[iv.extKeyCanon]
				iv.text = iv.extBaseLabel .. " :" .. (r ~= nil and tostring(r) or "-")
			end
			local x = zone.x + 2 + (ci - 1) * colW
			iv:draw(x, y, invers, LZ_ui.font + LEFT + (LZ_ui.themeText or 0))
		end
		y = y + LZ_ui.rowStep
	end
	lcd.drawText(zone.x + 2, zone.y + zone.h - LZ_ui.rowStep - 2, "EXIT: back", LZ_ui.font + LEFT + (LZ_ui.themeText or 0))
end

local function tickBasicCap(raw)
	if raw ~= nil and raw ~= 0 then
		lastRaw = raw
	end
	if getTime() < capDeadline then
		return nil
	end
	if lastRaw ~= nil then
		local canon = BASIC_STEPS[basicIdx][1]
		if canon == nil then
			canon = EVT_EXIT_BREAK
		end
		sessionBindings[canon] = lastRaw
		persistWizardBindings(sessionBindings)
		basicIdx = basicIdx + 1
		if basicIdx > #BASIC_STEPS then
			phase = "main"
			buildMainView()
		else
			startCaptureWindow()
		end
	else
		local c = BASIC_STEPS[basicIdx][1]
		if c == nil then
			c = EVT_EXIT_BREAK
		end
		sessionBindings[c] = nil
		persistWizardBindings(sessionBindings)
		basicIdx = basicIdx + 1
		if basicIdx > #BASIC_STEPS then
			phase = "main"
			buildMainView()
		else
			startCaptureWindow()
		end
	end
	return nil
end

local function tickExtCap(raw)
	if raw ~= nil and raw ~= 0 then
		lastRaw = raw
	end
	if getTime() < capDeadline then
		return nil
	end
	if lastRaw ~= nil then
		local step = EXT_STEPS[extPickIdx]
		sessionBindings[step[1]] = lastRaw
		persistWizardBindings(sessionBindings)
		phase = "ext"
		onMainExtClick()
	else
		local step = EXT_STEPS[extPickIdx]
		sessionBindings[step[1]] = nil
		persistWizardBindings(sessionBindings)
		phase = "ext"
		onMainExtClick()
	end
	return nil
end

function M.enter()
	LZ_runModule(gSDCardDir .. "LAOZHU/uilib/ViewMatrixO.lua")
	LZ_runModule(gSDCardDir .. "LAOZHU/uilib/InputViewO.lua")
	LZ_runModule(gSDCardDir .. "LAOZHU/uilib/ButtonO.lua")
	if KMgetKeyMap == nil then
		LZ_runModule(gSDCardDir .. "LAOZHU/uilib/keyMap.lua")
	end
	sessionBindings = loadBindingsFromFile()
	local km = KMgetKeyMap()
	baseKeyAtEnter = {}
	for k, v in pairs(km) do
		baseKeyAtEnter[k] = v
	end
	phase = "basic_cap"
	basicIdx = 1
	clearViewMatrix()
	startCaptureWindow()
end

--- rawEvent：硬件 event；zone：绘制区；返回 "exit" 退出向导回到调试页
function M.run(rawEvent, zone)
	zone = zone or { x = 0, y = 0, w = LCD_W, h = LCD_H }
	if phase == "basic_cap" then
		tickBasicCap(rawEvent)
		if phase == "basic_cap" then
			paintBasicCap(zone)
		else
			paintMain(zone)
		end
		return nil
	end
	if phase == "ext_cap" then
		tickExtCap(rawEvent)
		if phase == "ext_cap" then
			paintExtCap(zone)
		else
			paintExt(zone)
		end
		return nil
	end
	local mapped = mapSetupEvent(rawEvent)
	if phase == "main" then
		if mapped == EVT_EXIT_BREAK then
			return "exit"
		end
		if viewMatrix then
			viewMatrix:doKey(mapped)
		end
		paintMain(zone)
		return nil
	end
	if phase == "ext" then
		if mapped == EVT_EXIT_BREAK then
			phase = "main"
			buildMainView()
		elseif viewMatrix then
			viewMatrix:doKey(mapped)
		end
		if phase == "ext" then
			paintExt(zone)
		else
			paintMain(zone)
		end
		return nil
	end
	return nil
end

function M.destroy()
	clearViewMatrix()
	ViewMatrix = nil
	Button = nil
	InputView = nil
	phase = nil
	sessionBindings = nil
	baseKeyAtEnter = nil
end

return M
