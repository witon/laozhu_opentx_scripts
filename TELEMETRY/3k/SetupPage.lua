local varSliderSelector = nil
local readSwitchSelector = nil
local roundSwitchSelector = nil
local roundResetSwitchSelector = nil
local destTimeSettingStepNumEdit = nil
local operTimeEdit = nil
local testTimeEdit = nil
local viewMatrix = nil
    LZ_runModule(gScriptDir .. "TELEMETRY/common/ViewMatrix.lua")
    LZ_runModule(gScriptDir .. "TELEMETRY/common/InputView.lua")
    LZ_runModule(gScriptDir .. "TELEMETRY/common/InputSelector.lua")
    LZ_runModule(gScriptDir .. "TELEMETRY/common/NumEdit.lua")
    LZ_runModule(gScriptDir .. "TELEMETRY/common/TimeEdit.lua")
    LZ_runModule(gScriptDir .. "TELEMETRY/common/Fields.lua")
 
 
local function setCfgValue()
    f3kCfg["ReadSw"] = ISgetSelectedItemId(readSwitchSelector)
    f3kCfg["SelSlider"] = ISgetSelectedItemId(varSliderSelector)
    f3kCfg["RdSw"] = ISgetSelectedItemId(roundSwitchSelector)
    f3kCfg["RdResetSw"] = ISgetSelectedItemId(roundResetSwitchSelector)
    f3kCfg["DestTimeStep"] = destTimeSettingStepNumEdit.num
    f3kCfg["OperTime"] = operTimeEdit.num
    f3kCfg["TestTime"] = testTimeEdit.num
end

local function getCfgValue()
    ISsetSelectedItemById(readSwitchSelector, f3kCfg["ReadSw"])
    ISsetSelectedItemById(varSliderSelector, f3kCfg["SelSlider"])
    ISsetSelectedItemById(roundSwitchSelector, f3kCfg["RdSw"])
    ISsetSelectedItemById(roundResetSwitchSelector, f3kCfg["RdResetSw"])
    destTimeSettingStepNumEdit.num = CFGgetNumberField(f3kCfg, "DestTimeStep", 15)
    operTimeEdit.num = CFGgetNumberField(f3kCfg, "OperTime", 120)
    testTimeEdit.num = CFGgetNumberField(f3kCfg, "TestTime", 120)
end

local function onInputSelectorChange(selector)
    setCfgValue()
    CFGwriteToFile(f3kCfg, gConfigFileName)
end

local function onNumEditChange(numEdit)
    setCfgValue()
    CFGwriteToFile(f3kCfg, gConfigFileName)
end

local function destroy()
    VMunload()
    IVunload()
    ISunload()
    NEunload()
    TIMEEunload()
    FieldsUnload()
end

local function init()
   initFieldsInfo()

    varSliderSelector = ISnewInputSelector()
    ISsetFieldType(varSliderSelector, FIELDS_INPUT)
    ISsetOnChange(varSliderSelector, onInputSelectorChange)

    readSwitchSelector = ISnewInputSelector()
    ISsetFieldType(readSwitchSelector, FIELDS_SWITCH)
    ISsetOnChange(readSwitchSelector, onInputSelectorChange)

    roundSwitchSelector = ISnewInputSelector()
    ISsetFieldType(roundSwitchSelector, FIELDS_SWITCH)
    ISsetOnChange(roundSwitchSelector, onInputSelectorChange)

    roundResetSwitchSelector = ISnewInputSelector()
    ISsetFieldType(roundResetSwitchSelector, FIELDS_SWITCH)
    ISsetOnChange(roundResetSwitchSelector, onInputSelectorChange)


    destTimeSettingStepNumEdit = NEnewNumEdit()
    destTimeSettingStepNumEdit.step = 5
    NEsetRange(destTimeSettingStepNumEdit, 1, 60)
    NEsetOnChange(destTimeSettingStepNumEdit, onNumEditChange)

    operTimeEdit = TIMEEnewTimeEdit()
    NEsetRange(operTimeEdit, 0, 600)
    operTimeEdit.step = 5
    NEsetOnChange(operTimeEdit, onNumEditChange)

    testTimeEdit = TIMEEnewTimeEdit()
    NEsetRange(testTimeEdit, 0, 600)
    testTimeEdit.step = 5
    NEsetOnChange(testTimeEdit, onNumEditChange)

    viewMatrix = VMnewViewMatrix()
    local row = VMaddRow(viewMatrix)
    row[1] = destTimeSettingStepNumEdit
    row = VMaddRow(viewMatrix)
    row[1] = roundSwitchSelector
    row = VMaddRow(viewMatrix)
    row[1] = roundResetSwitchSelector
    row = VMaddRow(viewMatrix)
    row[1] = varSliderSelector
    row = VMaddRow(viewMatrix)
    row[1] = readSwitchSelector
    row = VMaddRow(viewMatrix)
    row[1] = operTimeEdit
    row = VMaddRow(viewMatrix)
    row[1] = testTimeEdit
    VMupdateCurIVFocus(viewMatrix)

    getCfgValue()
end

local function doKey(event)
    local eventProcessed = VMdoKey(viewMatrix, event)
    return eventProcessed
end

local function run(event, time)
    local invers = false
    if getRtcTime() % 2 == 1 then
        invers = true
    end
    local drawOptions
    lcd.drawText(0, 0, "Target Flight Time Step", SMLSIZE + LEFT)
    IVdraw(destTimeSettingStepNumEdit, 122, 0, invers, SMLSIZE + RIGHT)
    lcd.drawText(0, 9, "Round Start Switch", SMLSIZE + LEFT)
    IVdraw(roundSwitchSelector, 110, 9, invers, SMLSIZE + LEFT)
    lcd.drawText(0, 18, "Round Reset Switch", SMLSIZE + LEFT)
    IVdraw(roundResetSwitchSelector, 110, 18, invers, SMLSIZE + LEFT)
    lcd.drawText(0, 27, "Var Slider", SMLSIZE + LEFT)
    IVdraw(varSliderSelector, 110, 27, invers, SMLSIZE + LEFT)
    lcd.drawText(0, 36, "Read Switch", SMLSIZE + LEFT)
    IVdraw(readSwitchSelector, 110, 36, invers, SMLSIZE + LEFT)
    lcd.drawText(0, 45, "Oper Time", SMLSIZE + LEFT)
    IVdraw(operTimeEdit, 120, 45, invers, SMLSIZE + RIGHT)
    lcd.drawText(0, 54, "Test Time", SMLSIZE + LEFT)
    IVdraw(testTimeEdit, 120, 54, invers, SMLSIZE + RIGHT)
 
    return doKey(event)
end


return {run = run, init=init, destroy=destroy}