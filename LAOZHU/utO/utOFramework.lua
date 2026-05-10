-- utO 遥测 / LzUtO Widget 共用：emutest 列表、推进、ViewMatrix 演练 UI 与绘制。
-- 对外仅 initFramework / initUI / run；会话状态模块内私有。
local M = {}

local keyMap = nil

local TEST_FILES = {
	"/emutest/testCfg.lua",
	"/emutest/testCfgO.lua",
	"/emutest/testLoadModule.lua",
	"/emutest/testManagerOutput.lua",
	"/emutest/testDataFileDecode.lua",
	"/emutest/testSinkRateRecord.lua",
	-- "/SCRIPTS/emutest/testOutputCurveManager.lua",
}

local st = {
	curFileIndex = 1,
	curCaseIndex = 1,
	curCases = nil,
	dbgEnabled = true,
	surface = "telemetry",
	frameworkInited = false,
	viewMatrix = nil,
	inputSelector = nil,
	checkBox = nil,
	textEdit = nil,
	button = nil,
	numEdit = nil,
	outputSelector = nil,
	curveSelector = nil,
	modeSelector = nil,
	taskSelector = nil,
	timeEdit = nil,
	dbgLogView = nil,
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

local function doOneCase()
	if st.curCaseIndex > #st.curCases then
		st.curFileIndex = st.curFileIndex + 1
		if st.curFileIndex > #TEST_FILES then
			return false
		end
		st.curCaseIndex = 1
		local testFile = TEST_FILES[st.curFileIndex]
		st.curCases = LZ_runModule(gSDCardDir .. "SCRIPTS" .. testFile)
		if st.dbgEnabled then
			if st.curCases == nil then
				DBG_err("emutest", "load test file failed", testFile)
			end
			DBG_dbg("emutest", "file " .. tostring(st.curFileIndex) .. "/" .. tostring(#TEST_FILES), testFile)
		end
	end
	st.curCases[st.curCaseIndex]()
	st.curCaseIndex = st.curCaseIndex + 1
	return true
end

local function emutestStillRunning()
	return st.curFileIndex <= #TEST_FILES
end

local function handleViewMatrixKey(mappedEvent)
	st.viewMatrix:doKey(mappedEvent)
end

local function drawViewMatrixDemo(layout)
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
		st.checkBox:draw(leftCtlR, 1, invers, LZ_ui.font + RIGHT)
		lcd.drawText(rightLbl, 1, "TextEdit:", LZ_ui.font + LEFT)
		st.textEdit:draw(rightCtlR, 1, invers, LZ_ui.font + RIGHT)

		lcd.drawText(pad, rs + 1, "Button:", LZ_ui.font + LEFT)
		st.button:draw(leftCtlR, rs + 1, invers, LZ_ui.font + RIGHT)

		lcd.drawText(rightLbl, rs + 1, "ipselect:", LZ_ui.font + LEFT)
		st.inputSelector:draw(rightCtlR, rs + 1, invers, LZ_ui.font + RIGHT)

		lcd.drawText(pad, 2 * rs + 1, "NumEdit:", LZ_ui.font + LEFT)
		st.numEdit:draw(leftCtlR, 2 * rs + 1, invers, LZ_ui.font + RIGHT)

		lcd.drawText(rightLbl, 2 * rs + 1, "opselect:", LZ_ui.font + LEFT)
		st.outputSelector:draw(rightCtlR, 2 * rs + 1, invers, LZ_ui.font + RIGHT)

		lcd.drawText(rightLbl, 3 * rs + 1, "csselect:", LZ_ui.font + LEFT)
		st.curveSelector:draw(rightCtlR, 3 * rs + 1, invers, LZ_ui.font + RIGHT)

		lcd.drawText(pad, 3 * rs + 1, "mdselect:", LZ_ui.font + LEFT)
		st.modeSelector:draw(leftCtlR, 3 * rs + 1, invers, LZ_ui.font + RIGHT)

		lcd.drawText(pad, 4 * rs + 1, "tsselect:", LZ_ui.font + LEFT)
		st.taskSelector:draw(rightCtlR, 4 * rs + 1, invers, LZ_ui.font + RIGHT)

		lcd.drawText(pad, 5 * rs + 1, "timeedit:", LZ_ui.font + LEFT)
		st.timeEdit:draw(rightCtlR, 5 * rs + 1, invers, LZ_ui.font + RIGHT)
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
		st.checkBox:draw(leftCtlR, oy + 1, invers, LZ_ui.font + RIGHT)
		lcd.drawText(rightLbl, oy + 1, "TextEdit:", LZ_ui.font + LEFT)
		st.textEdit:draw(rightCtlR, oy + 1, invers, LZ_ui.font + RIGHT)

		lcd.drawText(leftLbl, oy + rs + 1, "Button:", LZ_ui.font + LEFT)
		st.button:draw(leftCtlR, oy + rs + 1, invers, LZ_ui.font + RIGHT)

		lcd.drawText(rightLbl, oy + rs + 1, "ipselect:", LZ_ui.font + LEFT)
		st.inputSelector:draw(rightCtlR, oy + rs + 1, invers, LZ_ui.font + RIGHT)

		lcd.drawText(leftLbl, oy + 2 * rs + 1, "NumEdit:", LZ_ui.font + LEFT)
		st.numEdit:draw(leftCtlR, oy + 2 * rs + 1, invers, LZ_ui.font + RIGHT)

		lcd.drawText(rightLbl, oy + 2 * rs + 1, "opselect:", LZ_ui.font + LEFT)
		st.outputSelector:draw(rightCtlR, oy + 2 * rs + 1, invers, LZ_ui.font + RIGHT)

		lcd.drawText(rightLbl, oy + 3 * rs + 1, "csselect:", LZ_ui.font + LEFT)
		st.curveSelector:draw(rightCtlR, oy + 3 * rs + 1, invers, LZ_ui.font + RIGHT)

		lcd.drawText(leftLbl, oy + 3 * rs + 1, "mdselect:", LZ_ui.font + LEFT)
		st.modeSelector:draw(leftCtlR, oy + 3 * rs + 1, invers, LZ_ui.font + RIGHT)

		lcd.drawText(leftLbl, oy + 4 * rs + 1, "tsselect:", LZ_ui.font + LEFT)
		st.taskSelector:draw(rightCtlR, oy + 4 * rs + 1, invers, LZ_ui.font + RIGHT)

		lcd.drawText(leftLbl, oy + 5 * rs + 1, "timeedit:", LZ_ui.font + LEFT)
		st.timeEdit:draw(rightCtlR, oy + 5 * rs + 1, invers, LZ_ui.font + RIGHT)
	end
end

function M.initFramework(opts)
	if st.frameworkInited then
		return
	end
	opts = opts or {}
	st.frameworkInited = true
	st.surface = opts.surface or "telemetry"
	st.dbgEnabled = opts.dbgEnabled ~= false
	LZ_runModule(gSDCardDir .. "LAOZHU/uilib/keyMap.lua")
	keyMap = KMgetKeyMap()
	KMunload()
	st.curFileIndex = 1
	st.curCaseIndex = 1
	DBG_dbg("begin load")
	st.curCases = LZ_runModule(gSDCardDir .. "SCRIPTS" .. TEST_FILES[st.curFileIndex])
	DBG_dbg("loaded")
	if st.curCases == nil and st.dbgEnabled then
		DBG_err("load test file failed:", TEST_FILES[st.curFileIndex])
	end
	if st.dbgEnabled then
		DBG_dbg("emutest", "file 1/" .. tostring(#TEST_FILES), TEST_FILES[1])
	end
	LZ_runModule(gSDCardDir .. "LAOZHU/EmuTestUtils.lua")
	LZ_runModule(gSDCardDir .. "LAOZHU/OTUtils.lua")
	if st.dbgEnabled then
		LZ_runModule(gSDCardDir .. "LAOZHU/DBGTools/DBGLogListView.lua")
		st.dbgLogView = DBGLogLVnew()
	end
end

function M.initUI()
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

	st.viewMatrix = ViewMatrix:new()

	st.inputSelector = InputSelector:new()
	st.inputSelector:setFieldType(FIELDS_INPUT)
	st.checkBox = CheckBox:new()
	st.textEdit = TextEdit:new()
	st.textEdit.str = "abcd"

	st.button = Button:new()
	st.button.text = "a bt"

	st.numEdit = NumEdit:new()
	st.outputSelector = OutputSelector:new()
	st.curveSelector = CurveSelector:new()
	st.modeSelector = ModeSelector:new()
	st.taskSelector = TaskSelector:new()

	st.timeEdit = TimeEdit:new()
	st.timeEdit:setRange(0, 600)
	st.timeEdit.step = 15

	local vm = st.viewMatrix
	vm.matrix = {}
	vm.matrix[1] = {}
	vm.matrix[1][1] = st.checkBox
	vm.matrix[1][2] = st.textEdit
	vm.matrix[2] = {}
	vm.matrix[2][1] = st.button
	vm.matrix[2][2] = st.inputSelector
	vm.matrix[3] = {}
	vm.matrix[3][1] = st.numEdit
	vm.matrix[3][2] = st.outputSelector
	vm.matrix[4] = {}
	vm.matrix[4][1] = st.modeSelector
	vm.matrix[4][2] = st.curveSelector
	vm.matrix[5] = {}
	vm.matrix[5][1] = st.taskSelector
	vm.matrix[6] = {}
	vm.matrix[6][1] = st.timeEdit

	vm:updateCurIVFocus()
end

function M.run(event, surfaceCtx)
	if st.surface == "widget" and surfaceCtx == nil then
		return
	end

	if emutestStillRunning() then
		doOneCase()
		if emutestStillRunning() then
			return
		end
	end

	if st.viewMatrix == nil then
		M.initUI()
	end

	local e = event or 0
	local mapped = keyMap[e] or e
	local layout
	if st.surface == "telemetry" then
		lcd.clear()
		layout = { kind = "full", rowH = LZ_ui.rowStep }
	else
		layout = { kind = "zone", ox = surfaceCtx.ox, oy = surfaceCtx.oy, z = surfaceCtx.z, rowH = surfaceCtx.rowH }
	end
	handleViewMatrixKey(mapped)
	drawViewMatrixDemo(layout)
	if st.dbgEnabled and st.dbgLogView ~= nil and DBG ~= nil then
		if st.surface == "widget" and surfaceCtx ~= nil then
			local z = surfaceCtx.z
			local maxVis = DBGLogLVmaxVisForRect(z.w, z.h)
			DBG_logClampScroll(maxVis)
			DBGLogLVdraw(st.dbgLogView, z.x, z.y, z.w, z.h, surfaceCtx.zoneBg, surfaceCtx.TXT, "App:长按ENT交权 ↑/↓滚动")
		elseif st.surface == "telemetry" then
			local rs = LZ_ui.rowStep
			local bandH = math.min(LCD_H, math.max(rs * 6, math.floor(LCD_H * 0.38)))
			local logY = LCD_H - bandH
			local maxVis = DBGLogLVmaxVisForRect(LCD_W, bandH)
			DBG_logClampScroll(maxVis)
			local txtFlags = LZ_ui.font + LEFT
			if LZ_ui.themeText ~= nil and LZ_ui.themeText ~= 0 then
				txtFlags = txtFlags + LZ_ui.themeText
			end
			DBGLogLVdraw(st.dbgLogView, 0, logY, LCD_W, bandH, ERASE, txtFlags, "↑/↓滚动")
		end
	end
end

return M
