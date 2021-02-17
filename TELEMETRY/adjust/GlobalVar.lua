
local gvNameEditArray = {}
local gvNumEditArray = {}
local scrollLine = 0
local viewMatrix = nil
local this = nil
local curGetGVIndex = -1

local function getGVValue(index, mode)
    local value = model.getGlobalVariable(index, mode)
    while value >= 1025 do
        value = model.getGlobalVariable(index, value - 1025)
    end
    return value
end

local function startGetAllGVValue()
    curGetGVIndex = 0
end


local function getGVName()
    for i=1, 4, 1 do
        gvNameEditArray[i].str = adjustCfg.getStrField("gvname" .. i)
        if gvNameEditArray[i].str == "" then
            gvNameEditArray[i].str = tostring(i)
        end
    end
end

local function setGVValue(index, mode, value)
    local curValue = model.getGlobalVariable(index, mode)
    if curValue >= 1025 then
        setGVValue(index, curValue - 1025, value)
    else
        model.setGlobalVariable(index, mode, value)
    end
end

local function readGVValue(gvIndex)
    for i=1, 9, 1 do
        gvNumEditArray[i][gvIndex].num = getGVValue(gvIndex-1, i-1)
        print("----------", i)
    end
end

local function onNumEditChange(numEdit)
    setGVValue(numEdit.index, numEdit.mode, numEdit.num)
    curGetGVIndex = 0
end

local function onTextEditChange(textEdit)
    local cfgs = adjustCfg.getCfgs()
    for i=1, #gvNameEditArray, 1 do
        cfgs["gvname" .. i] = gvNameEditArray[i].str
    end
    adjustCfg.writeToFile(gConfigFileName)
 

end

local function init()
    for i=1, 9, 1 do 
        gvNumEditArray[i] = {}
        for j=1, 4, 1 do
            gvNumEditArray[i][j] = NEnewNumEdit()
            NEsetOnChange(gvNumEditArray[i][j], onNumEditChange)
            gvNumEditArray[i][j].num = 0 --getGVValue(j-1, i-1)
            gvNumEditArray[i][j].mode = i - 1
            gvNumEditArray[i][j].index = j - 1
        end
    end

    viewMatrix = VMnewViewMatrix()
    viewMatrix.matrix[1] = {}
    for j=1, 4, 1 do
        gvNameEditArray[j] = TEnewTextEdit()
        gvNameEditArray[j].str = tostring(j)
        TEsetOnChange(gvNameEditArray[j], onTextEditChange)
        viewMatrix.matrix[1][j] = gvNameEditArray[j]
    end
    for i=1, #gvNumEditArray, 1 do
        viewMatrix.matrix[i+1] = {}
        for j=1, #gvNumEditArray[i], 1 do
            viewMatrix.matrix[i+1][j] = gvNumEditArray[i][j]
        end
    end
    viewMatrix.selectedRow = 2
    IVsetFocusState(viewMatrix.matrix[viewMatrix.selectedRow][viewMatrix.selectedCol], 1)
    getGVName()
    curGetGVIndex = 0
end


local function doKey(event)
    viewMatrix.doKey(viewMatrix, event)
	if (event==36 or event==68) then
        if viewMatrix.selectedRow - scrollLine < 3 and scrollLine > 0 then
            scrollLine = scrollLine - 1
        end
	elseif (event==35 or event==67) then
        if viewMatrix.selectedRow - scrollLine > 6 then
            scrollLine = scrollLine + 1
        end
    end
end

local function run(event, time)
    if curGetGVIndex >= 0 then
        curGetGVIndex = curGetGVIndex + 1
        readGVValue(curGetGVIndex)
        if curGetGVIndex == 4 then
            curGetGVIndex = -1
        end
    end

    local invers = false
    if getRtcTime() % 2 == 1 then
        invers = true
    end
    lcd.drawText(2, 0, "mode", SMLSIZE + LEFT)

    local curModeIndex = getFlightMode()
    local index, name = getFlightMode(0)
    lcd.drawText(0, 12, name, SMLSIZE + LEFT)
    if curModeIndex==0 then
        lcd.drawText(lcd.getLastPos(), 10, "*", SMLSIZE + BLINK +  LEFT)
    end

    lcd.drawLine(0, 9, 128, 9, DOTTED, 0)
    for j=1, 4, 1 do
        IVdraw(gvNameEditArray[j], 48 + (j-1) * 25, 1, invers, SMLSIZE + RIGHT)
        IVdraw(gvNumEditArray[1][j], 48 + (j-1) * 25, 12, invers, SMLSIZE + RIGHT)
    end

    for i=scrollLine + 2, 9, 1 do
        local y = (i-scrollLine)*8 + 4
        index, name = getFlightMode(i-1)
        lcd.drawText(0, y, name, SMLSIZE + LEFT)
        if curModeIndex==i-1 then
            lcd.drawText(lcd.getLastPos(), y, "*", SMLSIZE + BLINK +  LEFT)
        end
 
    end

    for i = 1, 4, 1 do
        for j=scrollLine + 2, 9, 1 do
            local y = (j-scrollLine)*8 + 4
            IVdraw(gvNumEditArray[j][i], 48 + (i-1) * 25, y, invers, SMLSIZE + RIGHT)
        end
    end
    return doKey(event)
end

local function bg()

end

this = {run=run, init=init, bg=bg, pageState=0}

return this