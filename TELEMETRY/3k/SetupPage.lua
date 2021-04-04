local varSliderSelector = nil
local readSwitchSelector = nil
local roundSwitchSelector = nil
local roundResetSwitchSelector = nil
local viewMatrix = nil
LZ_runModule(gScriptDir .. "TELEMETRY/common/ViewMatrix.lua")
LZ_runModule(gScriptDir .. "TELEMETRY/common/InputView.lua")
LZ_runModule(gScriptDir .. "TELEMETRY/common/InputSelector.lua")
LZ_runModule(gScriptDir .. "TELEMETRY/common/Fields.lua")

 
local function setCfgValue()
    f3kCfg["ReadSw"] = ISgetSelectedItemId(readSwitchSelector)
    f3kCfg["SelSlider"] = ISgetSelectedItemId(varSliderSelector)
    f3kCfg["RdSw"] = ISgetSelectedItemId(roundSwitchSelector)
    f3kCfg["RdResetSw"] = ISgetSelectedItemId(roundResetSwitchSelector)
end

local function getCfgValue()
    ISsetSelectedItemById(readSwitchSelector, f3kCfg["ReadSw"])
    ISsetSelectedItemById(varSliderSelector, f3kCfg["SelSlider"])
    ISsetSelectedItemById(roundSwitchSelector, f3kCfg["RdSw"])
    ISsetSelectedItemById(roundResetSwitchSelector, f3kCfg["RdResetSw"])
end

local function onInputSelectorChange(selector)
    setCfgValue()
    CFGwriteToFile(f3kCfg, gConfigFileName)
end


local function destroy()
    VMunload()
    IVunload()
    ISunload()
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

    viewMatrix = VMnewViewMatrix()
    local row = VMaddRow(viewMatrix)
    row[1] = roundSwitchSelector
    row = VMaddRow(viewMatrix)
    row[1] = roundResetSwitchSelector
    row = VMaddRow(viewMatrix)
    row[1] = varSliderSelector
    row = VMaddRow(viewMatrix)
    row[1] = readSwitchSelector
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

    lcd.drawFilledRectangle(0, 0, 128, 8, FORCE)
    lcd.drawText(0, 0, "Switch Setup", SMLSIZE + LEFT + INVERS)
    lcd.drawText(0, 10, "Round Start Switch", SMLSIZE + LEFT)
    IVdraw(roundSwitchSelector, 128, 10, invers, SMLSIZE + RIGHT)
    lcd.drawText(0, 19, "Round Reset Switch", SMLSIZE + LEFT)
    IVdraw(roundResetSwitchSelector, 128, 19, invers, SMLSIZE + RIGHT)
    lcd.drawText(0, 28, "Var Slider", SMLSIZE + LEFT)
    IVdraw(varSliderSelector, 128, 28, invers, SMLSIZE + RIGHT)
    lcd.drawText(0, 37, "Read Switch", SMLSIZE + LEFT)
    IVdraw(readSwitchSelector, 128, 37, invers, SMLSIZE + RIGHT)
 
    return doKey(event)
end


return {run = run, init=init, destroy=destroy}