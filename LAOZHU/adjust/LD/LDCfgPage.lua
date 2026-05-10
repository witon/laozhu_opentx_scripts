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
local lineArray = nil
local maxLines = nil

local function loadModule()
    LZ_runModule(gSDCardDir .. "LAOZHU/uilib/SelectorO.lua")
    LZ_runModule(gSDCardDir .. "LAOZHU/uilib/ModeSelectorO.lua")
    LZ_runModule(gSDCardDir .. "LAOZHU/uilib/InputSelectorO.lua")
    LZ_runModule(gSDCardDir .. "LAOZHU/uilib/Fields.lua")
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
    viewMatrix.scrollLine = 0
    viewMatrix:updateCurIVFocus()

    lineArray = {
        { "mode:", modeSelector },
        { "ele gv:", eleNumedit },
        { "flap1 gv:", flap1Numedit },
        { "flap2 gv:", flap2Numedit },
        { "test switch:", testSwitchSelector },
        { "read switch:", readSwitchSelector },
        { "select slider:", varSliderSelector },
    }
    local rs = LZ_ui.rowStep
    local hh = LZ_ui.headerRowHeight
    maxLines = math.min(#lineArray, math.max(1, math.floor((LCD_H - hh - 1) / rs)))
    viewMatrix.visibleRows = maxLines
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
    local rs = LZ_ui.rowStep
    local hh = LZ_ui.headerRowHeight
    lcd.drawFilledRectangle(0, 0, LCD_W, hh, FORCE)
    lcd.drawText(0, 0, "LD Cfg", LZ_ui.font + LEFT + INVERS)
    local y = hh + 1
    local lastLine = math.min(#lineArray, viewMatrix.scrollLine + maxLines)
    for i = viewMatrix.scrollLine + 1, lastLine, 1 do
        lcd.drawText(0, y, lineArray[i][1], LZ_ui.font + LEFT)
        lineArray[i][2]:draw(LCD_W, y, invers, LZ_ui.font + RIGHT)
        y = y + rs
    end
    return doKey(event)
end

local function bg()

end

this = {run=run, init=init, bg=bg, pageState=0, setCfgFileName=setCfgFileName}

return this