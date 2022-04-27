local viewMatrix = nil
local this = nil
local cfgButton = nil
local launchCfgPage = nil
local launchCfg = nil
local launchCfgFileName = "launch.cfg"
local eleGvNumEdit = nil
local flap1GvNumEdit = nil
local rudGvNumEdit = nil
local altID = 0
local launchRecord = nil
local recordListView = nil
local readVar = nil
local f3kState = nil
local curAlt = 0
local function loadModule()
    LZ_runModule("TELEMETRY/common/InputViewO.lua")
    LZ_runModule("TELEMETRY/common/ViewMatrixO.lua")
    LZ_runModule("TELEMETRY/common/ButtonO.lua")
    LZ_runModule("TELEMETRY/common/NumEditO.lua")
    LZ_runModule("LAOZHU/DataFileDecode.lua")
    LZ_runModule("LAOZHU/CfgO.lua")
    LZ_runModule("/LAOZHU/launchRecord.lua")
    LZ_runModule("LAOZHU/comm/Timer.lua")
    LZ_runModule("/TELEMETRY/adjust/Launch/LRecordListView.lua")
	LZ_runModule("LAOZHU/comm/OTSound.lua")
end

local function unloadModule()
    ViewMatrix = nil
    Button = nil
    NumEdit = nil
    InputView = nil
    DFDunload()
    LRunload()
    LRecordListView = nil
    CFGC = nil
    Timer = nil
end

local function onNumEditChange(numEdit)
    local modeIndex = launchCfg:getNumberField("mode", -1)
    if modeIndex == -1 then
        return
    end
    LZ_setGVValue(numEdit.gvIndex, modeIndex, numEdit.num)
end

local function getGVValue()
    local modeIndex = launchCfg:getNumberField("mode", -1)
    if eleGvNumEdit then
        eleGvNumEdit.num = LZ_getGVValue(eleGvNumEdit.gvIndex, modeIndex)
    end
    if flap1GvNumEdit then
        flap1GvNumEdit.num = LZ_getGVValue(flap1GvNumEdit.gvIndex, modeIndex)
    end
    if rudGvNumEdit then
        rudGvNumEdit.num = LZ_getGVValue(rudGvNumEdit.gvIndex, modeIndex)
    end
end

local function loadCfgPage()
    if launchCfgPage ~= nil then
        return
    end
    launchCfgPage = LZ_runModule("TELEMETRY/adjust/Launch/LaunchCfgPage.lua")
    launchCfgPage.setCfgFileName(launchCfgFileName)
    launchCfgPage.init()
end

local function unloadCfgPage()
    if launchCfgPage == nil then
        return
    end
    LZ_clearTable(launchCfgPage)
    launchCfgPage = nil
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
    local eleGvIndex = launchCfg:getNumberField("elegv", -1)
    local flap1GvIndex = launchCfg:getNumberField("flap1gv", -1)
    local rudGvIndex = launchCfg:getNumberField("rudgv", -1)
    local modeIndex = launchCfg:getNumberField("mode", -1)

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
    if rudGvIndex ~= -1 and modeIndex ~= -1 then
        rudGvNumEdit = NumEdit:new()
        rudGvNumEdit:setOnChange(onNumEditChange)
        row[#row+1] = rudGvNumEdit
        rudGvNumEdit.gvIndex = rudGvIndex
    else
        rudGvNumEdit = nil
    end
    row[#row+1] = cfgButton
    viewMatrix.selectedRow = 1
    viewMatrix.selectedCol = 1
    viewMatrix:updateCurIVFocus()

end

local function landedCallBack(flightTime, launchAlt, launchTime)
    local ele = "-"
    if eleGvNumEdit then
        ele = eleGvNumEdit.num
    end
    local flap1 = "-"
    if flap1GvNumEdit then
        flap1 = flap1GvNumEdit.num
    end
    local rud = "-"
    if rudGvNumEdit then
        rud = rudGvNumEdit.num
    end
    local record = LRaddOneRecord(launchRecord,
                    launchTime,
                    launchAlt,
                    ele,
                    flap1,
                    rud)
    LRwriteOneRecordToFile(getDateTime(), record)
end

local function launchedCallback(launchTime, launchAlt)
    LZ_playNumber(f3kState.getLaunchAlt(), 9)
end


local function init()
    loadModule()
    f3kState = LZ_runModule("/LAOZHU/F3k/F3kState.lua")
	f3kState.setLandedCallback(landedCallBack)
    f3kState.setLaunchedCallback(launchedCallback)
	
    launchRecord = LRnewLaunchRecord()
    LRreadOneDayRecordsFromFile(launchRecord, getDateTime())


    viewMatrix = ViewMatrix:new()
    cfgButton = Button:new()
    cfgButton.text = "*"
    cfgButton:setOnClick(onCfgButtonClick)

    recordListView = LRecordListView:new()
    recordListView.records = launchRecord.records

    launchCfg = CFGC:new()
    launchCfg:readFromFile(launchCfgFileName)

    updateGvNumEdit()
    getGVValue()
	altID = getTelemetryId("Alt")
	readVar = LZ_runModule("LAOZHU/readVar.lua")
	local launchReadVarMap = LZ_runModule("LAOZHU/launchReadVarMap.lua")
	launchReadVarMap.f3kState = f3kState
	readVar.setVarMap(launchReadVarMap)


	
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
	local flightMode, flightModeName = getFlightMode()
	curAlt = getValue(altID)
	local rtcTime = getRtcTime()

	f3kState.setAlt(curAlt)
	f3kState.doFlightState(curTime, flightModeName, rtcTime)

    if launchCfgPage then
        if launchCfgPage.pageState == 1 then
            unloadCfgPage()
            updateGvNumEdit()
            getGVValue()
            return true
        end
        local processed = launchCfgPage.run(event, time)
        if processed then
            return true
        end
    end

    local invers = false
    if rtcTime % 2 == 1 then
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
    if rudGvNumEdit then
        lcd.drawText(75, 0, "r:", LEFT)
        rudGvNumEdit:draw(90, 0, invers, LEFT)
    end

    cfgButton:draw(127, 0, invers, RIGHT)

    lcd.drawText(0, 10, "state:", SMLSIZE + LEFT)
	lcd.drawText(30, 10, f3kState.getCurFlightStateName(), SMLSIZE + LEFT)



    lcd.drawText(80, 10, "height:", SMLSIZE + LEFT)
    lcd.drawNumber(128, 10, f3kState.getLaunchAlt(), SMLSIZE + RIGHT)

    local varSelectorSliderValue = getValue(launchCfg:getNumberField('SelSlider'))
    local varReadSwitchValue = getValue(launchCfg:getNumberField('ReadSw'))
    readVar.doReadVar(varSelectorSliderValue, varReadSwitchValue, curTime)

    recordListView:draw(0, 19, invers, 0)
    return doKey(event)
end

local function bg()

end

this = {run=run, init=init, bg=bg, pageState=0}

return this