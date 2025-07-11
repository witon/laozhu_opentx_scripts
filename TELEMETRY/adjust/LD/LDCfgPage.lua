local viewMatrix = nil
local this = nil
local modeSelector = nil
local eleNumedit = nil
local flap1Numedit = nil
local flap2Numedit = nil
local testSwitchSelector = nil
local readSwitchSelector = nil
local varSliderSelector = nil

local cfgFileName = nil
local ldCfg = nil

local function loadModule()
    LZ_runModule("TELEMETRY/common/SelectorO.lua")
    LZ_runModule("TELEMETRY/common/ModeSelectorO.lua")
    LZ_runModule("TELEMETRY/common/InputSelectorO.lua")
    LZ_runModule("TELEMETRY/common/Fields.lua")
    initFieldsInfo()
end

local function unloadModule()
    Selector = nil
    ModeSelector = nil
    InputSelector = nil
    FieldsUnload()
end

local function setCfgFileName(fileName)
    cfgFileName = fileName
end

local function saveCfg()
    local kvs = ldCfg.kvs
    kvs['elegv'] = eleNumedit.num
    kvs['flap1gv'] = flap1Numedit.num
    kvs['flap2gv'] = flap2Numedit.num
    kvs['mode'] = modeSelector.selectedIndex
    kvs['testsw'] = testSwitchSelector:getSelectedItemId()
    kvs["ReadSw"] = readSwitchSelector:getSelectedItemId()
    kvs["SelSlider"] = varSliderSelector:getSelectedItemId()
    ldCfg:writeToFile(cfgFileName)
end

local function newGVInput()
    local gvNumEdit = NumEdit:new()
    gvNumEdit.min = -1
    gvNumEdit.max = 8
    gvNumEdit.num = -1
    return gvNumEdit
end

local function init()
    loadModule()
    ldCfg = CFGC:new()
    ldCfg:readFromFile(cfgFileName)
    
    viewMatrix = ViewMatrix:new()

    modeSelector = ModeSelector:new()
    modeSelector.selectedIndex = ldCfg:getNumberField("mode", -1)
    eleNumedit = newGVInput()
    eleNumedit.num = ldCfg:getNumberField("elegv", -1)
    flap1Numedit = newGVInput()
    flap1Numedit.num = ldCfg:getNumberField("flap1gv", -1)
    flap2Numedit = newGVInput()
    flap2Numedit.num = ldCfg:getNumberField("flap2gv", -1)

    local vmRow = viewMatrix:addRow()
    vmRow[1] = modeSelector

    vmRow = viewMatrix:addRow()
    vmRow[1] = eleNumedit

    vmRow = viewMatrix:addRow()
    vmRow[1] = flap1Numedit

    vmRow = viewMatrix:addRow()
    vmRow[1] = flap2Numedit

    testSwitchSelector = InputSelector:new()
    testSwitchSelector:setFieldType(FIELDS_SWITCH)
    testSwitchSelector:setSelectedItemById(ldCfg:getNumberField("testsw", -1))
    vmRow = viewMatrix:addRow()
    vmRow[1] = testSwitchSelector

    readSwitchSelector = InputSelector:new()
    readSwitchSelector:setFieldType(FIELDS_SWITCH)
    readSwitchSelector:setSelectedItemById(ldCfg:getNumberField("ReadSw", -1))
    vmRow = viewMatrix:addRow()
    vmRow[1] = readSwitchSelector

    varSliderSelector = InputSelector:new()
    varSliderSelector:setFieldType(FIELDS_INPUT)
    varSliderSelector:setSelectedItemById(ldCfg:getNumberField("SelSlider", -1))
    vmRow = viewMatrix:addRow()
    vmRow[1] = varSliderSelector

    viewMatrix.selectedRow = 1
    viewMatrix.selectedCol = 1
    viewMatrix:updateCurIVFocus()
 
end


local function doKey(event)
    local ret = viewMatrix:doKey(event)
    if event == EVT_EXIT_BREAK then
        saveCfg()
        this.pageState = 1
        unloadModule()
    end
    return true
end
local function run(event, time)
    local invers = false
    if getRtcTime() % 2 == 1 then
        invers = true
    end
    lcd.drawText(0, 0, "mode:", SMLSIZE + LEFT)
    modeSelector:draw(64, 0, invers, SMLSIZE + LEFT)

    lcd.drawText(0, 9, "ele gv:", SMLSIZE + LEFT)
    eleNumedit:draw(64, 9, invers, SMLSIZE + LEFT)

    lcd.drawText(0, 18, "flap1 gv:", SMLSIZE + LEFT)
    flap1Numedit:draw(64, 18, invers, SMLSIZE + LEFT)

    lcd.drawText(0, 27, "flap2 gv:", SMLSIZE + LEFT)
    flap2Numedit:draw(64, 27, invers, SMLSIZE + LEFT)

    lcd.drawText(0, 36, "test switch:", SMLSIZE + LEFT)
    testSwitchSelector:draw(64, 36, invers, SMLSIZE + LEFT)

    lcd.drawText(0, 45, "read switch:", SMLSIZE + LEFT)
    readSwitchSelector:draw(64, 45, invers, SMLSIZE + LEFT)
    lcd.drawText(0, 54, "select slider:", SMLSIZE + LEFT)
    varSliderSelector:draw(64, 54, invers, SMLSIZE + LEFT)
 
    return doKey(event)
end

local function bg()

end

this = {run=run, init=init, bg=bg, pageState=0, setCfgFileName=setCfgFileName}

return this