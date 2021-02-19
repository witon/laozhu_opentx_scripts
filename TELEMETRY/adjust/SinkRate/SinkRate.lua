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

local function onNumEditChange(numEdit)
    local modeIndex = sinkRateCfg.getNumberField("mode", -1)
    if modeIndex == -1 then
        return
    end
    LZ_setGVValue(numEdit.gvIndex, modeIndex, numEdit.num)
end

local function getGVValue()
    local modeIndex = sinkRateCfg.getNumberField("mode", -1)
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
    sinkRateCfgPage = LZ_runModule(gScriptDir .. "TELEMETRY/adjust/SinkRate/SinkRateCfgPage.lua")
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
    VMdelRow(viewMatrix, 1)
    local row = VMaddRow(viewMatrix)

    local eleGvIndex = sinkRateCfg.getNumberField("elegv", -1)
    local flap1GvIndex = sinkRateCfg.getNumberField("flap1gv", -1)
    local flap2GvIndex = sinkRateCfg.getNumberField("flap2gv", -1)
    local modeIndex = sinkRateCfg.getNumberField("mode", -1)

    if eleGvIndex ~= -1 and modeIndex ~= -1 then
        eleGvNumEdit = NEnewNumEdit()
        NEsetOnChange(eleGvNumEdit, onNumEditChange)
        row[#row+1] = eleGvNumEdit
        eleGvNumEdit.gvIndex = eleGvIndex
    else
        eleGvNumEdit = nil
    end
    if flap1GvIndex ~= -1 and modeIndex ~= -1 then
        flap1GvNumEdit = NEnewNumEdit()
        NEsetOnChange(flap1GvNumEdit, onNumEditChange)
        row[#row+1] = flap1GvNumEdit
        flap1GvNumEdit.gvIndex = flap1GvIndex
    else
        flap1GvNumEdit = nil
    end
    if flap2GvIndex ~= -1 and modeIndex ~= -1 then
        flap2GvNumEdit = NEnewNumEdit()
        NEsetOnChange(flap2GvNumEdit, onNumEditChange)
        row[#row+1] = flap2GvNumEdit
        flap2GvNumEdit.gvIndex = flap2GvIndex
    else
        flap2GvNumEdit = nil
    end
    row[#row+1] = cfgButton
    viewMatrix.selectedRow = 1
    viewMatrix.selectedCol = 1
    VMupdateCurIVFocus(viewMatrix)

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
    SRRaddOneRecord(sinkRateRecord,
                    state.startTime,
                    state.startAlt,
                    state.stopTime,
                    state.stopAlt,
                    ele,
                    flap1,
                    flap2)
    SRSreset(state)
end

local function init()

    LZ_runModule(gScriptDir .. "/LAOZHU/SinkRateState.lua")
    sinkRateState = SRSnewSinkRateState()
    SRSsetOnStateChange(sinkRateState, onSinkRateStateChange)
    LZ_runModule(gScriptDir .. "/LAOZHU/SinkRateRecord.lua")
    sinkRateRecord = SRRnewSinkRateRecord(getRtcTime())


    sinkRateCfg = LZ_runModule(gScriptDir .. "/LAOZHU/Cfg.lua")
    sinkRateCfg.readFromFile(sinkRateCfgFileName)

    viewMatrix = VMnewViewMatrix()
    cfgButton = BTnewButton()
    cfgButton.text = "*"
    BTsetOnClick(cfgButton, onCfgButtonClick)
    updateGvNumEdit()

    getGVValue()
	altID = getTelemetryId("Alt")
	
end

local function doKey(event)
    viewMatrix.doKey(viewMatrix, event)
end

local function run(event, time)
    if sinkRateCfgPage then
        if sinkRateCfgPage.pageState == 1 then
            unloadCfgPage()
            sinkRateCfg.readFromFile(sinkRateCfgFileName)
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
        IVdraw(eleGvNumEdit, 10, 0, invers, LEFT)
    end
    if flap1GvNumEdit then
        lcd.drawText(35, 0, "f1:", LEFT)
        IVdraw(flap1GvNumEdit, 50, 0, invers, LEFT) --54
    end
    if flap2GvNumEdit then
        lcd.drawText(75, 0, "f2:", LEFT)
        IVdraw(flap2GvNumEdit, 90, 0, invers, LEFT)
    end

    IVdraw(cfgButton, 127, 0, invers, RIGHT)

    local testSwIndex = sinkRateCfg.getNumberField("testsw", -1)
    if testSwIndex ~= -1 then
        local time = getRtcTime()
        local alt = getValue(altID)
        SRSrun(sinkRateState, time, alt, getValue(testSwIndex))
        lcd.drawText(0, 10, "dur:", SMLSIZE + LEFT)
        lcd.drawText(40, 10, LZ_formatTime(SRSgetCurDuration(sinkRateState, time)), SMLSIZE + RIGHT)
        lcd.drawText(44, 10, "sink:", SMLSIZE + LEFT)
        lcd.drawText(76, 10, math.floor(SRSgetCurSinkAlt(sinkRateState, alt)), SMLSIZE + RIGHT)
        lcd.drawText(80, 10, "srate:", SMLSIZE + LEFT)
        lcd.drawNumber(128, 10, SRSgetCurSinkRate(sinkRateState, time, alt)*100, SMLSIZE + RIGHT)
 
    end

    lcd.drawFilledRectangle(0, 19, 128, 9, FORCE)
    lcd.drawText(0, 20, "time", SMLSIZE + LEFT + INVERS)
    lcd.drawText(57, 20, "ele", SMLSIZE + RIGHT + INVERS)
    lcd.drawText(80, 20, "f1", SMLSIZE + RIGHT + INVERS)
    lcd.drawText(103, 20, "f2", SMLSIZE + RIGHT + INVERS)
    lcd.drawText(128, 20, "sr", SMLSIZE + RIGHT + INVERS)

    for i=1, #sinkRateRecord, 1 do
        local record = sinkRateRecord[#sinkRateRecord - i + 1]
        local y = 30 + (i-1) * 10
        lcd.drawText(0, y, LZ_formatTimeStamp(record.startTime), SMLSIZE + LEFT)
        lcd.drawText(57, y, record.ele, SMLSIZE + RIGHT)
        lcd.drawText(80, y, record.flap1, SMLSIZE + RIGHT)
        lcd.drawText(103, y, record.flap2, SMLSIZE + RIGHT)
        lcd.drawNumber(128, y, SRRgetRecordSinkRate(record), SMLSIZE + RIGHT)
 
    end
  



    return doKey(event)
end

local function bg()

end

this = {run=run, init=init, bg=bg, pageState=0}

return this