gSDCardDir = "/"
local fun, err = loadScript(gSDCardDir .. "LAOZHU/uilib/LoadModule.lua", "bt")
fun()
gAssertFlag = "ASSERT FLAG!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
local textEdit = nil
local button = nil
local checkBox = nil
local inputSelector = nil
local numEdit = nil
local outputSelector = nil
local curveSelector = nil
local modeSelector = nil
local taskSelector = nil
local timeEdit = nil


local viewMatrix = nil

-- 调试：见 LAOZHU/DBGTools/dbg.lua；ERROR_LOG 控制 DBG_err，DEBUG_LOG 控制 DBG_dbg；SHOW_LOG_SCREEN 开时对应级别写入日志缓冲（遥测侧 DBGTelemetryLog 尚未绘制覆盖层，宜保持 false）。
local DBG_OPTS = {
	printTag = "[utO]",
	ERROR_LOG = true,
	DEBUG_LOG = true,
	SHOW_LOG_SCREEN = false,
	LOG_MAX = 20,
}

LZ_runModule(gSDCardDir .. "LAOZHU/uilib/keyMap.lua")
local keyMap = KMgetKeyMap();
KMunload();

local testFiles = {
    "/emutest/testCfg.lua",
    "/emutest/testCfgO.lua",
 
    "/emutest/testLoadModule.lua",
    "/emutest/testManagerOutput.lua",
    "/emutest/testDataFileDecode.lua",
    "/emutest/testSinkRateRecord.lua"
 
    --"/SCRIPTS/emutest/testOutputCurveManager.lua",
}


local curCaseIndex = 1
local curFileIndex = 1
local curCases = nil

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

local function initUI()
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
 
    viewMatrix = ViewMatrix:new()

    inputSelector = InputSelector:new()
    inputSelector:setFieldType(FIELDS_INPUT)
    checkBox = CheckBox:new()
    textEdit = TextEdit:new()
    textEdit.str = "abcd"

    button = Button:new()
    button.text = "a bt"

    numEdit = NumEdit:new()
    outputSelector = OutputSelector:new()
    curveSelector = CurveSelector:new()
    modeSelector = ModeSelector:new()
    taskSelector = TaskSelector:new()

    timeEdit = TimeEdit:new()
    timeEdit:setRange(0, 600)
    timeEdit.step = 15



    viewMatrix.matrix = {}
    viewMatrix.matrix[1] = {}
    viewMatrix.matrix[1][1] = checkBox
    viewMatrix.matrix[1][2] = textEdit
    viewMatrix.matrix[2] = {}
    viewMatrix.matrix[2][1] = button
    viewMatrix.matrix[2][2] = inputSelector
    viewMatrix.matrix[3] = {}
    viewMatrix.matrix[3][1] = numEdit
    viewMatrix.matrix[3][2] = outputSelector
    viewMatrix.matrix[4] = {}
    viewMatrix.matrix[4][1] = modeSelector
    viewMatrix.matrix[4][2] = curveSelector
    viewMatrix.matrix[5] = {}
    viewMatrix.matrix[5][1] = taskSelector
    viewMatrix.matrix[6] = {}
    viewMatrix.matrix[6][1] = timeEdit
 
--    IVsetFocusState(viewMatrix.matrix[viewMatrix.selectedRow][viewMatrix.selectedCol], 1)
    viewMatrix:updateCurIVFocus()
 
end

local function init()
    local c2 = collectgarbage("count")
    LZ_runModule(gSDCardDir .. "LAOZHU/DBGTools/dbg.lua")
    DBG_init(DBG_OPTS)
    DBG_dbg("begin load")
    curCases = LZ_runModule(gSDCardDir .. "SCRIPTS" .. testFiles[curFileIndex])
    DBG_dbg("loaded")
    if curCases == nil then
        DBG_err("load test file failed:", testFiles[curFileIndex])
    end
    DBG_dbg("emutest", "file 1/" .. tostring(#testFiles), testFiles[1])
    curCaseIndex = 1
    LZ_runModule(gSDCardDir .. "LAOZHU/EmuTestUtils.lua")
    LZ_runModule(gSDCardDir .. "LAOZHU/OTUtils.lua")

end

local function doOneCase()
    if curCaseIndex > #curCases then
        curFileIndex = curFileIndex + 1
        if curFileIndex > #testFiles then
            return false
        end
        curCaseIndex = 1
        local testFile = testFiles[curFileIndex]
        curCases = LZ_runModule(gSDCardDir .. "SCRIPTS" .. testFile)
        if curCases == nil then
            DBG_err("load test file failed:", testFile)
        end
        DBG_dbg("emutest", "file " .. tostring(curFileIndex) .. "/" .. tostring(#testFiles), testFile)
    end
    curCases[curCaseIndex]()
    curCaseIndex = curCaseIndex + 1
    return true

end

local function run(event)
    if curFileIndex <= #testFiles then
        doOneCase()
        if curFileIndex > #testFiles then
            DBG_dbg("emutest OK")
        end
        return
    end

    local invers = false
    if getRtcTime() % 2 == 1 then
        invers = true
    end

    if viewMatrix == nil then
        initUI()
    end
 
    lcd.clear()


	local rawEv = event or 0
	if rawEv ~= 0 then
		local m = keyMap[rawEv]
		DBG_dbg("KEY", "raw=" .. tostring(rawEv), "mapped=" .. tostring(m or rawEv), "hasMap=" .. tostring(m ~= nil))
	end
	e = keyMap[event];
	if e ~= nil then
		event = e;
	end



    viewMatrix:doKey(event)
    local rs = LZ_ui.rowStep
    local midX = math.floor(LCD_W / 2)
    local pad = 1
    local gutter = 2
    local leftCtlR = midX - gutter
    local rightLbl = midX
    local rightCtlR = LCD_W - pad
    lcd.drawText(pad, 1, "CheckBox:", LZ_ui.font + LEFT)
    checkBox:draw(leftCtlR, 1, invers, LZ_ui.font + RIGHT)
    lcd.drawText(rightLbl, 1, "TextEdit:", LZ_ui.font + LEFT)
    textEdit:draw(rightCtlR, 1, invers, LZ_ui.font + RIGHT)

    lcd.drawText(pad, rs + 1, "Button:", LZ_ui.font + LEFT)
    button:draw(leftCtlR, rs + 1, invers, LZ_ui.font + RIGHT)

    lcd.drawText(rightLbl, rs + 1, "ipselect:", LZ_ui.font + LEFT)
    inputSelector:draw(rightCtlR, rs + 1, invers, LZ_ui.font + RIGHT)

    lcd.drawText(pad, 2 * rs + 1, "NumEdit:", LZ_ui.font + LEFT)
    numEdit:draw(leftCtlR, 2 * rs + 1, invers, LZ_ui.font + RIGHT)

    lcd.drawText(rightLbl, 2 * rs + 1, "opselect:", LZ_ui.font + LEFT)
    outputSelector:draw(rightCtlR, 2 * rs + 1, invers, LZ_ui.font + RIGHT)

    lcd.drawText(rightLbl, 3 * rs + 1, "csselect:", LZ_ui.font + LEFT)
    curveSelector:draw(rightCtlR, 3 * rs + 1, invers, LZ_ui.font + RIGHT)

    lcd.drawText(pad, 3 * rs + 1, "mdselect:", LZ_ui.font + LEFT)
    modeSelector:draw(leftCtlR, 3 * rs + 1, invers, LZ_ui.font + RIGHT)

    lcd.drawText(pad, 4 * rs + 1, "tsselect:", LZ_ui.font + LEFT)
    taskSelector:draw(rightCtlR, 4 * rs + 1, invers, LZ_ui.font + RIGHT)

    lcd.drawText(pad, 5 * rs + 1, "timeedit:", LZ_ui.font + LEFT)
    timeEdit:draw(rightCtlR, 5 * rs + 1, invers, LZ_ui.font + RIGHT)
end

return {run=run, init=init }