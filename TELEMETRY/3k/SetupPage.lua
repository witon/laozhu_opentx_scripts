local varSliderSelector = nil
local readSwitchSelector = nil
local roundSwitchSelector = nil
local roundResetSwitchSelector = nil
local viewMatrix = nil
LZ_runModule(gScriptDir .. "TELEMETRY/common/ViewMatrixO.lua")
LZ_runModule(gScriptDir .. "TELEMETRY/common/InputViewO.lua")
LZ_runModule(gScriptDir .. "TELEMETRY/common/SelectorO.lua")
LZ_runModule(gScriptDir .. "TELEMETRY/common/InputSelectorO.lua")
LZ_runModule(gScriptDir .. "TELEMETRY/common/Fields.lua")

 
local function setCfgValue()
    local kvs = f3kCfg.kvs
    kvs["ReadSw"] = readSwitchSelector:getSelectedItemId()
    kvs["SelSlider"] = varSliderSelector:getSelectedItemId()
    kvs["RdSw"] = roundSwitchSelector:getSelectedItemId()
    kvs["RdResetSw"] = roundResetSwitchSelector:getSelectedItemId()
end

local function getCfgValue()
    local kvs = f3kCfg.kvs
    readSwitchSelector:setSelectedItemById(kvs["ReadSw"])
    varSliderSelector:setSelectedItemById(kvs["SelSlider"])
    roundSwitchSelector:setSelectedItemById(kvs["RdSw"])
    roundResetSwitchSelector:setSelectedItemById(kvs["RdResetSw"])
end

local function onInputSelectorChange(selector)
    setCfgValue()
    f3kCfg:writeToFile(gConfigFileName)
end


local function destroy()
    ViewMatrix = nil
    InputView = nil
    InputSelector = nil
    Selector = nil
    FieldsUnload()
end

local function init()
   initFieldsInfo()

    varSliderSelector = InputSelector:new()
    varSliderSelector:setFieldType(FIELDS_INPUT)
    varSliderSelector:setOnChange(onInputSelectorChange)

    readSwitchSelector = InputSelector:new()
    readSwitchSelector:setFieldType(FIELDS_SWITCH)
    readSwitchSelector:setOnChange(onInputSelectorChange)

    roundSwitchSelector = InputSelector:new()
    roundSwitchSelector:setFieldType(FIELDS_SWITCH)
    roundSwitchSelector:setOnChange(onInputSelectorChange)

    roundResetSwitchSelector = InputSelector:new()
    roundResetSwitchSelector:setFieldType(FIELDS_SWITCH)
    roundResetSwitchSelector:setOnChange(onInputSelectorChange)

    viewMatrix = ViewMatrix:new()
    local row = viewMatrix:addRow()
    row[1] = roundSwitchSelector
    row = viewMatrix:addRow()
    row[1] = roundResetSwitchSelector
    row = viewMatrix:addRow()
    row[1] = varSliderSelector
    row = viewMatrix:addRow()
    row[1] = readSwitchSelector
    viewMatrix:updateCurIVFocus()

    getCfgValue()
end

local function doKey(event)
    local eventProcessed = viewMatrix:doKey(event)
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
    roundSwitchSelector:draw(128, 10, invers, SMLSIZE + RIGHT)
    lcd.drawText(0, 19, "Round Reset Switch", SMLSIZE + LEFT)
    roundResetSwitchSelector:draw(128, 19, invers, SMLSIZE + RIGHT)
    lcd.drawText(0, 28, "Var Slider", SMLSIZE + LEFT)
    varSliderSelector:draw(128, 28, invers, SMLSIZE + RIGHT)
    lcd.drawText(0, 37, "Read Switch", SMLSIZE + LEFT)
    readSwitchSelector:draw(128, 37, invers, SMLSIZE + RIGHT)
 
    return doKey(event)
end


return {run = run, init=init, destroy=destroy}