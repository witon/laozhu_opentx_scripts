gSDCardDir = "/"
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
    LZ_runModule(gSDCardDir .. "LAOZHU/uilib/TextEdit.lua")
    TEunload()
    LZ_runModule(gSDCardDir .. "LAOZHU/uilib/InputView.lua")
    IVunload()
    LZ_runModule(gSDCardDir .. "LAOZHU/uilib/Button.lua")
    BTunload()
    LZ_runModule(gSDCardDir .. "LAOZHU/uilib/CheckBox.lua")
    CBunload()
	LZ_runModule(gSDCardDir .. "LAOZHU/uilib/InputSelector.lua")
    ISunload()
	LZ_runModule(gSDCardDir .. "LAOZHU/uilib/Fields.lua")
	initFieldsInfo()
    FieldsUnload()
    LZ_runModule(gSDCardDir .. "LAOZHU/uilib/NumEdit.lua")
    NEunload()
    LZ_runModule(gSDCardDir .. "LAOZHU/uilib/OutputSelector.lua")
    OSunload()
	LZ_runModule(gSDCardDir .. "LAOZHU/uilib/CurveSelector.lua")
    CSunload()
	LZ_runModule(gSDCardDir .. "LAOZHU/uilib/Selector.lua")
    Sunload()
	LZ_runModule(gSDCardDir .. "LAOZHU/uilib/ModeSelector.lua")
    MSunload()
	LZ_runModule(gSDCardDir .. "LAOZHU/uilib/ViewMatrix.lua")
    VMunload()
	LZ_runModule(gSDCardDir .. "LAOZHU/uilib/TimeEdit.lua")
    TIMEEunload()

	LZ_runModule(gSDCardDir .. "LAOZHU/3k/TaskSelector.lua")
    TSunload()

end

local function initUI()
    testLoadAndUnload()
    LZ_runModule(gSDCardDir .. "LAOZHU/uilib/TextEdit.lua")
    LZ_runModule(gSDCardDir .. "LAOZHU/uilib/InputView.lua")
    LZ_runModule(gSDCardDir .. "LAOZHU/uilib/Button.lua")
    LZ_runModule(gSDCardDir .. "LAOZHU/uilib/CheckBox.lua")
	LZ_runModule(gSDCardDir .. "LAOZHU/uilib/InputSelector.lua")
	LZ_runModule(gSDCardDir .. "LAOZHU/uilib/Fields.lua")
	initFieldsInfo()
    LZ_runModule(gSDCardDir .. "LAOZHU/uilib/NumEdit.lua")
    LZ_runModule(gSDCardDir .. "LAOZHU/uilib/OutputSelector.lua")
	LZ_runModule(gSDCardDir .. "LAOZHU/uilib/CurveSelector.lua")
	LZ_runModule(gSDCardDir .. "LAOZHU/uilib/Selector.lua")
	LZ_runModule(gSDCardDir .. "LAOZHU/uilib/ModeSelector.lua")
	LZ_runModule(gSDCardDir .. "LAOZHU/uilib/ViewMatrix.lua")
	LZ_runModule(gSDCardDir .. "LAOZHU/3k/TaskSelector.lua")
	LZ_runModule(gSDCardDir .. "LAOZHU/uilib/TimeEdit.lua")
 
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
    local fun, err = loadScript(gSDCardDir .. "LAOZHU/uilib/LoadModule.lua", "bt")
    fun()
    curCases = LZ_runModule(gSDCardDir .. "SCRIPTS" .. testFiles[curFileIndex])
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
    local rs = LZ_ui.rowStep
    local midX = math.floor(LCD_W / 2)
    local pad = 1
    local gutter = 2
    local leftCtlR = midX - gutter
    local rightLbl = midX
    local rightCtlR = LCD_W - pad
    lcd.drawText(pad, 1, "CheckBox:", LZ_ui.font + LEFT)
    IVdraw(checkBox, leftCtlR, 1, invers, LZ_ui.font + RIGHT)
    lcd.drawText(rightLbl, 1, "TextEdit:", LZ_ui.font + LEFT)
    IVdraw(textEdit, rightCtlR, 1, invers, LZ_ui.font + RIGHT)

    lcd.drawText(pad, rs + 1, "Button:", LZ_ui.font + LEFT)
    IVdraw(button, leftCtlR, rs + 1, invers, LZ_ui.font + RIGHT)

    lcd.drawText(rightLbl, rs + 1, "ipselect:", LZ_ui.font + LEFT)
    IVdraw(inputSelector, rightCtlR, rs + 1, invers, LZ_ui.font + RIGHT)

    lcd.drawText(pad, 2 * rs + 1, "NumEdit:", LZ_ui.font + LEFT)
    IVdraw(numEdit, leftCtlR, 2 * rs + 1, invers, LZ_ui.font + RIGHT)

    lcd.drawText(rightLbl, 2 * rs + 1, "opselect:", LZ_ui.font + LEFT)
    IVdraw(outputSelector, rightCtlR, 2 * rs + 1, invers, LZ_ui.font + RIGHT)

    lcd.drawText(rightLbl, 3 * rs + 1, "csselect:", LZ_ui.font + LEFT)
    IVdraw(curveSelector, rightCtlR, 3 * rs + 1, invers, LZ_ui.font + RIGHT)

    lcd.drawText(pad, 3 * rs + 1, "mdselect:", LZ_ui.font + LEFT)
    IVdraw(modeSelector, leftCtlR, 3 * rs + 1, invers, LZ_ui.font + RIGHT)

    lcd.drawText(pad, 4 * rs + 1, "tsselect:", LZ_ui.font + LEFT)
    IVdraw(taskSelector, rightCtlR, 4 * rs + 1, invers, LZ_ui.font + RIGHT)

    lcd.drawText(pad, 5 * rs + 1, "timeedit:", LZ_ui.font + LEFT)
    IVdraw(timeEdit, rightCtlR, 5 * rs + 1, invers, LZ_ui.font + RIGHT)
end

return {run=run, init=init }