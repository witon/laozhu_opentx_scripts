gScriptDir = "/SCRIPTS/"
gAssertFlag = "ASSERT FLAG!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
local textEdit = nil
local button = nil
local checkBox = nil
local inputSelector = nil
local numEdit = nil
local outputSelector = nil

local viewMatrix = nil


local testFiles = {
    "/SCRIPTS/emutest/testCfg.lua",
    "/SCRIPTS/emutest/testLoadModule.lua",
    "/SCRIPTS/emutest/testManagerOutput.lua",
}


local curCaseIndex = 1
local curFileIndex = 1
local curCases = nil

local function init()
    curCases = dofile(testFiles[curFileIndex])
    curCaseIndex = 1
    dofile(gScriptDir .. "LAOZHU/EmuTestUtils.lua")
    local fun, err = loadScript(gScriptDir .. "TELEMETRY/common/LoadModule.lua", "bt")
    fun()
    LZ_runModule(gScriptDir .. "TELEMETRY/common/InputView.lua")
    LZ_runModule(gScriptDir .. "TELEMETRY/common/TextEdit.lua")
    LZ_runModule(gScriptDir .. "TELEMETRY/common/Button.lua")
    LZ_runModule(gScriptDir .. "TELEMETRY/common/CheckBox.lua")
	LZ_runModule(gScriptDir .. "TELEMETRY/common/InputSelector.lua")
	LZ_runModule(gScriptDir .. "TELEMETRY/common/Fields.lua")
	initFieldsInfo()
    LZ_runModule(gScriptDir .. "TELEMETRY/common/NumEdit.lua")
    LZ_runModule(gScriptDir .. "TELEMETRY/common/OutputSelector.lua")
	
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
 
    IVsetFocusState(viewMatrix.matrix[viewMatrix.selectedRow][viewMatrix.selectedCol], 1)
 
end

local function doOneCase()
    if curCaseIndex > #curCases then
        curFileIndex = curFileIndex + 1
        if curFileIndex > #testFiles then
            return
        end
        curCaseIndex = 1
        local testFile = testFiles[curFileIndex]
        curCases = dofile(testFile)
    end
    curCases[curCaseIndex]()
    curCaseIndex = curCaseIndex + 1

end

local function run(event)
    local invers = false
    if getRtcTime() % 2 == 1 then
        invers = true
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

    if curFileIndex > #testFiles then
        return
    end
    doOneCase()
end

return {run=run, init=init }