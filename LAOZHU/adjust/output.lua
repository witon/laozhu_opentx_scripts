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
local adjustMixSourceName = nil

local function pickAdjustMixSourceName()
    local names = {"s1", "s2", "s3", "ls", "rs", "thr"}
    for i = 1, #names do
        if getFieldInfo(names[i]) then
            return names[i]
        end
    end
    return nil
end

-- outColGap 列间距；outLeftPad 左侧起点留白；outNameColW 名称列宽度；outNumColW min/mid/max 单列宽度；outRevColW rev 列占位宽度（像素）
local outColGap, outLeftPad, outNameColW, outNumColW, outRevColW
-- outXMin/outXMid/outXMax 为 min/mid/max 列右对齐锚点（列右缘 x）；outXRev 为 rev 列右对齐锚点
local outXMin, outXMid, outXMax, outXRev
local outXCols = {}
local outAdjLabelX, outAdjCheckX, outXS1ValRight, outOutLabelX, outOutValX

local function initOutputLayout()
    outColGap = math.floor(LCD_W / 128)
    outLeftPad = 2
    outNameColW = 5 * LZ_ui.fontWidth
    outNumColW = 5 * LZ_ui.fontWidth
    outRevColW = 2 * LZ_ui.fontWidth
    local base = outLeftPad + outNameColW + outColGap
    outXMin = base + outNumColW
    outXMid = outXMin + outColGap + outNumColW
    outXMax = outXMid + outColGap + outNumColW
    outXRev = LCD_W - 1
    outXCols[1] = outXMin
    outXCols[2] = outXMid
    outXCols[3] = outXMax
    outXCols[4] = outXRev
    outAdjLabelX = 3 + 9 * LZ_ui.fontWidth
    outAdjCheckX = outAdjLabelX + 5 * LZ_ui.fontWidth + outColGap
    outXS1ValRight = outLeftPad + (6+4) * LZ_ui.fontWidth + outColGap
    outOutLabelX = math.floor(LCD_W / 2)
    outOutValRight = outOutLabelX + (6+4) * LZ_ui.fontWidth + outColGap
end

local function loadModule()
    LZ_runModule(gSDCardDir .. "LAOZHU/uilib/ViewMatrix.lua")
    LZ_runModule(gSDCardDir .. "LAOZHU/uilib/Button.lua")
    LZ_runModule(gSDCardDir .. "LAOZHU/uilib/CheckBox.lua")
    LZ_runModule(gSDCardDir .. "LAOZHU/uilib/NumEdit.lua")
    LZ_runModule(gSDCardDir .. "LAOZHU/uilib/InputView.lua")
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
    replaceMix(channel, checkBox.checked, adjustMixSourceName)
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
            replaceMix(adjustChannels[i]-1, outputEditRows[i][4].checked, adjustMixSourceName)
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
        selectChannelPage = LZ_runModule(gSDCardDir .. "LAOZHU/adjust/SelectChannel.lua")
        selectChannelPage.init()
        selectChannelPage.setSelectedChannels(adjustChannels)
    end
end

local function onCurvesButtonClick()
    if enableAdjustCheckBox.checked then
        return
    end
    if not curvesPage then
        curvesPage = LZ_runModule(gSDCardDir .. "LAOZHU/adjust/OutputCurve.lua")
        curvesPage.init()
        local revertArray = {}
        for i=1, #adjustChannels, 1 do
            revertArray[i] = outputEditRows[i][4].checked
        end
        curvesPage.setSelectedChannelsAndMixSource(adjustChannels, revertArray, adjustMixSourceName)
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
    if event==36 or event==68 then
        if viewMatrix.selectedRow - scrollLine < 2 and scrollLine > 0 then
            scrollLine = scrollLine - 1
        end
    elseif event==35 or event==67 then
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
    local rs = LZ_ui.rowStep
    local hh = LZ_ui.headerRowHeight
    IVdraw(selectChannelsButton, 3, 0, invers, LZ_ui.font + LEFT)
    lcd.drawText(outAdjLabelX, 0, "adj:", LZ_ui.font + LEFT)
    IVdraw(enableAdjustCheckBox, outAdjCheckX, 0, invers, LZ_ui.font + RIGHT)
    IVdraw(curvesButton, LCD_W - 3, 0, invers, LZ_ui.font + RIGHT)

    local yS1 = rs
    local adjRaw = 0
    if adjustMixSourceName then
        local fi = getFieldInfo(adjustMixSourceName)
        if fi then
            adjRaw = getValue(fi.id)
        end
    end
    lcd.drawText(outLeftPad, yS1, adjustMixSourceName and (adjustMixSourceName .. ":") or "-:", LZ_ui.font + LEFT)
    lcd.drawText(outXS1ValRight, yS1, math.floor(adjRaw * 100 / 1024), LZ_ui.font + RIGHT)
    lcd.drawText(outOutLabelX, yS1, "output:", LZ_ui.font + LEFT)
    lcd.drawText(outOutValRight, yS1, math.floor(adjRaw * 150 / 1024), LZ_ui.font + RIGHT)

    local yTblHead = yS1 + rs
    lcd.drawFilledRectangle(0, yTblHead - LZ_ui.headFillTopPad, LCD_W, hh + LZ_ui.headFillTopPad + LZ_ui.headFillBottomPad, FORCE)
    lcd.drawText(outLeftPad, yTblHead, "name", LZ_ui.font + LEFT + INVERS)
    lcd.drawText(outXMin, yTblHead, "min", LZ_ui.font + RIGHT + INVERS)
    lcd.drawText(outXMid, yTblHead, "mid", LZ_ui.font + RIGHT + INVERS)
    lcd.drawText(outXMax, yTblHead, "max", LZ_ui.font + RIGHT + INVERS)
    lcd.drawText(outXRev, yTblHead, "rev", LZ_ui.font + RIGHT + INVERS)

    local yData0 = yTblHead + hh + LZ_ui.headFillTopPad + LZ_ui.headFillBottomPad + 1
    for i = scrollLine + 1, scrollLine + 6, 1 do
        if i <= #adjustChannels then
            local rowY = yData0 + (i - scrollLine - 1) * rs
            lcd.drawText(outLeftPad, rowY, outputNameArray[i], LZ_ui.font)
            for j = 1, 4, 1 do
                if i <= 16 then
                    IVdraw(outputEditRows[i][j], outXCols[j], rowY, invers, LZ_ui.font + RIGHT)
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

local function init()
    loadModule()
    initOutputLayout()
    LZ_runModule(gSDCardDir .. "LAOZHU/adjust/ReplaceMix.lua")
    adjustMixSourceName = pickAdjustMixSourceName()
    LZ_runModule(gSDCardDir .. "LAOZHU/adjust/OutputCurveManager.lua")
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
init()

this = {run = run, bg = bg, pageState=0}
return this