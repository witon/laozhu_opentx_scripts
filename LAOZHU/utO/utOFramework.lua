-- utO 遥测 / LzUtO Widget 共用：emutest 列表、推进、ViewMatrix 演练 UI 与绘制。
local M = {}

local keyMap = nil

local function mapRaw(rawEv)
	local ke = keyMap[rawEv]
	return ke ~= nil and ke or rawEv
end

-- 遥测 ViewMatrix：KEY 调试 + 返回映射后事件（依赖 DBG_init 已执行）。
function M.telemetryViewMatrixMappedEvent(event)
	local rawEv = event or 0
	if rawEv ~= 0 then
		local m = keyMap[rawEv]
		DBG_dbg("KEY", "raw=" .. tostring(rawEv), "mapped=" .. tostring(m or rawEv), "hasMap=" .. tostring(m ~= nil))
	end
	return mapRaw(rawEv)
end

-- LzUtO ViewMatrix：按键调试、未交权周期日志、DBG_logOnMappedKey、返回映射后事件。
function M.widgetViewMatrixMappedEvent(dbgEnabled, event, refreshCount)
	local rawEv = event or 0
	if dbgEnabled then
		if event ~= nil and rawEv ~= 0 then
			local m = keyMap[event]
			DBG_dbg("KEY", "raw=" .. tostring(rawEv), "mapped=" .. tostring(m or rawEv), "hasMap=" .. tostring(m ~= nil))
		elseif refreshCount % 120 == 1 then
			DBG_dbg(string.format("refresh#%d evt=nil (未交权给 widget)", refreshCount))
		end
	end
	local mapped = mapRaw(rawEv)
	if dbgEnabled and event ~= nil and event ~= 0 then
		DBG_logOnMappedKey(mapped)
	end
	return mapped
end

M.TEST_FILES = {
	"/emutest/testCfg.lua",
	"/emutest/testCfgO.lua",
	"/emutest/testLoadModule.lua",
	"/emutest/testManagerOutput.lua",
	"/emutest/testDataFileDecode.lua",
	"/emutest/testSinkRateRecord.lua",
	-- "/SCRIPTS/emutest/testOutputCurveManager.lua",
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
	LZ_runModule(gSDCardDir .. "LAOZHU/uilib/TimeEditO.lua")
	LZ_runModule(gSDCardDir .. "LAOZHU/3k/TaskSelectorO.lua")
end

function M.initFramework(state)
	LZ_runModule(gSDCardDir .. "LAOZHU/uilib/keyMap.lua")
	keyMap = KMgetKeyMap()
	KMunload()
	state.curFileIndex = 1
	state.curCaseIndex = 1
	DBG_dbg("begin load")
	state.curCases = LZ_runModule(gSDCardDir .. "SCRIPTS" .. M.TEST_FILES[state.curFileIndex])
	DBG_dbg("loaded")
	if state.curCases == nil and state.dbgEnabled then
		DBG_err("load test file failed:", M.TEST_FILES[state.curFileIndex])
	end
	if state.dbgEnabled then
		DBG_dbg("emutest", "file 1/" .. tostring(#M.TEST_FILES), M.TEST_FILES[1])
	end
	LZ_runModule(gSDCardDir .. "LAOZHU/EmuTestUtils.lua")
	LZ_runModule(gSDCardDir .. "LAOZHU/OTUtils.lua")
end

function M.doOneCase(state)
	if state.curCaseIndex > #state.curCases then
		state.curFileIndex = state.curFileIndex + 1
		if state.curFileIndex > #M.TEST_FILES then
			return false
		end
		state.curCaseIndex = 1
		local testFile = M.TEST_FILES[state.curFileIndex]
		state.curCases = LZ_runModule(gSDCardDir .. "SCRIPTS" .. testFile)
		if state.dbgEnabled then
			if state.curCases == nil then
				DBG_err("emutest", "load test file failed", testFile)
			end
			DBG_dbg("emutest", "file " .. tostring(state.curFileIndex) .. "/" .. tostring(#M.TEST_FILES), testFile)
		end
	end
	state.curCases[state.curCaseIndex]()
	state.curCaseIndex = state.curCaseIndex + 1
	return true
end

function M.emutestStillRunning(state)
	return state.curFileIndex <= #M.TEST_FILES
end

function M.initUI(state)
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
	LZ_runModule(gSDCardDir .. "LAOZHU/3k/TaskSelectorO.lua")
	LZ_runModule(gSDCardDir .. "LAOZHU/uilib/TimeEditO.lua")

	state.viewMatrix = ViewMatrix:new()

	state.inputSelector = InputSelector:new()
	state.inputSelector:setFieldType(FIELDS_INPUT)
	state.checkBox = CheckBox:new()
	state.textEdit = TextEdit:new()
	state.textEdit.str = "abcd"

	state.button = Button:new()
	state.button.text = "a bt"

	state.numEdit = NumEdit:new()
	state.outputSelector = OutputSelector:new()
	state.curveSelector = CurveSelector:new()
	state.modeSelector = ModeSelector:new()
	state.taskSelector = TaskSelector:new()

	state.timeEdit = TimeEdit:new()
	state.timeEdit:setRange(0, 600)
	state.timeEdit.step = 15

	local vm = state.viewMatrix
	vm.matrix = {}
	vm.matrix[1] = {}
	vm.matrix[1][1] = state.checkBox
	vm.matrix[1][2] = state.textEdit
	vm.matrix[2] = {}
	vm.matrix[2][1] = state.button
	vm.matrix[2][2] = state.inputSelector
	vm.matrix[3] = {}
	vm.matrix[3][1] = state.numEdit
	vm.matrix[3][2] = state.outputSelector
	vm.matrix[4] = {}
	vm.matrix[4][1] = state.modeSelector
	vm.matrix[4][2] = state.curveSelector
	vm.matrix[5] = {}
	vm.matrix[5][1] = state.taskSelector
	vm.matrix[6] = {}
	vm.matrix[6][1] = state.timeEdit

	vm:updateCurIVFocus()
end

function M.handleViewMatrixKey(state, mappedEvent)
	state.viewMatrix:doKey(mappedEvent)
end

function M.drawEmutestProgress(state, layout)
	local ox, oy, rowH, TXT = layout.ox, layout.oy, layout.rowH, layout.TXT
	local fn = M.TEST_FILES[state.curFileIndex] or "?"
	lcd.drawText(ox + 2, oy + 2, "emutest", TXT)
	lcd.drawText(ox + 2, oy + 2 + rowH, "f " .. tostring(state.curFileIndex) .. "/" .. tostring(#M.TEST_FILES), TXT)
	lcd.drawText(ox + 2, oy + 2 + 2 * rowH, string.sub(tostring(fn), 1, 28), TXT)
	lcd.drawText(ox + 2, oy + 2 + 3 * rowH, "c " .. tostring(state.curCaseIndex), TXT)
end

function M.drawEmutestComplete(layout)
	lcd.drawText(layout.ox + 2, layout.oy + 2, "emutest OK", layout.TXT)
end

function M.drawViewMatrixDemo(state, layout)
	local invers = false
	if getRtcTime() % 2 == 1 then
		invers = true
	end
	local rs = layout.rowH or LZ_ui.rowStep

	if layout.kind == "full" then
		local midX = math.floor(LCD_W / 2)
		local pad = 1
		local gutter = 2
		local leftCtlR = midX - gutter
		local rightLbl = midX
		local rightCtlR = LCD_W - pad
		lcd.drawText(pad, 1, "CheckBox:", LZ_ui.font + LEFT)
		state.checkBox:draw(leftCtlR, 1, invers, LZ_ui.font + RIGHT)
		lcd.drawText(rightLbl, 1, "TextEdit:", LZ_ui.font + LEFT)
		state.textEdit:draw(rightCtlR, 1, invers, LZ_ui.font + RIGHT)

		lcd.drawText(pad, rs + 1, "Button:", LZ_ui.font + LEFT)
		state.button:draw(leftCtlR, rs + 1, invers, LZ_ui.font + RIGHT)

		lcd.drawText(rightLbl, rs + 1, "ipselect:", LZ_ui.font + LEFT)
		state.inputSelector:draw(rightCtlR, rs + 1, invers, LZ_ui.font + RIGHT)

		lcd.drawText(pad, 2 * rs + 1, "NumEdit:", LZ_ui.font + LEFT)
		state.numEdit:draw(leftCtlR, 2 * rs + 1, invers, LZ_ui.font + RIGHT)

		lcd.drawText(rightLbl, 2 * rs + 1, "opselect:", LZ_ui.font + LEFT)
		state.outputSelector:draw(rightCtlR, 2 * rs + 1, invers, LZ_ui.font + RIGHT)

		lcd.drawText(rightLbl, 3 * rs + 1, "csselect:", LZ_ui.font + LEFT)
		state.curveSelector:draw(rightCtlR, 3 * rs + 1, invers, LZ_ui.font + RIGHT)

		lcd.drawText(pad, 3 * rs + 1, "mdselect:", LZ_ui.font + LEFT)
		state.modeSelector:draw(leftCtlR, 3 * rs + 1, invers, LZ_ui.font + RIGHT)

		lcd.drawText(pad, 4 * rs + 1, "tsselect:", LZ_ui.font + LEFT)
		state.taskSelector:draw(rightCtlR, 4 * rs + 1, invers, LZ_ui.font + RIGHT)

		lcd.drawText(pad, 5 * rs + 1, "timeedit:", LZ_ui.font + LEFT)
		state.timeEdit:draw(rightCtlR, 5 * rs + 1, invers, LZ_ui.font + RIGHT)
		return
	end

	if layout.kind == "zone" then
		local z = layout.z
		local ox = layout.ox
		local oy = layout.oy
		local midGap = 6
		local leftEnd = math.floor((z.w - midGap) / 2)
		local rightStart = leftEnd + midGap
		local pad = 1
		local leftLbl = ox + pad
		local leftCtlR = ox + leftEnd - pad
		local rightLbl = ox + rightStart
		local rightCtlR = ox + z.w - pad

		lcd.drawText(leftLbl, oy + 1, "CheckBox:", LZ_ui.font + LEFT)
		state.checkBox:draw(leftCtlR, oy + 1, invers, LZ_ui.font + RIGHT)
		lcd.drawText(rightLbl, oy + 1, "TextEdit:", LZ_ui.font + LEFT)
		state.textEdit:draw(rightCtlR, oy + 1, invers, LZ_ui.font + RIGHT)

		lcd.drawText(leftLbl, oy + rs + 1, "Button:", LZ_ui.font + LEFT)
		state.button:draw(leftCtlR, oy + rs + 1, invers, LZ_ui.font + RIGHT)

		lcd.drawText(rightLbl, oy + rs + 1, "ipselect:", LZ_ui.font + LEFT)
		state.inputSelector:draw(rightCtlR, oy + rs + 1, invers, LZ_ui.font + RIGHT)

		lcd.drawText(leftLbl, oy + 2 * rs + 1, "NumEdit:", LZ_ui.font + LEFT)
		state.numEdit:draw(leftCtlR, oy + 2 * rs + 1, invers, LZ_ui.font + RIGHT)

		lcd.drawText(rightLbl, oy + 2 * rs + 1, "opselect:", LZ_ui.font + LEFT)
		state.outputSelector:draw(rightCtlR, oy + 2 * rs + 1, invers, LZ_ui.font + RIGHT)

		lcd.drawText(rightLbl, oy + 3 * rs + 1, "csselect:", LZ_ui.font + LEFT)
		state.curveSelector:draw(rightCtlR, oy + 3 * rs + 1, invers, LZ_ui.font + RIGHT)

		lcd.drawText(leftLbl, oy + 3 * rs + 1, "mdselect:", LZ_ui.font + LEFT)
		state.modeSelector:draw(leftCtlR, oy + 3 * rs + 1, invers, LZ_ui.font + RIGHT)

		lcd.drawText(leftLbl, oy + 4 * rs + 1, "tsselect:", LZ_ui.font + LEFT)
		state.taskSelector:draw(rightCtlR, oy + 4 * rs + 1, invers, LZ_ui.font + RIGHT)

		lcd.drawText(leftLbl, oy + 5 * rs + 1, "timeedit:", LZ_ui.font + LEFT)
		state.timeEdit:draw(rightCtlR, oy + 5 * rs + 1, invers, LZ_ui.font + RIGHT)
	end
end

return M
