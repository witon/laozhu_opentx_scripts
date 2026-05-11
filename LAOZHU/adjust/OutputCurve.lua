local curvePointNumEditArray = {}
--                            {
--                                {
--                                    output=1,
--                                    curve=1,
--                                    {x1, y2},
--                                    {y1, y2}
--                                },
--                                {
--                                    {},
--                                    {}
--                                }
--                            }
local scrollLine = 0
local scrollCol = 0
local viewMatrix = nil
local this = nil
local adjustMixSourceName = nil

-- 布局：与 output.lua / GlobalVar 一致按 LCD_W、LZ_ui.fontWidth 计算（仅绘制）
local curveColGap, curveLeftPad, curveNameColW, curveCurColW, curvePointColW
local curveXCurRight
local crvXS1ValRight, crvOutLabelX, crvOutValRight

local function initCurveLayout()
    curveColGap = math.max(1, math.floor(LCD_W / 128))
    curveLeftPad = 2
    curveNameColW = 4 * LZ_ui.fontWidth
    curveCurColW = 3 * LZ_ui.fontWidth
    curvePointColW = 5 * LZ_ui.fontWidth
    curveXCurRight = curveLeftPad + curveNameColW + curveColGap + curveCurColW
    crvXS1ValRight = curveLeftPad + (6 + 4) * LZ_ui.fontWidth + curveColGap
    crvOutLabelX = math.floor(LCD_W / 2)
    crvOutValRight = crvOutLabelX + (6 + 4) * LZ_ui.fontWidth + curveColGap
end

local function curvePointAnchorX(i)
    return curveXCurRight + curveColGap + (i - scrollCol) * (curvePointColW + curveColGap)
end

local function setCurve(index)

end

local function updateOneRowNumEditValue(curveRow)
    local output = model.getOutput(curveRow.output)
    curveRow.curve = output.curve
    if output.curve then
        local curveData = model.getCurve(output.curve)
        if not curveData then
            return
        end
        local i = 1
        for index, value in pairs(curveData.y) do
            curveRow.yNumEditArray[i].num = value
            if curveData.type == 1 then
                curveRow.xNumEditArray[i].num = curveData.x[index]
            end
            i = i + 1
        end
    end
end

local function updateAllCurvesNumEditValue()
    for i=1, #curvePointNumEditArray, 1 do
        updateOneRowNumEditValue(curvePointNumEditArray[i])
    end
end

local function onNumEditChange(numEdit)
    local editRow = curvePointNumEditArray[numEdit.row]
    local curve = editRow.curve
    local curveData = model.getCurve(curve)
    if curveData.points ~= #editRow.yNumEditArray then
        LZ_error("invalid curve data")
        return
    end
    curveData.y = {}
    if curveData.type == 1 then
        curveData.x = {}
    end
    curveData.x = {}
    for i=1, #editRow.yNumEditArray, 1 do
        curveData.y[i] = editRow.yNumEditArray[i].num
        if curveData.type == 1 then
            curveData.x[i] = editRow.xNumEditArray[i].num
        end
    end
    model.setCurve(curve, curveData)
    updateAllCurvesNumEditValue()
    
end


local function getChannelCurve(curveRow, row)
    local output = model.getOutput(curveRow.output)
    curveRow.curve = output.curve
    curveRow.yNumEditArray = {}
    if output.curve then
        local vmRowY = VMaddRow(viewMatrix)
        local curveData = model.getCurve(output.curve)
        if curveData then
            local vmRowX = nil
            if curveData.type == 1 then
                vmRowX = VMaddRow(viewMatrix)
                curveRow.xNumEditArray = {}
            end
            local i = 1
            for index,value in pairs(curveData.y) do
                local yNumEdit = NEnewNumEdit()
                yNumEdit.min = -100
                yNumEdit.max = 100
                NEsetOnChange(yNumEdit, onNumEditChange)
                yNumEdit.num = value
                curveRow.yNumEditArray[i] = yNumEdit
                yNumEdit.row = row
                vmRowY[i] = yNumEdit
                if curveData.type == 1 then
                    local xNumEdit = NEnewNumEdit()
                    xNumEdit.min = -100
                    xNumEdit.max = 100
                    NEsetOnChange(xNumEdit, onNumEditChange)
                    xNumEdit.num = curveData.x[index]
                    curveRow.xNumEditArray[i] = xNumEdit
                    vmRowX[i] = xNumEdit
                    xNumEdit.row = row
                end
                i = i + 1
 
            end
        end
    end
end

local function enableAdjust()
    for i=1, #curvePointNumEditArray, 1 do
        replaceMix(curvePointNumEditArray[i].output, curvePointNumEditArray[i].revert, adjustMixSourceName)
    end
end
 
local function setSelectedChannelsAndMixSource(channels, revert, sourceName)
    adjustMixSourceName = sourceName
    LZ_clearTable(curvePointNumEditArray)
    curvePointNumEditArray = {}
    VMclear(viewMatrix.matrix)
    for i=1, #channels, 1 do
        curvePointNumEditArray[i] = {}
        curvePointNumEditArray[i].output=channels[i] - 1
        curvePointNumEditArray[i].revert = revert[i]
        getChannelCurve(curvePointNumEditArray[i], i)
    end
    VMupdateCurIVFocus(viewMatrix)
    enableAdjust()
end



local function init()
    initCurveLayout()
    viewMatrix = VMnewViewMatrix()
end

local function disableAdjust()
    for i=1, #curvePointNumEditArray, 1 do
        recoverMix(curvePointNumEditArray[i].output)
    end
end

local function doKey(event)
    viewMatrix.doKey(viewMatrix, event)
    if VMisEmpty(viewMatrix) then
        return false
    end
	if (event==36) then
        if VMgetCurIV(viewMatrix).row - scrollLine < 1 and scrollLine > 0 then
            scrollLine = scrollLine - 1
        end
	elseif (event==35) then
        if VMgetCurIV(viewMatrix).row - scrollLine > 3 then
            scrollLine = scrollLine + 1
        end
    elseif (event==37) then
        if viewMatrix.selectedCol - scrollCol > 4 then
            scrollCol = scrollCol + 1
        end
    elseif (event==38) then
        if viewMatrix.selectedCol - scrollCol < 1  then
            scrollCol = scrollCol - 1
        end
    elseif (event==EVT_EXIT_BREAK) then
        disableAdjust()
    end
end

local function drawHeadLine(yHead, hh)
    lcd.drawFilledRectangle(0, yHead - LZ_ui.headFillTopPad, LCD_W, hh + LZ_ui.headFillTopPad + LZ_ui.headFillBottomPad, FORCE)
    lcd.drawText(curveLeftPad, yHead, "ch", LZ_ui.font + LEFT + INVERS)
    lcd.drawText(curveXCurRight, yHead, "cur", LZ_ui.font + RIGHT + INVERS)
    for i = 1 + scrollCol, 10, 1 do
        local ax = curvePointAnchorX(i)
        if ax > LCD_W - 1 then
            break
        end
        lcd.drawText(ax, yHead, "p" .. i, LZ_ui.font + RIGHT + INVERS)
    end
end

local function getX(pointNum, index)
    return -100 + 200 / (pointNum-1) * (index - 1)
end 

local function drawOneRow(index, invers, yRowStart, rowSpan, subDy)
    local row = curvePointNumEditArray[index]
    local outputName = LZ_getOutputName(row.output)
    local y = yRowStart + (index - scrollLine - 1) * rowSpan
    lcd.drawLine(0, y + rowSpan - 1, LCD_W, y + rowSpan - 1, DOTTED, 0)
    lcd.drawText(curveLeftPad, y, outputName, LZ_ui.font + LEFT)
    lcd.drawText(curveXCurRight, y, LZ_getCurveName(row.curve), LZ_ui.font + RIGHT)
    for i = 1 + scrollCol, #row.yNumEditArray, 1 do
        local ax = curvePointAnchorX(i)
        if ax > LCD_W - 1 then
            break
        end
        IVdraw(row.yNumEditArray[i], ax, y, invers, LZ_ui.font + RIGHT)
        if row.xNumEditArray then
            IVdraw(row.xNumEditArray[i], ax, y + subDy, invers, LZ_ui.font + RIGHT)
        else
            lcd.drawText(ax, y + subDy, getX(#row.yNumEditArray, i), LZ_ui.font + RIGHT)
        end
    end
end

local function run(event, time)
    local invers = false
    if getRtcTime() % 2 == 1 then
        invers = true
    end
    local rs = LZ_ui.rowStep
    local hh = LZ_ui.headerRowHeight
    local rowSpan = rs * 2
    local subDy = rs
    local yThr = 0
    local yHead = rs
    local yRowStart = yHead + hh + LZ_ui.headFillTopPad + LZ_ui.headFillBottomPad + 1

    local adjRaw = 0
    if adjustMixSourceName then
        local fi = getFieldInfo(adjustMixSourceName)
        if fi then
            adjRaw = getValue(fi.id)
        end
    end
    lcd.drawText(curveLeftPad, yThr, adjustMixSourceName and (adjustMixSourceName .. ":") or "-:", LZ_ui.font + LEFT)
    lcd.drawText(crvXS1ValRight, yThr, math.floor(adjRaw * 100 / 1024), LZ_ui.font + RIGHT)
    lcd.drawText(crvOutLabelX, yThr, "output:", LZ_ui.font + LEFT)
    lcd.drawText(crvOutValRight, yThr, math.floor(adjRaw * 150 / 1024), LZ_ui.font + RIGHT)

    drawHeadLine(yHead, hh)
    for i = 1 + scrollLine, #curvePointNumEditArray, 1 do
        local y = yRowStart + (i - scrollLine - 1) * rowSpan
        if y + rowSpan > LCD_H then
            break
        end
        drawOneRow(i, invers, yRowStart, rowSpan, subDy)
    end

    return doKey(event)
end

local function bg()
    this.pageState = 1
    disableAdjust()
end

this = {run = run, init=init, setSelectedChannelsAndMixSource=setSelectedChannelsAndMixSource, bg = bg, pageState=0}
return this