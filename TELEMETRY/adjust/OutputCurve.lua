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
        for i=1, curveData.points, 1 do
            curveRow.yNumEditArray[i].num = curveData.y[i-1]
            if curveData.type == 1 then
                curveRow.xNumEditArray[i].num = curveData.x[i-1]
            end
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
            for i=1, curveData.points, 1 do
                local yNumEdit = NEnewNumEdit()
                yNumEdit.min = -100
                yNumEdit.max = 100
                NEsetOnChange(yNumEdit, onNumEditChange)
                yNumEdit.num = curveData.y[i-1]
                curveRow.yNumEditArray[i] = yNumEdit
                yNumEdit.row = row
                vmRowY[i] = yNumEdit
                if curveData.type == 1 then
                    local xNumEdit = NEnewNumEdit()
                    xNumEdit.min = -100
                    xNumEdit.max = 100
                    NEsetOnChange(xNumEdit, onNumEditChange)
                    xNumEdit.num = curveData.x[i-1]
                    curveRow.xNumEditArray[i] = xNumEdit
                    vmRowX[i] = xNumEdit
                    xNumEdit.row = row
                end
            end
        end
    end
end

local function enableAdjust()
    for i=1, #curvePointNumEditArray, 1 do
        replaceMix(curvePointNumEditArray[i].output, curvePointNumEditArray[i].revert)
    end
end
 
local function setSelectedChannels(channels, revert)
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
	if (event==36 or event==68 or event==4099) then
        if VMgetCurIV(viewMatrix).row - scrollLine < 1 and scrollLine > 0 then
            scrollLine = scrollLine - 1
        end
	elseif (event==35 or event==67 or event==4100) then
        if VMgetCurIV(viewMatrix).row - scrollLine > 3 then
            scrollLine = scrollLine + 1
        end
    elseif (event==37 or event ==99) then
        if viewMatrix.selectedCol - scrollCol > 4 then
            scrollCol = scrollCol + 1
        end
    elseif (event==38 or event ==98) then
        if viewMatrix.selectedCol - scrollCol < 1  then
            scrollCol = scrollCol - 1
        end
    elseif (event==EVT_EXIT_BREAK) then
        disableAdjust()
    end
end

local function drawHeadLine()
    lcd.drawFilledRectangle(0, 7, 128, 8, FORCE)
    lcd.drawText(0, 8, "ch", SMLSIZE + LEFT + INVERS)
    lcd.drawText(33, 8, "cur", SMLSIZE + RIGHT + INVERS)
 
    for i=1+scrollCol, 10, 1 do
        lcd.drawText(33 + 20 * (i-scrollCol), 8, "p" .. i, SMLSIZE + RIGHT + INVERS)
    end
 
end

local function getX(pointNum, index)
    return -100 + 200 / (pointNum-1) * (index - 1)
end 

local function drawOneRow(index, invers)
    local row = curvePointNumEditArray[index]
    local outputName = LZ_getOutputName(row.output)
    local y = 17 * (index - scrollLine) - 1
    lcd.drawLine(0, y+15, 128, y+15, DOTTED, 0)
    lcd.drawText(0, y, outputName, SMLSIZE + LEFT)
    lcd.drawText(34, y, LZ_getCurveName(row.curve), SMLSIZE + RIGHT)
    for i=1+scrollCol, #row.yNumEditArray, 1 do
        IVdraw(row.yNumEditArray[i], 35 + 20 * (i-scrollCol), y, invers, SMLSIZE + RIGHT)
        if row.xNumEditArray then
            IVdraw(row.xNumEditArray[i], 35 + 20 * (i-scrollCol), y + 8, invers, SMLSIZE + RIGHT)
        else
            lcd.drawText(35 + 20 * (i-scrollCol), y + 8, getX(#row.yNumEditArray, i), SMLSIZE + RIGHT)
        end
    end
end

local function run(event, time)
    local invers = false
    if getRtcTime() % 2 == 1 then
        invers = true
    end

    lcd.drawText(2, 0, "thr:", SMLSIZE + LEFT)
    lcd.drawText(22, 0, math.floor(getValue("thr") * 100 / 1024), SMLSIZE+LEFT)
    lcd.drawText(64, 0, "output:", SMLSIZE + LEFT)
    lcd.drawText(98, 0, math.floor(getValue("thr") * 150/1024), SMLSIZE+LEFT)
 
    drawHeadLine()
    for i=1 + scrollLine, #curvePointNumEditArray, 1 do
        drawOneRow(i, invers)
    end

    return doKey(event)
end

local function bg()
    this.pageState = 1
    disableAdjust()
end

this = {run = run, init=init, setSelectedChannels=setSelectedChannels, bg = bg, pageState=0}
return this