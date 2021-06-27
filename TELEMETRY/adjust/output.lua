local adjustChannels = {}
local outputEditRows = {}
local outputNameArray = {}
local scrollLine = 0
local selectChannelsButton = nil
local curvesButton = nil
local enableAdjustCheckBox = nil
local viewMatrix = nil

local selectChannelPage = nil
local curvesPage = nil
local this = nil

local function loadModule()
    LZ_runModule("TELEMETRY/common/ViewMatrix.lua")
    LZ_runModule("TELEMETRY/common/Button.lua")
    LZ_runModule("TELEMETRY/common/CheckBox.lua")
    LZ_runModule("TELEMETRY/common/NumEdit.lua")
    LZ_runModule("TELEMETRY/common/InputView.lua")
end

local function unloadModule()
    VMunload()
    BTunload()
    NEunload()
    IVunload()
    CBunload()
end

local function getOutputValue(rowNum, index, row)
    local output = model.getOutput(index-1)
    row[1].num = math.ceil(output.min * 99 / 1500)
    row[2].num = math.ceil(output.offset * 99 / 1500)
    row[3].num = math.ceil(output.max * 99 / 1500)
    if output.revert == 0 then
        row[4].checked = false
    else
        row[4].checked = true
    end
    outputNameArray[rowNum] = output.name
    if output.name == "" then
        outputNameArray[rowNum] = index
    end
end

local function saveOutputValue(index, neRow)
    local output = model.getOutput(index)
    output.min = neRow[1].num * 1500 / 99
    output.offset = neRow[2].num * 1500 / 99
    output.max = neRow[3].num *1500 / 99
    model.setOutput(index, output)
end

local function onReverseCheckBoxChange(checkBox)
    local channel = checkBox.channel - 1
    recoverMix(channel)
    replaceMix(channel, checkBox.checked)
end

local function onNumEditChange(numEdit)
    local row = outputEditRows[numEdit.row-1]
    saveOutputValue(numEdit.channel-1, row)
end

local function newParamNe(row, channel)
    local ne = NEnewNumEdit()
    ne.max = 99
    ne.min = -99
    ne.row = row
    ne.channel = channel
    NEsetOnChange(ne, onNumEditChange)
    return ne
end

local function updateviewMatrix()
    for i=2, #viewMatrix.matrix, 1 do
        viewMatrix.matrix[i] = nil
    end
    if enableAdjustCheckBox.checked then
        for i=1, #outputEditRows, 1 do
            viewMatrix.matrix[i+1] = {}
            local outputEditRow = outputEditRows[i]
            for j=1, #outputEditRow, 1 do
                viewMatrix.matrix[i+1][j] = outputEditRow[j]
            end
        end
    else
        for i=1, #outputEditRows, 1 do
            viewMatrix.matrix[i+1] = {}
            viewMatrix.matrix[i+1][1] = outputEditRows[i][4]
        end
    end
end

local function onEnableAdjustCheckBoxChange(checkBox)
    if checkBox.checked then
        for i=1, #adjustChannels, 1 do
            replaceMix(adjustChannels[i]-1, outputEditRows[i][4].checked)
        end
        OCMdisableCurve(adjustChannels)
    else
        for i=1, #adjustChannels, 1 do
            recoverMix(adjustChannels[i]-1)
        end
        OCMrecoverCurve(adjustChannels)
    end
    updateviewMatrix()
    
end

local function onSelectChannelsButtonClick(button)
    if enableAdjustCheckBox.checked then
        return
    end
    if not selectChannelPage then
        selectChannelPage = LZ_runModule("TELEMETRY/adjust/SelectChannel.lua")
        selectChannelPage.init()
        selectChannelPage.setSelectedChannels(adjustChannels)
    end
end

local function onCurvesButtonClick()
    if enableAdjustCheckBox.checked then
        return
    end
    if not curvesPage then
        curvesPage = LZ_runModule("TELEMETRY/adjust/OutputCurve.lua")
        curvesPage.init()
        local revertArray = {}
        for i=1, #adjustChannels, 1 do
            revertArray[i] = outputEditRows[i][4].checked
        end
        curvesPage.setSelectedChannels(adjustChannels, revertArray)
    end
end

local function init()
    loadModule()

    LZ_runModule("TELEMETRY/adjust/ReplaceMix.lua")
    LZ_runModule("TELEMETRY/adjust/OutputCurveManager.lua")
    selectChannelsButton = BTnewButton()
    curvesButton = BTnewButton()
    curvesButton.text = "curves"
    BTsetOnClick(curvesButton, onCurvesButtonClick)
    BTsetOnClick(selectChannelsButton, onSelectChannelsButtonClick)
    selectChannelsButton.text = "channels"
    enableAdjustCheckBox = CBnewCheckBox()
    CBsetOnChange(enableAdjustCheckBox, onEnableAdjustCheckBoxChange)

    viewMatrix = VMnewViewMatrix()
    viewMatrix.matrix[1] = {}
    viewMatrix.matrix[1][1] = selectChannelsButton
    viewMatrix.matrix[1][2] = enableAdjustCheckBox 
    viewMatrix.matrix[1][3] = curvesButton
 
    IVsetFocusState(viewMatrix.matrix[viewMatrix.selectedRow][viewMatrix.selectedCol], 1)
    for i=0, 16, 1 do
        recoverMix(i)
    end
end

local function updateAdjustChannels()
    LZ_clearTable(outputNameArray)
    LZ_clearTable(outputEditRows)
    outputEditRows = {}
    outputNameArray = {}
    for i=1, #adjustChannels, 1 do
        local outputEditRow = {}
        for j=1, 3, 1 do
           outputEditRow[j] = newParamNe(i+1, adjustChannels[i])
        end
        outputEditRow[4] = CBnewCheckBox()
        CBsetOnChange(outputEditRow[4], onReverseCheckBoxChange)
        outputEditRow[4].channel = adjustChannels[i]
 
        outputEditRows[i] = outputEditRow
        getOutputValue(i, adjustChannels[i], outputEditRow)
    end
end

local function doKey(event)
    local ret = viewMatrix.doKey(viewMatrix, event)
    if event==36 then
        if viewMatrix.selectedRow - scrollLine < 2 and scrollLine > 0 then
            scrollLine = scrollLine - 1
        end
    elseif event==35 then
        if viewMatrix.selectedRow - scrollLine > 5 then
                scrollLine = scrollLine + 1
        end
        if scrollLine > 12 then
            scrollLine = 12 
        end
    end
    if not ret and event==EVT_EXIT_BREAK then
        enableAdjustCheckBox.checked = false
        onEnableAdjustCheckBoxChange(enableAdjustCheckBox)
        this.pageState = 1
        unloadModule()
    end
end

local function run(event, time)

    if selectChannelPage then
        local processed = selectChannelPage.run(event, time)
        if processed then
            return true
        end
		if event == EVT_EXIT_BREAK then
            adjustChannels = {}
            selectChannelPage.getSelectedChannels(adjustChannels)
            LZ_clearTable(selectChannelPage)
            selectChannelPage = nil
            collectgarbage()
            updateAdjustChannels()
            updateviewMatrix()
		end
        return true
    elseif curvesPage then
        local processed = curvesPage.run(event, time)
        if processed then
            return true
        end
		if event == EVT_EXIT_BREAK then
            LZ_clearTable(curvesPage)
            curvesPage = nil
            collectgarbage()
		end
        return true
    end

    local invers = false
    if getRtcTime() % 2 == 1 then
        invers = true
    end
    IVdraw(selectChannelsButton, 3, 0, invers, SMLSIZE + LEFT)
    lcd.drawText(50, 0, "adj:", SMLSIZE + LEFT)
    IVdraw(enableAdjustCheckBox, 75, 0, invers, SMLSIZE + RIGHT)
    IVdraw(curvesButton, 125, 0, invers, SMLSIZE + RIGHT)

    lcd.drawText(2, 9, "thr:", SMLSIZE + LEFT)
    lcd.drawText(22, 9, math.floor(getValue("thr") * 100 / 1024), SMLSIZE+LEFT)
    lcd.drawText(64, 9, "output:", SMLSIZE + LEFT)
    lcd.drawText(98, 9, math.floor(getValue("thr") * 150/1024), SMLSIZE+LEFT)
 

    lcd.drawFilledRectangle(0, 17, 128, 9, FORCE)
    lcd.drawText(2, 18, "name", SMLSIZE + LEFT + INVERS)
    lcd.drawText(48, 18, "min", SMLSIZE + RIGHT + INVERS)
    lcd.drawText(71, 18, "mid", SMLSIZE + RIGHT + INVERS)
    lcd.drawText(94, 18, "max", SMLSIZE + RIGHT + INVERS)
    lcd.drawText(127, 18, "rev", SMLSIZE + RIGHT + INVERS)
 
    for i=scrollLine + 1, scrollLine + 6, 1 do
        if i <= #adjustChannels then
            lcd.drawText(2, 9 * (i-scrollLine + 2), outputNameArray[i])
            for j=1, 4, 1 do
                if i <= 16 then
                    IVdraw(outputEditRows[i][j], 25 + 23 * (j), 9 * (i - scrollLine + 2), invers, SMLSIZE + RIGHT)
                end
            end
        end
    end
    return doKey(event)
end

local function bg()
    enableAdjustCheckBox.checked = false
    onEnableAdjustCheckBoxChange(enableAdjustCheckBox)
    if curvesPage then
        curvesPage.bg()
    end
    this.pageState = 1
    unloadModule()
end

this = {run = run, init=init, bg = bg, pageState=0}
return this