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

-- 128px 屏设计坐标按 LCD_W 比例缩放（与 Launch / LRecordListView 同源）
local srEleLabelX, srEleValX, srF1LabelX, srF1ValX, srF2LabelX, srF2ValX
local srStatVal1X, srStatLab2X, srStatVal2X, srStatLab3X

local function initSinkRateLayout()
    local s = LCD_W / 128
    srEleLabelX = math.floor(0 * s)
    srEleValX = math.floor(10 * s)
    srF1LabelX = math.floor(35 * s)
    srF1ValX = math.floor(50 * s)
    srF2LabelX = math.floor(75 * s)
    srF2ValX = math.floor(90 * s)
    srStatVal1X = math.floor(40 * s)
    srStatLab2X = math.floor(44 * s)
    srStatVal2X = math.floor(76 * s)
    srStatLab3X = math.floor(80 * s)
end

local function loadModule()
    LZ_runModule(gSDCardDir .. "LAOZHU/uilib/InputViewO.lua")
    LZ_runModule(gSDCardDir .. "LAOZHU/uilib/ViewMatrixO.lua")
    LZ_runModule(gSDCardDir .. "LAOZHU/uilib/ButtonO.lua")
    LZ_runModule(gSDCardDir .. "LAOZHU/uilib/NumEditO.lua")
    LZ_runModule(gSDCardDir .. "LAOZHU/DataFileDecode.lua")
    LZ_runModule(gSDCardDir .. "LAOZHU/CfgO.lua")
    LZ_runModule(gSDCardDir .. "LAOZHU/SinkRateRecord.lua")
    LZ_runModule(gSDCardDir .. "LAOZHU/SinkRateState.lua")
    LZ_runModule(gSDCardDir .. "LAOZHU/adjust/SinkRate/SRRecordListView.lua")
    LZ_runModule(gSDCardDir .. "LAOZHU/comm/OTSound.lua")
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
    sinkRateCfgPage = LZ_runModule(gSDCardDir .. "LAOZHU/adjust/SinkRate/SinkRateCfgPage.lua")
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
        local processed = sinkRateCfgPage.run(event, curTime)
        if processed then
            return true
        end
    end

    local invers = false
    if getRtcTime() % 2 == 1 then
        invers = true
    end
    local rs = LZ_ui.rowStep
    if eleGvNumEdit then
        lcd.drawText(srEleLabelX, 0, "e:", LZ_ui.font + LEFT)
        eleGvNumEdit:draw(srEleValX, 0, invers, LZ_ui.font + LEFT)
    end
    if flap1GvNumEdit then
        lcd.drawText(srF1LabelX, 0, "f1:", LZ_ui.font + LEFT)
        flap1GvNumEdit:draw(srF1ValX, 0, invers, LZ_ui.font + LEFT)
    end
    if flap2GvNumEdit then
        lcd.drawText(srF2LabelX, 0, "f2:", LZ_ui.font + LEFT)
        flap2GvNumEdit:draw(srF2ValX, 0, invers, LZ_ui.font + LEFT)
    end

    cfgButton:draw(LCD_W, 0, invers, LZ_ui.font + RIGHT)

    local testSwIndex = sinkRateCfg:getNumberField("testsw", -1)
    local playTone = false
    if getRtcTime() % 4 == 1 then
        playTone = true
    end
    if testSwIndex ~= -1 then
        local time = getRtcTime()
        local alt = 0
        if altID ~= -1 then
            alt = getValue(altID)
        end
        SRSrun(sinkRateState, time, alt, getValue(testSwIndex))

        if SRSisStart(sinkRateState) and playTone and playingTone == false then
            --playTone(1000, 100, 0, 0)
            LZ_playNumber(SRSgetCurSinkRate(sinkRateState)*100, 0)
            playingTone = true
        end
        if not invers and playingTone then
            playingTone = false
        end

        local yStat = rs
        lcd.drawText(0, yStat, "dur:", LZ_ui.font + LEFT)
        lcd.drawText(srStatVal1X, yStat, LZ_formatTime(SRSgetCurDuration(sinkRateState)), LZ_ui.font + RIGHT)
        lcd.drawText(srStatLab2X, yStat, "sink:", LZ_ui.font + LEFT)
        lcd.drawText(srStatVal2X, yStat, math.floor(SRSgetCurSinkAlt(sinkRateState)), LZ_ui.font + RIGHT)
        lcd.drawText(srStatLab3X, yStat, "srate:", LZ_ui.font + LEFT)
        lcd.drawNumber(LCD_W - 1, yStat, SRSgetCurSinkRate(sinkRateState) * 100, LZ_ui.font + RIGHT)

        local varSelectorSliderValue = getValue(sinkRateCfg:getNumberField('SelSlider'))
        local varReadSwitchValue = getValue(sinkRateCfg:getNumberField('ReadSw'))
        readVar.doReadVar(varSelectorSliderValue, varReadSwitchValue, curTime)
 
    end



    recordListView:draw(0, rs * 2, invers, 0)
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
	readVar = LZ_runModule(gSDCardDir .. "LAOZHU/readVar.lua")
	local sinkRateReadVarMap = LZ_runModule(gSDCardDir .. "LAOZHU/sinkRateReadVarMap.lua")
	sinkRateReadVarMap.sinkRateState = sinkRateState
	readVar.setVarMap(sinkRateReadVarMap)
    initSinkRateLayout()
end

init()

this = {run=run, bg=bg, pageState=0}

return this