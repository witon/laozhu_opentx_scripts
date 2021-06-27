gScriptDir = "/SCRIPTS/"
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


local testFiles = {
    "/SCRIPTS/emutest/testCfg.lua",
    "/SCRIPTS/emutest/testCfgO.lua",
 
    "/SCRIPTS/emutest/testLoadModule.lua",
    "/SCRIPTS/emutest/testManagerOutput.lua",
    "/SCRIPTS/emutest/testDataFileDecode.lua",
    "/SCRIPTS/emutest/testSinkRateRecord.lua"
 
    --"/SCRIPTS/emutest/testOutputCurveManager.lua",
}


local curCaseIndex = 1
local curFileIndex = 1
local curCases = nil

local function testLoadAndUnload()
    LZ_runModule("TELEMETRY/common/InputViewO.lua")
    LZ_runModule("TELEMETRY/common/TextEditO.lua")
    LZ_runModule("TELEMETRY/common/ButtonO.lua")
    LZ_runModule("TELEMETRY/common/CheckBoxO.lua")
	LZ_runModule("TELEMETRY/common/SelectorO.lua")
	LZ_runModule("TELEMETRY/common/InputSelectorO.lua")
	LZ_runModule("TELEMETRY/common/Fields.lua")
	initFieldsInfo()
    FieldsUnload()
    LZ_runModule("TELEMETRY/common/NumEditO.lua")
    LZ_runModule("TELEMETRY/common/OutputSelectorO.lua")
	LZ_runModule("TELEMETRY/common/CurveSelector.lua")
    CSunload()
	LZ_runModule("TELEMETRY/common/ModeSelectorO.lua")
	LZ_runModule("TELEMETRY/common/ViewMatrixO.lua")
	LZ_runModule("TELEMETRY/common/TimeEditO.lua")
	LZ_runModule("TELEMETRY/3k/TaskSelectorO.lua")
end

local function initUI()
    testLoadAndUnload()
    LZ_runModule("TELEMETRY/common/TextEditO.lua")
    LZ_runModule("TELEMETRY/common/InputViewO.lua")
    LZ_runModule("TELEMETRY/common/ButtonO.lua")
    LZ_runModule("TELEMETRY/common/CheckBoxO.lua")
	LZ_runModule("TELEMETRY/common/SelectorO.lua")
	LZ_runModule("TELEMETRY/common/InputSelector.lua")
	LZ_runModule("TELEMETRY/common/Fields.lua")
	initFieldsInfo()
    LZ_runModule("TELEMETRY/common/NumEditO.lua")
    LZ_runModule("TELEMETRY/common/OutputSelectorO.lua")
	LZ_runModule("TELEMETRY/common/CurveSelectorO.lua")
	LZ_runModule("TELEMETRY/common/ModeSelectorO.lua")
	LZ_runModule("TELEMETRY/common/ViewMatrixO.lua")
	LZ_runModule("TELEMETRY/3k/TaskSelectorO.lua")
	LZ_runModule("TELEMETRY/common/TimeEditO.lua")
 
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
    local fun, err = loadScript(gScriptDir .. "TELEMETRY/common/LoadModule.lua", "bt")
    fun()
    curCases = LZ_runModule(testFiles[curFileIndex])
    curCaseIndex = 1
    LZ_runModule("LAOZHU/EmuTestUtils.lua")
    LZ_runModule("LAOZHU/OTUtils.lua")

end

local function doOneCase()
    if curCaseIndex > #curCases then
        curFileIndex = curFileIndex + 1
        if curFileIndex > #testFiles then
            return false
        end
        curCaseIndex = 1
        local testFile = testFiles[curFileIndex]
        curCases = LZ_runModule(testFile)
    end
    curCases[curCaseIndex]()
    curCaseIndex = curCaseIndex + 1
    return true

end

local function run(event)
    if curFileIndex <= #testFiles then
        doOneCase()
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
    viewMatrix:doKey(event)
    lcd.drawText(1, 1, "CheckBox:", SMLSIZE + LEFT)
    checkBox:draw(54, 1, invers, SMLSIZE + RIGHT)
    lcd.drawText(60, 1, "TextEdit:", SMLSIZE + LEFT)
    textEdit:draw(128, 1, invers, SMLSIZE + RIGHT)


    lcd.drawText(1, 10, "Button:", SMLSIZE + LEFT)
    button:draw(54, 10, invers, SMLSIZE + RIGHT)

    lcd.drawText(60, 10, "ipselect:", SMLSIZE + LEFT)
    inputSelector:draw(128, 10, invers, SMLSIZE + RIGHT)

    lcd.drawText(1, 20, "NumEdit:", SMLSIZE + LEFT)
    numEdit:draw(54, 20, invers, SMLSIZE + RIGHT)

    lcd.drawText(60, 20, "opselect:", SMLSIZE + LEFT)
    outputSelector:draw(128, 20, invers, SMLSIZE + RIGHT)
--
    lcd.drawText(60, 30, "csselect:", SMLSIZE + LEFT)
    curveSelector:draw(128, 30, invers, SMLSIZE + RIGHT)
--
    lcd.drawText(0, 30, "mdselect:", SMLSIZE + LEFT)
    modeSelector:draw(58, 30, invers, SMLSIZE + RIGHT)
--
    lcd.drawText(0, 40, "tsselect:", SMLSIZE + LEFT)
    taskSelector:draw(84, 40, invers, SMLSIZE + RIGHT)
--
    lcd.drawText(0, 50, "timeedit:", SMLSIZE + LEFT)
    timeEdit:draw(84, 50, invers, SMLSIZE + RIGHT)
end

return {run=run, init=init }