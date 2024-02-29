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

local ver, radio = getVersion();
local upEvent = 0
local downEvent = 0
local leftEvent = 0
local rightEvent = 0
if string.sub(radio, 1, 5) == "zorro" then
	upEvent = 37
	downEvent = 38
	leftEvent = 4099
	rightEvent = 4100
end



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
    LZ_runModule("TELEMETRY/common/TextEdit.lua")
    TEunload()
    LZ_runModule("TELEMETRY/common/InputView.lua")
    IVunload()
    LZ_runModule("TELEMETRY/common/Button.lua")
    BTunload()
    LZ_runModule("TELEMETRY/common/CheckBox.lua")
    CBunload()
	LZ_runModule("TELEMETRY/common/InputSelector.lua")
    ISunload()
	LZ_runModule("TELEMETRY/common/Fields.lua")
	initFieldsInfo()
    FieldsUnload()
    LZ_runModule("TELEMETRY/common/NumEdit.lua")
    NEunload()
    LZ_runModule("TELEMETRY/common/OutputSelector.lua")
    OSunload()
	LZ_runModule("TELEMETRY/common/CurveSelector.lua")
    CSunload()
	LZ_runModule("TELEMETRY/common/Selector.lua")
    Sunload()
	LZ_runModule("TELEMETRY/common/ModeSelector.lua")
    MSunload()
	LZ_runModule("TELEMETRY/common/ViewMatrix.lua")
    VMunload()
	LZ_runModule("TELEMETRY/common/TimeEdit.lua")
    TIMEEunload()

	LZ_runModule("TELEMETRY/3k/TaskSelector.lua")
    TSunload()

end

local function initUI()
    testLoadAndUnload()
    LZ_runModule("TELEMETRY/common/TextEdit.lua")
    LZ_runModule("TELEMETRY/common/InputView.lua")
    LZ_runModule("TELEMETRY/common/Button.lua")
    LZ_runModule("TELEMETRY/common/CheckBox.lua")
	LZ_runModule("TELEMETRY/common/InputSelector.lua")
	LZ_runModule("TELEMETRY/common/Fields.lua")
	initFieldsInfo()
    LZ_runModule("TELEMETRY/common/NumEdit.lua")
    LZ_runModule("TELEMETRY/common/OutputSelector.lua")
	LZ_runModule("TELEMETRY/common/CurveSelector.lua")
	LZ_runModule("TELEMETRY/common/Selector.lua")
	LZ_runModule("TELEMETRY/common/ModeSelector.lua")
	LZ_runModule("TELEMETRY/common/ViewMatrix.lua")
	LZ_runModule("TELEMETRY/3k/TaskSelector.lua")
	LZ_runModule("TELEMETRY/common/TimeEdit.lua")
 
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
    taskSelector = TSnewTaskSelector()

    timeEdit = TIMEEnewTimeEdit()
    NEsetRange(timeEdit, 0, 600)
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
 
    IVsetFocusState(viewMatrix.matrix[viewMatrix.selectedRow][viewMatrix.selectedCol], 1)
 
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
	if event ~= 0 then
		print("before:", event)
	end
	if event == leftEvent then
		event = 38
	elseif event == rightEvent then
		event = 37
	elseif event == downEvent then
		event = 35
	elseif event == upEvent then
		event = 36
	end
	if event ~= 0 then
		print("after:", event)
	end


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

    lcd.drawText(0, 40, "tsselect:", SMLSIZE + LEFT)
    IVdraw(taskSelector, 84, 40, invers, SMLSIZE + RIGHT)

    lcd.drawText(0, 50, "timeedit:", SMLSIZE + LEFT)
    IVdraw(timeEdit, 84, 50, invers, SMLSIZE + RIGHT)
end

return {run=run, init=init }