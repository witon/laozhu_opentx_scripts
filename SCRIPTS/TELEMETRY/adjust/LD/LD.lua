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
local function loadModule()
    LZ_runModule("TELEMETRY/common/InputViewO.lua")
    LZ_runModule("TELEMETRY/common/ViewMatrixO.lua")
    LZ_runModule("TELEMETRY/common/ButtonO.lua")
    LZ_runModule("TELEMETRY/common/NumEditO.lua")
    LZ_runModule("LAOZHU/DataFileDecode.lua")
    LZ_runModule("LAOZHU/CfgO.lua")
    LZ_runModule("/LAOZHU/LDRecord.lua")
    LZ_runModule("/LAOZHU/LDState.lua")
    LZ_runModule("/TELEMETRY/adjust/LD/LDRecordListView.lua")
    LZ_runModule("/LAOZHU/comm/OTSound.lua")
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
    ldCfgPage = LZ_runModule("TELEMETRY/adjust/LD/LDCfgPage.lua")
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

    if eleGvNumEdit then
        lcd.drawText(0, 0, "e:", LEFT)
        eleGvNumEdit:draw(10, 0, invers, LEFT)
    end
    if flap1GvNumEdit then
        lcd.drawText(35, 0, "f1:", LEFT)
        flap1GvNumEdit:draw(50, 0, invers, LEFT) --54
    end
    if flap2GvNumEdit then
        lcd.drawText(75, 0, "f2:", LEFT)
        flap2GvNumEdit:draw(90, 0, invers, LEFT)
    end

    cfgButton:draw(127, 0, invers, RIGHT)
    lcd.drawText(0, 10, "dur:", SMLSIZE + LEFT)
    lcd.drawText(40, 10, LZ_formatTime(LDSgetCurDuration(ldState)), SMLSIZE + RIGHT)
    lcd.drawText(44, 10, "sink:", SMLSIZE + LEFT)
    lcd.drawText(76, 10, math.floor(LDSgetCurSinkAlt(ldState)), SMLSIZE + RIGHT)
    lcd.drawText(80, 10, "dist:", SMLSIZE + LEFT)
    lcd.drawNumber(128, 10, math.floor(LDSgetCurDistance(ldState)), SMLSIZE + RIGHT)
    lcd.drawText(0, 19, "speed:", SMLSIZE + LEFT)
    lcd.drawText(40, 19, math.floor(LDSgetCurSpeed(ldState)*10)/10, SMLSIZE + RIGHT)
    lcd.drawText(44, 19, "ld:", SMLSIZE + LEFT)
    lcd.drawText(76, 19, math.floor(LDSgetCurLD(ldState)*10)/10, SMLSIZE + RIGHT)
    lcd.drawText(80, 19, "srate:", SMLSIZE + LEFT)
    lcd.drawText(128, 19, math.floor(LDSgetCurSinkRate(ldState)*10)/10, SMLSIZE + RIGHT)
    recordListView:draw(0, 29, invers, 0)
end

local function run(event, curTime)
    if ldCfgPage then
        if ldCfgPage.pageState == 1 then
            unloadCfgPage()
            updateGvNumEdit()
            getGVValue()
            return true
        end
        local processed = ldCfgPage.run(event, time)
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
        local alt = getValue(altID)
        local gps = getValue(gpsID)
        if(gps ~= nil and gps ~= 0) then
            LDSrun(ldState, time, alt, gps.lon, gps.lat, getValue(testSwIndex))
        else
            LDSrun(ldState, time, alt, 0, 0, getValue(testSwIndex))
        end

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
	readVar = LZ_runModule("LAOZHU/readVar.lua")
	local ldReadVarMap = LZ_runModule("LAOZHU/LDReadVarMap.lua")
	ldReadVarMap.ldState = ldState
	readVar.setVarMap(ldReadVarMap)
end

init()

this = {run=run, bg=bg, pageState=0}

return this