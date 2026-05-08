-- 彩屏 Widget 版 utO：与 SCRIPTS/TELEMETRY/utO.lua 相同的 emutest 批跑 + 跑完后的 ViewMatrix 控件演练。
-- App 布局下请用「App mode」放置本 widget；需先 **长按 ENTER**（或长按触摸）把输入交给 widget 后，`event` 才非 nil，按键才会进入 ViewMatrix。

local name = "LzUtO"

local options = {
	{ "Color", COLOR, COLOR_THEME_SECONDARY1 },
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
	LZ_runModule(gSDCardDir .. "SCRIPTS/TELEMETRY/common/InputViewO.lua")
	LZ_runModule(gSDCardDir .. "SCRIPTS/TELEMETRY/common/TextEditO.lua")
	LZ_runModule(gSDCardDir .. "SCRIPTS/TELEMETRY/common/ButtonO.lua")
	LZ_runModule(gSDCardDir .. "SCRIPTS/TELEMETRY/common/CheckBoxO.lua")
	LZ_runModule(gSDCardDir .. "SCRIPTS/TELEMETRY/common/SelectorO.lua")
	LZ_runModule(gSDCardDir .. "SCRIPTS/TELEMETRY/common/InputSelectorO.lua")
	LZ_runModule(gSDCardDir .. "SCRIPTS/TELEMETRY/common/Fields.lua")
	initFieldsInfo()
	FieldsUnload()
	LZ_runModule(gSDCardDir .. "SCRIPTS/TELEMETRY/common/NumEditO.lua")
	LZ_runModule(gSDCardDir .. "SCRIPTS/TELEMETRY/common/OutputSelectorO.lua")
	LZ_runModule(gSDCardDir .. "SCRIPTS/TELEMETRY/common/CurveSelector.lua")
	CSunload()
	LZ_runModule(gSDCardDir .. "SCRIPTS/TELEMETRY/common/ModeSelectorO.lua")
	LZ_runModule(gSDCardDir .. "SCRIPTS/TELEMETRY/common/ViewMatrixO.lua")
	LZ_runModule(gSDCardDir .. "SCRIPTS/TELEMETRY/3k/TaskSelectorO.lua")
end

local function initUI(widget)
	testLoadAndUnload()
	LZ_runModule(gSDCardDir .. "SCRIPTS/TELEMETRY/common/TextEditO.lua")
	LZ_runModule(gSDCardDir .. "SCRIPTS/TELEMETRY/common/InputViewO.lua")
	LZ_runModule(gSDCardDir .. "SCRIPTS/TELEMETRY/common/ButtonO.lua")
	LZ_runModule(gSDCardDir .. "SCRIPTS/TELEMETRY/common/CheckBoxO.lua")
	LZ_runModule(gSDCardDir .. "SCRIPTS/TELEMETRY/common/SelectorO.lua")
	LZ_runModule(gSDCardDir .. "SCRIPTS/TELEMETRY/common/InputSelector.lua")
	LZ_runModule(gSDCardDir .. "SCRIPTS/TELEMETRY/common/Fields.lua")
	initFieldsInfo()
	LZ_runModule(gSDCardDir .. "SCRIPTS/TELEMETRY/common/NumEditO.lua")
	LZ_runModule(gSDCardDir .. "SCRIPTS/TELEMETRY/common/OutputSelectorO.lua")
	LZ_runModule(gSDCardDir .. "SCRIPTS/TELEMETRY/common/CurveSelectorO.lua")
	LZ_runModule(gSDCardDir .. "SCRIPTS/TELEMETRY/common/ModeSelectorO.lua")
	LZ_runModule(gSDCardDir .. "SCRIPTS/TELEMETRY/common/ViewMatrixO.lua")
	LZ_runModule(gSDCardDir .. "SCRIPTS/TELEMETRY/3k/TaskSelectorO.lua")
	LZ_runModule(gSDCardDir .. "SCRIPTS/TELEMETRY/common/TimeEditO.lua")

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

	local TXT = SMLSIZE + LEFT + COLOR_THEME_PRIMARY1

	if widget.curFileIndex <= #testFiles then
		doOneCase(widget)
		if widget.curFileIndex > #testFiles then
			lcd.drawText(ox + 2, oy + 2, "emutest OK", TXT)
			return
		end
		local fn = testFiles[widget.curFileIndex] or "?"
		lcd.drawText(ox + 2, oy + 2, "emutest", TXT)
		lcd.drawText(ox + 2, oy + 16, "f " .. tostring(widget.curFileIndex) .. "/" .. tostring(#testFiles), TXT)
		lcd.drawText(ox + 2, oy + 30, string.sub(tostring(fn), 1, 28), TXT)
		lcd.drawText(ox + 2, oy + 44, "c " .. tostring(widget.curCaseIndex), TXT)
		return
	end

	local invers = false
	if getRtcTime() % 2 == 1 then
		invers = true
	end

	if widget.viewMatrix == nil then
		initUI(widget)
	end

	local ev = event or 0
	if ev ~= 0 then
		print("[LzUtO] before:", ev)
	end
	local e = widget.keyMap[ev]
	if e ~= nil then
		ev = e
	end
	if ev ~= 0 then
		print("[LzUtO] after:", ev)
	end

	widget.viewMatrix:doKey(ev)

	lcd.drawText(ox + 1, oy + 1, "CheckBox:", SMLSIZE + LEFT)
	widget.checkBox:draw(ox + 54, oy + 1, invers, SMLSIZE + RIGHT)
	lcd.drawText(ox + 60, oy + 1, "TextEdit:", SMLSIZE + LEFT)
	widget.textEdit:draw(ox + 128, oy + 1, invers, SMLSIZE + RIGHT)

	lcd.drawText(ox + 1, oy + 10, "Button:", SMLSIZE + LEFT)
	widget.button:draw(ox + 54, oy + 10, invers, SMLSIZE + RIGHT)

	lcd.drawText(ox + 60, oy + 10, "ipselect:", SMLSIZE + LEFT)
	widget.inputSelector:draw(ox + 128, oy + 10, invers, SMLSIZE + RIGHT)

	lcd.drawText(ox + 1, oy + 20, "NumEdit:", SMLSIZE + LEFT)
	widget.numEdit:draw(ox + 54, oy + 20, invers, SMLSIZE + RIGHT)

	lcd.drawText(ox + 60, oy + 20, "opselect:", SMLSIZE + LEFT)
	widget.outputSelector:draw(ox + 128, oy + 20, invers, SMLSIZE + RIGHT)

	lcd.drawText(ox + 60, oy + 30, "csselect:", SMLSIZE + LEFT)
	widget.curveSelector:draw(ox + 128, oy + 30, invers, SMLSIZE + RIGHT)

	lcd.drawText(ox + 0, oy + 30, "mdselect:", SMLSIZE + LEFT)
	widget.modeSelector:draw(ox + 58, oy + 30, invers, SMLSIZE + RIGHT)

	lcd.drawText(ox + 0, oy + 40, "tsselect:", SMLSIZE + LEFT)
	widget.taskSelector:draw(ox + 84, oy + 40, invers, SMLSIZE + RIGHT)

	lcd.drawText(ox + 0, oy + 50, "timeedit:", SMLSIZE + LEFT)
	widget.timeEdit:draw(ox + 84, oy + 50, invers, SMLSIZE + RIGHT)

	local hintY = z.y + z.h - 14
	if hintY >= oy + 62 then
		lcd.drawText(ox + 2, hintY, "App:长按ENT交权", TXT)
	end
end

local function create(zone, options)
	gSDCardDir = "/"
	gAssertFlag = "ASSERT FLAG!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"

	local fun, err = loadScript(gSDCardDir .. "SCRIPTS/TELEMETRY/common/LoadModule.lua", "bt")
	if fun then
		fun()
	else
		print("[LzUtO] LoadModule FAIL:", tostring(err))
	end

	local curCases = LZ_runModule(gSDCardDir .. "SCRIPTS" .. testFiles[1])
	LZ_runModule(gSDCardDir .. "LAOZHU/EmuTestUtils.lua")
	LZ_runModule(gSDCardDir .. "LAOZHU/OTUtils.lua")

	LZ_runModule(gSDCardDir .. "SCRIPTS/TELEMETRY/common/keyMap.lua")
	local keyMap = KMgetKeyMap()
	KMunload()

	return {
		zone = zone,
		options = options,
		keyMap = keyMap,
		curFileIndex = 1,
		curCaseIndex = 1,
		curCases = curCases,
		viewMatrix = nil,
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
