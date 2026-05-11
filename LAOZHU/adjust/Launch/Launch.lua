local viewMatrix = nil
local this = nil
local cfgButton = nil
local launchCfgPage = nil
local launchCfg = nil
local eleGvNumEdit = nil
local flap1GvNumEdit = nil
local rudGvNumEdit = nil
local altID = 0
local launchRecord = nil
local recordListView = nil
local readVar = nil
local f3kState = nil
local curAlt = 0

-- 128px 屏设计坐标按 LCD_W 比例缩放（与 F3KRecordListView / output 同源）
local lauEleLabelX, lauEleValX, lauF1LabelX, lauF1ValX, lauRLabelX, lauRValX
local lauStateNameX, lauHeightLabelX

local function initLaunchLayout()
    local s = LCD_W / 128
    lauEleLabelX = math.floor(0 * s)
    lauEleValX = math.floor(10 * s)
    lauF1LabelX = math.floor(35 * s)
    lauF1ValX = math.floor(50 * s)
    lauRLabelX = math.floor(75 * s)
    lauRValX = math.floor(90 * s)
    lauStateNameX = math.floor(30 * s)
    lauHeightLabelX = math.floor(80 * s)
end

local function loadModule()
    LZ_runModule(gSDCardDir .. "LAOZHU/uilib/InputViewO.lua")
    LZ_runModule(gSDCardDir .. "LAOZHU/uilib/ViewMatrixO.lua")
    LZ_runModule(gSDCardDir .. "LAOZHU/uilib/ButtonO.lua")
    LZ_runModule(gSDCardDir .. "LAOZHU/uilib/NumEditO.lua")
    LZ_runModule(gSDCardDir .. "LAOZHU/DataFileDecode.lua")
    LZ_runModule(gSDCardDir .. "LAOZHU/CfgO.lua")
    LZ_runModule(gSDCardDir .. "LAOZHU/launchRecord.lua")
    LZ_runModule(gSDCardDir .. "LAOZHU/comm/Timer.lua")
    LZ_runModule(gSDCardDir .. "LAOZHU/adjust/Launch/LRecordListView.lua")
	LZ_runModule(gSDCardDir .. "LAOZHU/comm/OTSound.lua")
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
    launchCfgPage = LZ_runModule(gSDCardDir .. "LAOZHU/adjust/Launch/LaunchCfgPage.lua")
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

local function landedCallback(flightTime, launchAlt, launchTime)
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
    LZ_playNumber(f3kState.launchAlt, 9)
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

    if launchRecord == nil then
        launchRecord = LRnewLaunchRecord()
        LRreadOneDayRecordsFromFile(launchRecord, getDateTime())
        --recordListView.records = launchRecord.records
        recordListView.lr = launchRecord
        return
    end


	local flightMode, flightModeName = getFlightMode()
	curAlt = getValue(altID)
	local rtcTime = getRtcTime()

	f3kState.curAlt = curAlt
	f3kState.doFlightState(curTime, flightModeName, rtcTime)

    if launchCfgPage then
        if launchCfgPage.pageState == 1 then
            unloadCfgPage()
            updateGvNumEdit()
            getGVValue()
            return true
        end
        local processed = launchCfgPage.run(event, curTime)
        if processed then
            return true
        end
    end

    local invers = false
    if rtcTime % 2 == 1 then
        invers = true
    end
    local rs = LZ_ui.rowStep
    if eleGvNumEdit then
        lcd.drawText(lauEleLabelX, 0, "e:", LZ_ui.font + LEFT)
        eleGvNumEdit:draw(lauEleValX, 0, invers, LZ_ui.font + LEFT)
    end
    if flap1GvNumEdit then
        lcd.drawText(lauF1LabelX, 0, "f1:", LZ_ui.font + LEFT)
        flap1GvNumEdit:draw(lauF1ValX, 0, invers, LZ_ui.font + LEFT)
    end
    if rudGvNumEdit then
        lcd.drawText(lauRLabelX, 0, "r:", LZ_ui.font + LEFT)
        rudGvNumEdit:draw(lauRValX, 0, invers, LZ_ui.font + LEFT)
    end

    cfgButton:draw(LCD_W, 0, invers, LZ_ui.font + RIGHT)

    local yStat = rs
    lcd.drawText(0, yStat, "state:", LZ_ui.font + LEFT)
    lcd.drawText(lauStateNameX, yStat, f3kState.getCurFlightStateName(), LZ_ui.font + LEFT)
    lcd.drawText(lauHeightLabelX, yStat, "height:", LZ_ui.font + LEFT)
    lcd.drawNumber(LCD_W - 1, yStat, f3kState.launchAlt, LZ_ui.font + RIGHT)

    local varSelectorSliderValue = getValue(launchCfg:getNumberField('SelSlider'))
    local varReadSwitchValue = getValue(launchCfg:getNumberField('ReadSw'))
    readVar.doReadVar(varSelectorSliderValue, varReadSwitchValue, curTime)

    recordListView:draw(0, yStat + rs, invers, 0)
    return doKey(event)
end

local function bg()

end

local function init()
    loadModule()
    f3kState = LZ_runModule(gSDCardDir .. "LAOZHU/F3k/F3kState.lua")
	f3kState.landedCallback = landedCallback
    f3kState.launchedCallback = launchedCallback
	
    viewMatrix = ViewMatrix:new()
    cfgButton = Button:new()
    cfgButton.text = "*"
    cfgButton:setOnClick(onCfgButtonClick)

    recordListView = LRecordListView:new()

    launchCfg = CFGC:new()
    launchCfg:readFromFile("launch.cfg")

    updateGvNumEdit()
    getGVValue()
	altID = getTelemetryId("Alt")
	readVar = LZ_runModule(gSDCardDir .. "LAOZHU/readVar.lua")
	local launchReadVarMap = LZ_runModule(gSDCardDir .. "LAOZHU/launchReadVarMap.lua")
	launchReadVarMap.f3kState = f3kState
	readVar.setVarMap(launchReadVarMap)
    initLaunchLayout()
end

init()

this = {run=run, bg=bg, pageState=0}

return this