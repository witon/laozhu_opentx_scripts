local viewMatrix = nil
local this = nil
local cfgButton = nil
local sinkRateCfgPage = nil
local sinkRateCfg = nil
local sinkRateCfgFileName = "sinkrate.cfg"
local eleGvNumEdit = nil
local flap1GvNumEdit = nil
local flap2GvNumEdit = nil
local sinkRateState = nil
local altID = 0
local sinkRateRecord = nil
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
    LZ_runModule("/LAOZHU/SinkRateRecord.lua")
    LZ_runModule("/LAOZHU/SinkRateState.lua")
    LZ_runModule("/TELEMETRY/adjust/SinkRate/SRRecordListView.lua")
    LZ_runModule("/LAOZHU/comm/OTSound.lua")
end

local function unloadModule()
    ViewMatrix = nil
    Button = nil
    NumEdit = nil
    InputView = nil
    DFDunload()
    SRRunload()
    SRSunload()
    SRRecordListView = nil
    CFGC = nil
end

local function onNumEditChange(numEdit)
    local modeIndex = sinkRateCfg:getNumberField("mode", -1)
    if modeIndex == -1 then
        return
    end
    LZ_setGVValue(numEdit.gvIndex, modeIndex, numEdit.num)
end

local function getGVValue()
    local modeIndex = sinkRateCfg:getNumberField("mode", -1)
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
    if sinkRateCfgPage ~= nil then
        return
    end
    sinkRateCfgPage = LZ_runModule("TELEMETRY/adjust/SinkRate/SinkRateCfgPage.lua")
    sinkRateCfgPage.setCfgFileName(sinkRateCfgFileName)
    sinkRateCfgPage.init()
end

local function unloadCfgPage()
    if sinkRateCfgPage == nil then
        return
    end
    LZ_clearTable(sinkRateCfgPage)
    sinkRateCfgPage = nil
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
    local eleGvIndex = sinkRateCfg:getNumberField("elegv", -1)
    local flap1GvIndex = sinkRateCfg:getNumberField("flap1gv", -1)
    local flap2GvIndex = sinkRateCfg:getNumberField("flap2gv", -1)
    local modeIndex = sinkRateCfg:getNumberField("mode", -1)

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

local function onSinkRateStateChange(state, isStart)
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
    local record = SRRaddOneRecord(sinkRateRecord,
                    state.startTime,
                    state.startAlt,
                    state.stopTime,
                    state.stopAlt,
                    ele,
                    flap1,
                    flap2)
    SRRwriteOneRecordToFile(getDateTime(), record)
    SRSreset(state)
end


local function doKey(event)
    local ret = viewMatrix:doKey(event)
    if (not ret) and event == EVT_EXIT_BREAK then
        this.pageState = 1
        unloadModule()
    end
    return ret
end

local function run(event, curTime)
    if sinkRateCfgPage then
        if sinkRateCfgPage.pageState == 1 then
            unloadCfgPage()
            updateGvNumEdit()
            getGVValue()
            return true
        end
        local processed = sinkRateCfgPage.run(event, time)
        if processed then
            return true
        end
    end

    local invers = false
    if getRtcTime() % 2 == 1 then
        invers = true
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

    local testSwIndex = sinkRateCfg:getNumberField("testsw", -1)
    local playTone = false
    if getRtcTime() % 4 == 1 then
        playTone = true
    end
    if testSwIndex ~= -1 then
        local time = getRtcTime()
        local alt = getValue(altID)
        SRSrun(sinkRateState, time, alt, getValue(testSwIndex))

        if SRSisStart(sinkRateState) and playTone and playingTone == false then
            --playTone(1000, 100, 0, 0)
            LZ_playNumber(SRSgetCurSinkRate(sinkRateState)*100, 0)
            playingTone = true
        end
        if not invers and playingTone then
            playingTone = false
        end

        lcd.drawText(0, 10, "dur:", SMLSIZE + LEFT)
        lcd.drawText(40, 10, LZ_formatTime(SRSgetCurDuration(sinkRateState)), SMLSIZE + RIGHT)
        lcd.drawText(44, 10, "sink:", SMLSIZE + LEFT)
        lcd.drawText(76, 10, math.floor(SRSgetCurSinkAlt(sinkRateState)), SMLSIZE + RIGHT)
        lcd.drawText(80, 10, "srate:", SMLSIZE + LEFT)
        lcd.drawNumber(128, 10, SRSgetCurSinkRate(sinkRateState)*100, SMLSIZE + RIGHT)

        local varSelectorSliderValue = getValue(sinkRateCfg:getNumberField('SelSlider'))
        local varReadSwitchValue = getValue(sinkRateCfg:getNumberField('ReadSw'))
        readVar.doReadVar(varSelectorSliderValue, varReadSwitchValue, curTime)
 
    end



    recordListView:draw(0, 19, invers, 0)
    return doKey(event)
end

local function bg()

end

local function init()
    loadModule()
    sinkRateState = SRSnewSinkRateState()
    SRSsetOnStateChange(sinkRateState, onSinkRateStateChange)
    sinkRateRecord = SRRnewSinkRateRecord()
    SRRreadOneDayRecordsFromFile(sinkRateRecord, getDateTime())


    viewMatrix = ViewMatrix:new()
    cfgButton = Button:new()
    cfgButton.text = "*"
    cfgButton:setOnClick(onCfgButtonClick)

    recordListView = SRRecordListView:new()
    recordListView.records = sinkRateRecord.records

    sinkRateCfg = CFGC:new()
    sinkRateCfg:readFromFile(sinkRateCfgFileName)

    updateGvNumEdit()
    getGVValue()
	altID = getTelemetryId("Alt")
	readVar = LZ_runModule("LAOZHU/readVar.lua")
	local sinkRateReadVarMap = LZ_runModule("LAOZHU/sinkRateReadVarMap.lua")
	sinkRateReadVarMap.sinkRateState = sinkRateState
	readVar.setVarMap(sinkRateReadVarMap)
end

init()

this = {run=run, bg=bg, pageState=0}

return this