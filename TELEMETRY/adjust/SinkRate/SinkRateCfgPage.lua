local viewMatrix = nil
local this = nil
local modeSelector = nil
local eleNumedit = nil
local flap1Numedit = nil
local flap2Numedit = nil
local testSwitchSelector = nil

local cfgFileName = nil
local sinkRateCfg = nil

local function setCfgFileName(fileName)
    cfgFileName = fileName
end

local function saveCfg()
    local cfgs = sinkRateCfg.getCfgs()
    cfgs['elegv'] = eleNumedit.num
    cfgs['flap1gv'] = flap1Numedit.num
    cfgs['flap2gv'] = flap2Numedit.num
    cfgs['mode'] = modeSelector.selectedIndex
    cfgs['testsw'] = ISgetSelectedItemId(testSwitchSelector)
    sinkRateCfg.writeToFile(cfgFileName)
end

local function newGVInput()
    local gvNumEdit = NEnewNumEdit()
    gvNumEdit.min = -1
    gvNumEdit.max = 8
    gvNumEdit.num = -1
    return gvNumEdit
end

local function init()
    sinkRateCfg = LZ_runModule(gScriptDir .. "LAOZHU/Cfg.lua")
    sinkRateCfg.readFromFile(cfgFileName)
    
    viewMatrix = VMnewViewMatrix()

    modeSelector = MSnewModeSelector()
    modeSelector.selectedIndex = sinkRateCfg.getNumberField("mode", -1)
    eleNumedit = newGVInput()
    eleNumedit.num = sinkRateCfg.getNumberField("elegv", -1)
    flap1Numedit = newGVInput()
    flap1Numedit.num = sinkRateCfg.getNumberField("flap1gv", -1)
    flap2Numedit = newGVInput()
    flap2Numedit.num = sinkRateCfg.getNumberField("flap2gv", -1)

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
    ISsetSelectedItemById(testSwitchSelector, sinkRateCfg.getNumberField("testsw", -1))
 
    vmRow = VMaddRow(viewMatrix)
    vmRow[1] = testSwitchSelector

    viewMatrix.selectedRow = 1
    viewMatrix.selectedCol = 1
    VMupdateCurIVFocus(viewMatrix)
end


local function doKey(event)
    viewMatrix.doKey(viewMatrix, event)
    if event == EVT_EXIT_BREAK then
        saveCfg()
        this.pageState = 1
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
    
    lcd.drawText(0, 10, "ele gv:", SMLSIZE + LEFT)
    IVdraw(eleNumedit, 64, 10, invers, SMLSIZE + LEFT)
 
    lcd.drawText(0, 20, "flap1 gv:", SMLSIZE + LEFT)
    IVdraw(flap1Numedit, 64, 20, invers, SMLSIZE + LEFT)
 
    lcd.drawText(0, 30, "flap2 gv:", SMLSIZE + LEFT)
    IVdraw(flap2Numedit, 64, 30, invers, SMLSIZE + LEFT)

    lcd.drawText(0, 40, "test switch:", SMLSIZE + LEFT)
    IVdraw(testSwitchSelector, 64, 40, invers, SMLSIZE + LEFT)
   return doKey(event)
end

local function bg()

end

this = {run=run, init=init, bg=bg, pageState=0, setCfgFileName=setCfgFileName}

return this