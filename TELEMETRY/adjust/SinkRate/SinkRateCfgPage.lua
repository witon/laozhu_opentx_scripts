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
local sinkRateCfg = nil

local function loadModule()
    LZ_runModule("TELEMETRY/common/Selector.lua")
    LZ_runModule("TELEMETRY/common/ModeSelector.lua")
    LZ_runModule("TELEMETRY/common/InputSelector.lua")
    LZ_runModule("TELEMETRY/common/Fields.lua")
    initFieldsInfo()
end

local function unloadModule()
    MSunload()
    Sunload()
    ISunload()
    FieldsUnload()
end

local function setCfgFileName(fileName)
    cfgFileName = fileName
end

local function saveCfg()
    local kvs = sinkRateCfg.kvs
    kvs['elegv'] = eleNumedit.num
    kvs['flap1gv'] = flap1Numedit.num
    kvs['flap2gv'] = flap2Numedit.num
    kvs['mode'] = modeSelector.selectedIndex
    kvs['testsw'] = ISgetSelectedItemId(testSwitchSelector)
    kvs["ReadSw"] = ISgetSelectedItemId(readSwitchSelector)
    kvs["SelSlider"] = ISgetSelectedItemId(varSliderSelector)
    sinkRateCfg:writeToFile(cfgFileName)
end

local function newGVInput()
    local gvNumEdit = NEnewNumEdit()
    gvNumEdit.min = -1
    gvNumEdit.max = 8
    gvNumEdit.num = -1
    return gvNumEdit
end

local function init()
    loadModule()
    sinkRateCfg = CFGC:new()
    sinkRateCfg:readFromFile(cfgFileName)
    
    viewMatrix = VMnewViewMatrix()

    modeSelector = MSnewModeSelector()
    modeSelector.selectedIndex = sinkRateCfg:getNumberField("mode", -1)
    eleNumedit = newGVInput()
    eleNumedit.num = sinkRateCfg:getNumberField("elegv", -1)
    flap1Numedit = newGVInput()
    flap1Numedit.num = sinkRateCfg:getNumberField("flap1gv", -1)
    flap2Numedit = newGVInput()
    flap2Numedit.num = sinkRateCfg:getNumberField("flap2gv", -1)

    local vmRow = VMaddRow(viewMatrix)
    vmRow[1] = modeSelector

    vmRow = VMaddRow(viewMatrix)
    vmRow[1] = eleNumedit

    vmRow = VMaddRow(viewMatrix)
    vmRow[1] = flap1Numedit

    vmRow = VMaddRow(viewMatrix)
    vmRow[1] = flap2Numedit

    testSwitchSelector = ISnewInputSelector()
    ISsetFieldType(testSwitchSelector, FIELDS_SWITCH)
    ISsetSelectedItemById(testSwitchSelector, sinkRateCfg:getNumberField("testsw", -1))
    vmRow = VMaddRow(viewMatrix)
    vmRow[1] = testSwitchSelector

    readSwitchSelector = ISnewInputSelector()
    ISsetFieldType(readSwitchSelector, FIELDS_SWITCH)
    ISsetSelectedItemById(readSwitchSelector, sinkRateCfg:getNumberField("ReadSw", -1))
    vmRow = VMaddRow(viewMatrix)
    vmRow[1] = readSwitchSelector

    varSliderSelector = ISnewInputSelector()
    ISsetFieldType(varSliderSelector, FIELDS_INPUT)
    ISsetSelectedItemById(varSliderSelector, sinkRateCfg:getNumberField("SelSlider", -1))
    vmRow = VMaddRow(viewMatrix)
    vmRow[1] = varSliderSelector

    viewMatrix.selectedRow = 1
    viewMatrix.selectedCol = 1
    VMupdateCurIVFocus(viewMatrix)
end


local function doKey(event)
    viewMatrix.doKey(viewMatrix, event)
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
    IVdraw(modeSelector, 64, 0, invers, SMLSIZE + LEFT)

    lcd.drawText(0, 9, "ele gv:", SMLSIZE + LEFT)
    IVdraw(eleNumedit, 64, 9, invers, SMLSIZE + LEFT)

    lcd.drawText(0, 18, "flap1 gv:", SMLSIZE + LEFT)
    IVdraw(flap1Numedit, 64, 18, invers, SMLSIZE + LEFT)

    lcd.drawText(0, 27, "flap2 gv:", SMLSIZE + LEFT)
    IVdraw(flap2Numedit, 64, 27, invers, SMLSIZE + LEFT)

    lcd.drawText(0, 36, "test switch:", SMLSIZE + LEFT)
    IVdraw(testSwitchSelector, 64, 36, invers, SMLSIZE + LEFT)

    lcd.drawText(0, 45, "read switch:", SMLSIZE + LEFT)
    IVdraw(readSwitchSelector, 64, 45, invers, SMLSIZE + LEFT)
    lcd.drawText(0, 54, "select slider:", SMLSIZE + LEFT)
    IVdraw(varSliderSelector, 64, 54, invers, SMLSIZE + LEFT)
 
    return doKey(event)
end

local function bg()

end

this = {run=run, init=init, bg=bg, pageState=0, setCfgFileName=setCfgFileName}

return this