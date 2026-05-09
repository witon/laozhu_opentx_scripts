-- 彩屏 Widget 版 utO：与 SCRIPTS/TELEMETRY/utO.lua 相同的 emutest 批跑 + 跑完后的 ViewMatrix 控件演练。
-- App 布局下请用「App mode」放置本 widget；需先 **长按 ENTER**（或长按触摸）把输入交给 widget 后，`event` 才非 nil，按键才会进入 ViewMatrix。

local name = "LzUtO"

local options = {
	{ "Color", COLOR, COLOR_THEME_SECONDARY1 },
}

-- 调试：见 LAOZHU/DBGTools/dbg.lua；ERROR_LOG 控制 DBG_err，DEBUG_LOG 控制 DBG_dbg；SHOW_LOG_SCREEN 开时对应级别写入缓冲供覆盖层绘制。
local DBG_OPTS = {
	printTag = "[LzUtO]",
	ERROR_LOG = true,
	DEBUG_LOG = true,
	SHOW_LOG_SCREEN = false,
	LOG_MAX = 20,
}

local testFiles = {
	"/emutest/testCfg.lua",
	"/emutest/testCfgO.lua",
	"/emutest/testLoadModule.lua",
	"/emutest/testManagerOutput.lua",
	"/emutest/testDataFileDecode.lua",
	"/emutest/testSinkRateRecord.lua",
}

local function testLoadAndUnload()
	LZ_runModule(gSDCardDir .. "LAOZHU/uilib/InputViewO.lua")
	LZ_runModule(gSDCardDir .. "LAOZHU/uilib/TextEditO.lua")
	LZ_runModule(gSDCardDir .. "LAOZHU/uilib/ButtonO.lua")
	LZ_runModule(gSDCardDir .. "LAOZHU/uilib/CheckBoxO.lua")
	LZ_runModule(gSDCardDir .. "LAOZHU/uilib/SelectorO.lua")
	LZ_runModule(gSDCardDir .. "LAOZHU/uilib/InputSelectorO.lua")
	LZ_runModule(gSDCardDir .. "LAOZHU/uilib/Fields.lua")
	initFieldsInfo()
	FieldsUnload()
	LZ_runModule(gSDCardDir .. "LAOZHU/uilib/NumEditO.lua")
	LZ_runModule(gSDCardDir .. "LAOZHU/uilib/OutputSelectorO.lua")
	LZ_runModule(gSDCardDir .. "LAOZHU/uilib/CurveSelector.lua")
	CSunload()
	LZ_runModule(gSDCardDir .. "LAOZHU/uilib/ModeSelectorO.lua")
	LZ_runModule(gSDCardDir .. "LAOZHU/uilib/ViewMatrixO.lua")
	LZ_runModule(gSDCardDir .. "SCRIPTS/TELEMETRY/3k/TaskSelectorO.lua")
end

local function initUI(widget)
	testLoadAndUnload()
	LZ_runModule(gSDCardDir .. "LAOZHU/uilib/TextEditO.lua")
	LZ_runModule(gSDCardDir .. "LAOZHU/uilib/InputViewO.lua")
	LZ_runModule(gSDCardDir .. "LAOZHU/uilib/ButtonO.lua")
	LZ_runModule(gSDCardDir .. "LAOZHU/uilib/CheckBoxO.lua")
	LZ_runModule(gSDCardDir .. "LAOZHU/uilib/SelectorO.lua")
	LZ_runModule(gSDCardDir .. "LAOZHU/uilib/InputSelector.lua")
	LZ_runModule(gSDCardDir .. "LAOZHU/uilib/Fields.lua")
	initFieldsInfo()
	LZ_runModule(gSDCardDir .. "LAOZHU/uilib/NumEditO.lua")
	LZ_runModule(gSDCardDir .. "LAOZHU/uilib/OutputSelectorO.lua")
	LZ_runModule(gSDCardDir .. "LAOZHU/uilib/CurveSelectorO.lua")
	LZ_runModule(gSDCardDir .. "LAOZHU/uilib/ModeSelectorO.lua")
	LZ_runModule(gSDCardDir .. "LAOZHU/uilib/ViewMatrixO.lua")
	LZ_runModule(gSDCardDir .. "SCRIPTS/TELEMETRY/3k/TaskSelectorO.lua")
	LZ_runModule(gSDCardDir .. "LAOZHU/uilib/TimeEditO.lua")

	widget.viewMatrix = ViewMatrix:new()

	widget.inputSelector = InputSelector:new()
	widget.inputSelector:setFieldType(FIELDS_INPUT)
	widget.checkBox = CheckBox:new()
	widget.textEdit = TextEdit:new()
	widget.textEdit.str = "abcd"

	widget.button = Button:new()
	widget.button.text = "a bt"

	widget.numEdit = NumEdit:new()
	widget.outputSelector = OutputSelector:new()
	widget.curveSelector = CurveSelector:new()
	widget.modeSelector = ModeSelector:new()
	widget.taskSelector = TaskSelector:new()

	widget.timeEdit = TimeEdit:new()
	widget.timeEdit:setRange(0, 600)
	widget.timeEdit.step = 15

	local vm = widget.viewMatrix
	vm.matrix = {}
	vm.matrix[1] = {}
	vm.matrix[1][1] = widget.checkBox
	vm.matrix[1][2] = widget.textEdit
	vm.matrix[2] = {}
	vm.matrix[2][1] = widget.button
	vm.matrix[2][2] = widget.inputSelector
	vm.matrix[3] = {}
	vm.matrix[3][1] = widget.numEdit
	vm.matrix[3][2] = widget.outputSelector
	vm.matrix[4] = {}
	vm.matrix[4][1] = widget.modeSelector
	vm.matrix[4][2] = widget.curveSelector
	vm.matrix[5] = {}
	vm.matrix[5][1] = widget.taskSelector
	vm.matrix[6] = {}
	vm.matrix[6][1] = widget.timeEdit

	vm:updateCurIVFocus()
end

local function doOneCase(widget)
	if widget.curCaseIndex > #widget.curCases then
		widget.curFileIndex = widget.curFileIndex + 1
		if widget.curFileIndex > #testFiles then
			return false
		end
		widget.curCaseIndex = 1
		local testFile = testFiles[widget.curFileIndex]
		widget.curCases = LZ_runModule(gSDCardDir .. "SCRIPTS" .. testFile)
		if widget.dbgEnabled then
			if widget.curCases == nil then
				DBG_err("emutest", "load test file failed", testFile)
			end
			DBG_dbg("emutest", "file " .. tostring(widget.curFileIndex) .. "/" .. tostring(#testFiles), testFile)
		end
	end
	widget.curCases[widget.curCaseIndex]()
	widget.curCaseIndex = widget.curCaseIndex + 1
	return true
end

local function update(widget, newOptions)
	widget.options = newOptions
end

local function background(widget)
end

local function refresh(widget, event, touchState)
	local z = widget.zone
	local ox = z.x
	local oy = z.y
	local zoneBg = _G["COLOR_THEME_SECONDARY2"] or ERASE
	lcd.drawFilledRectangle(z.x, z.y, z.w, z.h, zoneBg)

	local TXT = LZ_ui.font + LEFT + LZ_ui.themeText

	local rowH = LZ_ui.rowStep
	local logLinesTop = oy + rowH
	local logHintY = z.y + z.h - rowH - 2
	if logHintY < logLinesTop + rowH then
		logHintY = logLinesTop + rowH
	end
	local logAvailH = logHintY - logLinesTop - 2
	local maxVisLog = math.max(1, math.floor(logAvailH / rowH))

	if widget.curFileIndex <= #testFiles then
		doOneCase(widget)
		if widget.curFileIndex > #testFiles then
			if widget.dbgEnabled then
				DBG_dbg("emutest OK")
			end
			lcd.drawText(ox + 2, oy + 2, "emutest OK", TXT)
			return
		end
		local fn = testFiles[widget.curFileIndex] or "?"
		lcd.drawText(ox + 2, oy + 2, "emutest", TXT)
		lcd.drawText(ox + 2, oy + 2 + rowH, "f " .. tostring(widget.curFileIndex) .. "/" .. tostring(#testFiles), TXT)
		lcd.drawText(ox + 2, oy + 2 + 2 * rowH, string.sub(tostring(fn), 1, 28), TXT)
		lcd.drawText(ox + 2, oy + 2 + 3 * rowH, "c " .. tostring(widget.curCaseIndex), TXT)
		return
	end

	local invers = false
	if getRtcTime() % 2 == 1 then
		invers = true
	end

	if widget.viewMatrix == nil then
		initUI(widget)
	end

	widget._dbgN = (widget._dbgN or 0) + 1
	local rawEv = event or 0
	if widget.dbgEnabled then
		if event ~= nil and rawEv ~= 0 then
			local m = widget.keyMap[event]
			DBG_dbg("KEY", "raw=" .. tostring(rawEv), "mapped=" .. tostring(m or rawEv), "hasMap=" .. tostring(m ~= nil))
		elseif widget._dbgN % 120 == 1 then
			DBG_dbg(string.format("refresh#%d evt=nil (未交权给 widget)", widget._dbgN))
		end
	end

	local ev = rawEv
	local e = widget.keyMap[ev]
	if e ~= nil then
		ev = e
	end

	if widget.dbgEnabled and event ~= nil and event ~= 0 then
		local mappedEvent = widget.keyMap[event] or event
		DBG_logOnMappedKey(mappedEvent)
	end

	widget.viewMatrix:doKey(ev)

	local rs = rowH
	local midGap = 6
	local leftEnd = math.floor((z.w - midGap) / 2)
	local rightStart = leftEnd + midGap
	local pad = 1
	local leftLbl = ox + pad
	local leftCtlR = ox + leftEnd - pad
	local rightLbl = ox + rightStart
	local rightCtlR = ox + z.w - pad

	lcd.drawText(leftLbl, oy + 1, "CheckBox:", LZ_ui.font + LEFT)
	widget.checkBox:draw(leftCtlR, oy + 1, invers, LZ_ui.font + RIGHT)
	lcd.drawText(rightLbl, oy + 1, "TextEdit:", LZ_ui.font + LEFT)
	widget.textEdit:draw(rightCtlR, oy + 1, invers, LZ_ui.font + RIGHT)

	lcd.drawText(leftLbl, oy + rs + 1, "Button:", LZ_ui.font + LEFT)
	widget.button:draw(leftCtlR, oy + rs + 1, invers, LZ_ui.font + RIGHT)

	lcd.drawText(rightLbl, oy + rs + 1, "ipselect:", LZ_ui.font + LEFT)
	widget.inputSelector:draw(rightCtlR, oy + rs + 1, invers, LZ_ui.font + RIGHT)

	lcd.drawText(leftLbl, oy + 2 * rs + 1, "NumEdit:", LZ_ui.font + LEFT)
	widget.numEdit:draw(leftCtlR, oy + 2 * rs + 1, invers, LZ_ui.font + RIGHT)

	lcd.drawText(rightLbl, oy + 2 * rs + 1, "opselect:", LZ_ui.font + LEFT)
	widget.outputSelector:draw(rightCtlR, oy + 2 * rs + 1, invers, LZ_ui.font + RIGHT)

	lcd.drawText(rightLbl, oy + 3 * rs + 1, "csselect:", LZ_ui.font + LEFT)
	widget.curveSelector:draw(rightCtlR, oy + 3 * rs + 1, invers, LZ_ui.font + RIGHT)

	lcd.drawText(leftLbl, oy + 3 * rs + 1, "mdselect:", LZ_ui.font + LEFT)
	widget.modeSelector:draw(leftCtlR, oy + 3 * rs + 1, invers, LZ_ui.font + RIGHT)

	lcd.drawText(leftLbl, oy + 4 * rs + 1, "tsselect:", LZ_ui.font + LEFT)
	widget.taskSelector:draw(rightCtlR, oy + 4 * rs + 1, invers, LZ_ui.font + RIGHT)

	lcd.drawText(leftLbl, oy + 5 * rs + 1, "timeedit:", LZ_ui.font + LEFT)
	widget.timeEdit:draw(rightCtlR, oy + 5 * rs + 1, invers, LZ_ui.font + RIGHT)

	local hintY = z.y + z.h - rs - 2
	if hintY >= oy + 5 * rs + 12 then
		lcd.drawText(ox + 2, hintY, "App:长按ENT交权", TXT)
	end

	if widget.dbgEnabled then
		DBG_logClampScroll(maxVisLog)
		DBGW_drawLogOverlay(z, zoneBg, TXT, "App:长按ENT交权 ↑/↓滚动")
	end
end

local function create(zone, options)
	gSDCardDir = "/"
	gAssertFlag = "ASSERT FLAG!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"

	local fun, err = loadScript(gSDCardDir .. "LAOZHU/uilib/LoadModule.lua", "bt")
	if fun then
		fun()
		LZ_runModule(gSDCardDir .. "LAOZHU/DBGTools/dbg.lua")
		DBG_init(DBG_OPTS)
		LZ_runModule(gSDCardDir .. "LAOZHU/DBGTools/DBGWidgetLog.lua")
		local ver0, radio0 = getVersion()
		DBG_dbg("create", "fw=" .. string.sub(tostring(ver0), 1, 8), "radio=" .. tostring(radio0), "zone", zone and zone.w or "?", zone and zone.h or "?")
		DBG_dbg("LoadModule ok")
	else
		print("[LzUtO] LoadModule FAIL:", tostring(err))
	end

	local curCases = LZ_runModule(gSDCardDir .. "SCRIPTS" .. testFiles[1])
	if fun then
		DBG_dbg("emutest", "file 1/" .. tostring(#testFiles), testFiles[1])
		if curCases == nil then
			DBG_err("emutest", "first file load failed", testFiles[1])
		end
	end
	LZ_runModule(gSDCardDir .. "LAOZHU/EmuTestUtils.lua")
	LZ_runModule(gSDCardDir .. "LAOZHU/OTUtils.lua")

	LZ_runModule(gSDCardDir .. "LAOZHU/uilib/keyMap.lua")
	local keyMap = KMgetKeyMap()
	KMunload()
	if fun then
		DBG_dbg("keyMap ok")
	end

	local dbgEnabled = fun ~= nil
	return {
		zone = zone,
		options = options,
		keyMap = keyMap,
		curFileIndex = 1,
		curCaseIndex = 1,
		curCases = curCases,
		viewMatrix = nil,
		dbgEnabled = dbgEnabled,
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
