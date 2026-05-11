local viewMatrix = nil
local this = nil
local cfgButton = nil
local ldCfgPage = nil
local ldCfg = nil
local ldCfgFileName = "ld.cfg"
local eleGvNumEdit = nil
local flap1GvNumEdit = nil
local flap2GvNumEdit = nil
local ldState = nil
local altID = 0
local gpsID = 0
local ldRecord = nil
local recordListView = nil
local playingTone = false
local readVar = nil

-- 128px 屏设计坐标按 LCD_W 比例缩放（与 Launch / LRecordListView 同源）
local ldEleLabelX, ldEleValX, ldF1LabelX, ldF1ValX, ldF2LabelX, ldF2ValX
local ldStatVal1X, ldStatLab2X, ldStatVal2X, ldStatLab3X

local function initLDLayout()
    local s = LCD_W / 128
    ldEleLabelX = math.floor(0 * s)
    ldEleValX = math.floor(10 * s)
    ldF1LabelX = math.floor(35 * s)
    ldF1ValX = math.floor(50 * s)
    ldF2LabelX = math.floor(75 * s)
    ldF2ValX = math.floor(90 * s)
    ldStatVal1X = math.floor(40 * s)
    ldStatLab2X = math.floor(44 * s)
    ldStatVal2X = math.floor(76 * s)
    ldStatLab3X = math.floor(80 * s)
end

local function loadModule()
    LZ_runModule(gSDCardDir .. "LAOZHU/uilib/InputViewO.lua")
    LZ_runModule(gSDCardDir .. "LAOZHU/uilib/ViewMatrixO.lua")
    LZ_runModule(gSDCardDir .. "LAOZHU/uilib/ButtonO.lua")
    LZ_runModule(gSDCardDir .. "LAOZHU/uilib/NumEditO.lua")
    LZ_runModule(gSDCardDir .. "LAOZHU/DataFileDecode.lua")
    LZ_runModule(gSDCardDir .. "LAOZHU/CfgO.lua")
    LZ_runModule(gSDCardDir .. "LAOZHU/LDRecord.lua")
    LZ_runModule(gSDCardDir .. "LAOZHU/LDState.lua")
    LZ_runModule(gSDCardDir .. "LAOZHU/adjust/LD/LDRecordListView.lua")
    LZ_runModule(gSDCardDir .. "LAOZHU/comm/OTSound.lua")
end

local function unloadModule()
    ViewMatrix = nil
    Button = nil
    NumEdit = nil
    InputView = nil
    DFDunload()
    LDSunload()
    LDRecordListView = nil
    CFGC = nil
end

local function onNumEditChange(numEdit)
    local modeIndex = ldCfg:getNumberField("mode", -1)
    if modeIndex == -1 then
        return
    end
    LZ_setGVValue(numEdit.gvIndex, modeIndex, numEdit.num)
end

local function getGVValue()
    local modeIndex = ldCfg:getNumberField("mode", -1)
    if eleGvNumEdit then
        eleGvNumEdit.num = LZ_getGVValue(eleGvNumEdit.gvIndex, modeIndex)
    end
    if flap1GvNumEdit then
        flap1GvNumEdit.num = LZ_getGVValue(flap1GvNumEdit.gvIndex, modeIndex)
    end
    if flap2GvNumEdit then
        flap2GvNumEdit.num = LZ_getGVValue(flap2GvNumEdit.gvIndex, modeIndex)
    end
end

local function loadCfgPage()
    print("loadCfgPage")
    if ldCfgPage ~= nil then
        return
    end
    ldCfgPage = LZ_runModule(gSDCardDir .. "LAOZHU/adjust/LD/LDCfgPage.lua")
    ldCfgPage.setCfgFileName(ldCfgFileName)
    ldCfgPage.init()
end

local function unloadCfgPage()
    if ldCfgPage == nil then
        return
    end
    LZ_clearTable(ldCfgPage)
    ldCfgPage = nil
    collectgarbage()
end

local function onCfgButtonClick(button)
    loadCfgPage()
end


local function updateGvNumEdit()
    viewMatrix:clearCurIVFocus()
    local row = nil
    if viewMatrix:isEmpty() then
        viewMatrix:addRow()
        row = viewMatrix:addRow()
        row[1] = recordListView
    end
    viewMatrix:clearRow(1)
    row = viewMatrix.matrix[1]
    local eleGvIndex = ldCfg:getNumberField("elegv", -1)
    local flap1GvIndex = ldCfg:getNumberField("flap1gv", -1)
    local flap2GvIndex = ldCfg:getNumberField("flap2gv", -1)
    local modeIndex = ldCfg:getNumberField("mode", -1)

    if eleGvIndex ~= -1 and modeIndex ~= -1 then
        eleGvNumEdit = NumEdit:new()
        eleGvNumEdit:setOnChange(onNumEditChange)
        row[#row+1] = eleGvNumEdit
        eleGvNumEdit.gvIndex = eleGvIndex
    else
        eleGvNumEdit = nil
    end
    if flap1GvIndex ~= -1 and modeIndex ~= -1 then
        flap1GvNumEdit = NumEdit:new()
        flap1GvNumEdit:setOnChange(onNumEditChange)
        row[#row+1] = flap1GvNumEdit
        flap1GvNumEdit.gvIndex = flap1GvIndex
    else
        flap1GvNumEdit = nil
    end
    if flap2GvIndex ~= -1 and modeIndex ~= -1 then
        flap2GvNumEdit = NumEdit:new()
        flap2GvNumEdit:setOnChange(onNumEditChange)
        row[#row+1] = flap2GvNumEdit
        flap2GvNumEdit.gvIndex = flap2GvIndex
    else
        flap2GvNumEdit = nil
    end
    row[#row+1] = cfgButton
    viewMatrix.selectedRow = 1
    viewMatrix.selectedCol = 1
    viewMatrix:updateCurIVFocus()

end

local function onLDStateChange(state, isStart)
    if isStart then
        return
    end
    local ele = "-"
    if eleGvNumEdit then
        ele = eleGvNumEdit.num
    end
    local flap1 = "-"
    if flap1GvNumEdit then
        flap1 = flap1GvNumEdit.num
    end
    local flap2 = "-"
    if flap2GvNumEdit then
        flap2 = flap2GvNumEdit.num
    end
    local record = LDRaddOneRecord(ldRecord,
                    state.startTime,
                    state.startAlt,
                    state.startLon,
                    state.startLat,
                    state.stopTime,
                    state.stopAlt,
                    state.stopLon,
                    state.stopLat,
                    ele,
                    flap1,
                    flap2)
    LDRwriteOneRecordToFile(getDateTime(), record)
    LDSreset(state)
end


local function doKey(event)
    local ret = viewMatrix:doKey(event)
    if (not ret) and event == EVT_EXIT_BREAK then
        this.pageState = 1
        unloadModule()
    end
    return ret
end

local function draw(event, invers)
    if(viewMatrix.selectedRow > 1) then
        recordListView:draw(0, 0, invers, 0)
        return
    end

    local rs = LZ_ui.rowStep
    if eleGvNumEdit then
        lcd.drawText(ldEleLabelX, 0, "e:", LZ_ui.font + LEFT)
        eleGvNumEdit:draw(ldEleValX, 0, invers, LZ_ui.font + LEFT)
    end
    if flap1GvNumEdit then
        lcd.drawText(ldF1LabelX, 0, "f1:", LZ_ui.font + LEFT)
        flap1GvNumEdit:draw(ldF1ValX, 0, invers, LZ_ui.font + LEFT)
    end
    if flap2GvNumEdit then
        lcd.drawText(ldF2LabelX, 0, "f2:", LZ_ui.font + LEFT)
        flap2GvNumEdit:draw(ldF2ValX, 0, invers, LZ_ui.font + LEFT)
    end

    cfgButton:draw(LCD_W, 0, invers, LZ_ui.font + RIGHT)
    local yStat1 = rs
    local yStat2 = rs * 2
    lcd.drawText(0, yStat1, "dur:", LZ_ui.font + LEFT)
    lcd.drawText(ldStatVal1X, yStat1, LZ_formatTime(LDSgetCurDuration(ldState)), LZ_ui.font + RIGHT)
    lcd.drawText(ldStatLab2X, yStat1, "sink:", LZ_ui.font + LEFT)
    lcd.drawText(ldStatVal2X, yStat1, math.floor(LDSgetCurSinkAlt(ldState)), LZ_ui.font + RIGHT)
    lcd.drawText(ldStatLab3X, yStat1, "dist:", LZ_ui.font + LEFT)
    lcd.drawNumber(LCD_W - 1, yStat1, math.floor(LDSgetCurDistance(ldState)), LZ_ui.font + RIGHT)
    lcd.drawText(0, yStat2, "speed:", LZ_ui.font + LEFT)
    lcd.drawText(ldStatVal1X, yStat2, math.floor(LDSgetCurSpeed(ldState) * 10) / 10, LZ_ui.font + RIGHT)
    lcd.drawText(ldStatLab2X, yStat2, "ld:", LZ_ui.font + LEFT)
    lcd.drawText(ldStatVal2X, yStat2, math.floor(LDSgetCurLD(ldState) * 10) / 10, LZ_ui.font + RIGHT)
    lcd.drawText(ldStatLab3X, yStat2, "srate:", LZ_ui.font + LEFT)
    lcd.drawText(LCD_W - 1, yStat2, math.floor(LDSgetCurSinkRate(ldState) * 10) / 10, LZ_ui.font + RIGHT)
    recordListView:draw(0, rs * 3, invers, 0)
end

local function run(event, curTime)
    if ldCfgPage then
        if ldCfgPage.pageState == 1 then
            unloadCfgPage()
            updateGvNumEdit()
            getGVValue()
            return true
        end
        local processed = ldCfgPage.run(event, curTime)
        if processed then
            return true
        end
    end

    local testSwIndex = ldCfg:getNumberField("testsw", -1)
    local playTone = false
    if getRtcTime() % 6 == 1 then
        playTone = true
    end

    local invers = false
    if getRtcTime() % 2 == 1 then
        invers = true
    end

    if testSwIndex ~= -1 then
        local time = getRtcTime()
        local alt = 0
        if altID ~= -1 then
            alt = getValue(altID)
        end
        local lon, lat = 0, 0
        if gpsID ~= -1 then
            local gps = getValue(gpsID)
            if type(gps) == "table" and gps.lon ~= nil and gps.lat ~= nil then
                lon = gps.lon
                lat = gps.lat
            end
        end
        LDSrun(ldState, time, alt, lon, lat, getValue(testSwIndex))

        if LDSisStart(ldState) and playTone and playingTone == false then
            --playTone(1000, 100, 0, 0)
            LZ_playNumber(LDSgetCurLD(ldState), 0)
            playingTone = true
        end
        if not invers and playingTone then
            playingTone = false
        end


        local varSelectorSliderValue = getValue(ldCfg:getNumberField('SelSlider'))
        local varReadSwitchValue = getValue(ldCfg:getNumberField('ReadSw'))
        readVar.doReadVar(varSelectorSliderValue, varReadSwitchValue, curTime)
    end
    draw(event, invers)


    return doKey(event)
end



local function bg()

end

local function init()
    loadModule()
    ldState = LDSnewLDState()
    LDSsetOnStateChange(ldState, onLDStateChange)
    ldRecord = LDRnewLDRecord()
    LDRreadOneDayRecordsFromFile(ldRecord, getDateTime())


    viewMatrix = ViewMatrix:new()
    cfgButton = Button:new()
    cfgButton.text = "*"
    cfgButton:setOnClick(onCfgButtonClick)

    recordListView = LDRecordListView:new()
    recordListView.records = ldRecord.records

    ldCfg = CFGC:new()
    ldCfg:readFromFile(ldCfgFileName)

    updateGvNumEdit()
    getGVValue()
	altID = getTelemetryId("Alt")
    gpsID = getTelemetryId("GPS")
	readVar = LZ_runModule(gSDCardDir .. "LAOZHU/readVar.lua")
	local ldReadVarMap = LZ_runModule(gSDCardDir .. "LAOZHU/LDReadVarMap.lua")
	ldReadVarMap.ldState = ldState
	readVar.setVarMap(ldReadVarMap)
    initLDLayout()
end

init()

this = {run=run, bg=bg, pageState=0}

return this