local varSliderSelector = nil
local readSwitchSelector = nil
local roundSwitchSelector = nil
local roundResetSwitchSelector = nil
local viewMatrix = nil
LZ_runModule(gSDCardDir .. "LAOZHU/uilib/ViewMatrixO.lua")
LZ_runModule(gSDCardDir .. "LAOZHU/uilib/InputViewO.lua")
LZ_runModule(gSDCardDir .. "LAOZHU/uilib/SelectorO.lua")
LZ_runModule(gSDCardDir .. "LAOZHU/uilib/InputSelectorO.lua")
LZ_runModule(gSDCardDir .. "LAOZHU/uilib/Fields.lua")

 
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

    local rs = LZ_ui.rowStep
    lcd.drawFilledRectangle(0, 0, 128, rs, FORCE)
    lcd.drawText(0, 0, "Switch Setup", LZ_ui.font + LEFT + INVERS)
    lcd.drawText(0, rs + 1, "Round Start Switch", LZ_ui.font + LEFT)
    roundSwitchSelector:draw(128, rs + 1, invers, LZ_ui.font + RIGHT)
    lcd.drawText(0, 2 * rs + 1, "Round Reset Switch", LZ_ui.font + LEFT)
    roundResetSwitchSelector:draw(128, 2 * rs + 1, invers, LZ_ui.font + RIGHT)
    lcd.drawText(0, 3 * rs + 1, "Var Slider", LZ_ui.font + LEFT)
    varSliderSelector:draw(128, 3 * rs + 1, invers, LZ_ui.font + RIGHT)
    lcd.drawText(0, 4 * rs + 1, "Read Switch", LZ_ui.font + LEFT)
    readSwitchSelector:draw(128, 4 * rs + 1, invers, LZ_ui.font + RIGHT)
 
    return doKey(event)
end

init()

return {run = run, destroy=destroy}