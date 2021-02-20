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


local viewMatrix = nil


local testFiles = {
    "/SCRIPTS/emutest/testCfg.lua",
    "/SCRIPTS/emutest/testLoadModule.lua",
    "/SCRIPTS/emutest/testManagerOutput.lua",
    --"/SCRIPTS/emutest/testOutputCurveManager.lua",
}


local curCaseIndex = 1
local curFileIndex = 1
local curCases = nil

local function testLoadAndUnload()
    LZ_runModule(gScriptDir .. "TELEMETRY/common/TextEdit.lua")
    TEunload()
    LZ_runModule(gScriptDir .. "TELEMETRY/common/InputView.lua")
    IVunload()
    LZ_runModule(gScriptDir .. "TELEMETRY/common/Button.lua")
    BTunload()
    LZ_runModule(gScriptDir .. "TELEMETRY/common/CheckBox.lua")
    CBunload()
	LZ_runModule(gScriptDir .. "TELEMETRY/common/InputSelector.lua")
    ISunload()
	LZ_runModule(gScriptDir .. "TELEMETRY/common/Fields.lua")
	initFieldsInfo()
    FieldsUnload()
    LZ_runModule(gScriptDir .. "TELEMETRY/common/NumEdit.lua")
    NEunload()
    LZ_runModule(gScriptDir .. "TELEMETRY/common/OutputSelector.lua")
    OSunload()
	LZ_runModule(gScriptDir .. "TELEMETRY/common/CurveSelector.lua")
    CSunload()
	LZ_runModule(gScriptDir .. "TELEMETRY/common/Selector.lua")
    Sunload()
	LZ_runModule(gScriptDir .. "TELEMETRY/common/ModeSelector.lua")
    MSunload()
	LZ_runModule(gScriptDir .. "TELEMETRY/common/ViewMatrix.lua")
    VMunload()
end

local function initUI()
    testLoadAndUnload()
    LZ_runModule(gScriptDir .. "TELEMETRY/common/TextEdit.lua")
    LZ_runModule(gScriptDir .. "TELEMETRY/common/InputView.lua")
    LZ_runModule(gScriptDir .. "TELEMETRY/common/Button.lua")
    LZ_runModule(gScriptDir .. "TELEMETRY/common/CheckBox.lua")
	LZ_runModule(gScriptDir .. "TELEMETRY/common/InputSelector.lua")
	LZ_runModule(gScriptDir .. "TELEMETRY/common/Fields.lua")
	initFieldsInfo()
    LZ_runModule(gScriptDir .. "TELEMETRY/common/NumEdit.lua")
    LZ_runModule(gScriptDir .. "TELEMETRY/common/OutputSelector.lua")
	LZ_runModule(gScriptDir .. "TELEMETRY/common/CurveSelector.lua")
	LZ_runModule(gScriptDir .. "TELEMETRY/common/Selector.lua")
	LZ_runModule(gScriptDir .. "TELEMETRY/common/ModeSelector.lua")
	LZ_runModule(gScriptDir .. "TELEMETRY/common/ViewMatrix.lua")
    viewMatrix = VMnewViewMatrix()

    inputSelector = ISnewInputSelector()
    ISsetFieldType(inputSelector, FIELDS_INPUT)
    checkBox = CBnewCheckBox()
    textEdit = TEnewTextEdit()
    textEdit.str = "abcd"

    button = BTnewButton()
    button.text = "a bt"

    numEdit = NEnewNumEdit()
    outputSelector = OSnewOutputSelector()
    curveSelector = CSnewCurveSelector()
    modeSelector = MSnewModeSelector()


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
 
    IVsetFocusState(viewMatrix.matrix[viewMatrix.selectedRow][viewMatrix.selectedCol], 1)
 
end

local function init()
    local c2 = collectgarbage("count")
    local fun, err = loadScript(gScriptDir .. "TELEMETRY/common/LoadModule.lua", "bt")
    fun()
    curCases = LZ_runModule(testFiles[curFileIndex])
    curCaseIndex = 1
    LZ_runModule(gScriptDir .. "LAOZHU/EmuTestUtils.lua")
    LZ_runModule(gScriptDir .. "LAOZHU/utils.lua")

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
    viewMatrix.doKey(viewMatrix, event)
    lcd.drawText(1, 1, "CheckBox:", SMLSIZE + LEFT)
    IVdraw(checkBox, 54, 1, invers, SMLSIZE + RIGHT)
    lcd.drawText(60, 1, "TextEdit:", SMLSIZE + LEFT)
    IVdraw(textEdit, 128, 1, invers, SMLSIZE + RIGHT)


    lcd.drawText(1, 10, "Button:", SMLSIZE + LEFT)
    IVdraw(button, 54, 10, invers, SMLSIZE + RIGHT)

    lcd.drawText(60, 10, "ipselect:", SMLSIZE + LEFT)
    IVdraw(inputSelector, 128, 10, invers, SMLSIZE + RIGHT)

    lcd.drawText(1, 20, "NumEdit:", SMLSIZE + LEFT)
    IVdraw(numEdit, 54, 20, invers, SMLSIZE + RIGHT)

    lcd.drawText(60, 20, "opselect:", SMLSIZE + LEFT)
    IVdraw(outputSelector, 128, 20, invers, SMLSIZE + RIGHT)

    lcd.drawText(60, 30, "csselect:", SMLSIZE + LEFT)
    IVdraw(curveSelector, 128, 30, invers, SMLSIZE + RIGHT)

    lcd.drawText(0, 30, "mdselect:", SMLSIZE + LEFT)
    IVdraw(modeSelector, 58, 30, invers, SMLSIZE + RIGHT)
 
    --local c3 = collectgarbage("count")
    --print("----------------c3", c3)
 

end

return {run=run, init=init }