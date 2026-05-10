
local gvNameEditArray = {}
local gvNumEditArray = {}
local scrollLine = 0
local scrollCol = 0
local viewMatrix = nil
local this = nil
local curGetGVIndex = -1

local configFileName = "output.cfg"
local outputCfg = nil

local function loadModule()
    LZ_runModule(gSDCardDir .. "LAOZHU/uilib/InputView.lua")
    LZ_runModule(gSDCardDir .. "LAOZHU/uilib/ViewMatrix.lua")
    LZ_runModule(gSDCardDir .. "LAOZHU/uilib/TextEdit.lua")
    LZ_runModule(gSDCardDir .. "LAOZHU/uilib/NumEdit.lua")
    LZ_runModule(gSDCardDir .. "LAOZHU/CfgO.lua")
end

local function unloadModule()
    IVunload()
    VMunload()
    TEunload()
    NEunload()
    CFGC = nil
end

local function startGetAllGVValue()
    curGetGVIndex = 1
end

local function getGVName()
    for i=1, 6, 1 do
        gvNameEditArray[i].str = outputCfg:getStrField("gvname" .. i)
        if gvNameEditArray[i].str == "" then
            gvNameEditArray[i].str = tostring(i)
        end
    end
end


local function readOneGVValue(gvIndex)
    for i=1, 9, 1 do
       gvNumEditArray[i][gvIndex].num = LZ_getGVValue(gvIndex-1, i-1)
    end
end

local function onNumEditChange(numEdit)
    LZ_setGVValue(numEdit.index, numEdit.mode, numEdit.num)
    startGetAllGVValue()
end

local function onTextEditChange(textEdit)
    for i=1, #gvNameEditArray, 1 do
        outputCfg.kvs["gvname" .. i] = gvNameEditArray[i].str
    end
    outputCfg:writeToFile(configFileName)
end



local function doKey(event)
    local ret = viewMatrix.doKey(viewMatrix, event)
	if (event==36) then
        if viewMatrix.selectedRow - scrollLine < 3 and scrollLine > 0 then
            scrollLine = scrollLine - 1
        end
	elseif (event==35) then
        if viewMatrix.selectedRow - scrollLine > 6 then
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
    end
    if not ret and event == EVT_EXIT_BREAK then
        this.pageState = 1
        unloadModule()
    end
    return ret
end

local function run(event, time)
    if curGetGVIndex >= 0 then
        readOneGVValue(curGetGVIndex)
        curGetGVIndex = curGetGVIndex + 1
        if curGetGVIndex == 7 then
            curGetGVIndex = -1
        end
    end

    local invers = false
    if getRtcTime() % 2 == 1 then
        invers = true
    end
    local rs = LZ_ui.rowStep
    local hh = LZ_ui.headerRowHeight
    lcd.drawFilledRectangle(0, 0, LCD_W, hh, FORCE)
    lcd.drawText(0, 0, "mode", LZ_ui.font + LEFT + INVERS)

    local curModeIndex = getFlightMode()
    local index, name = getFlightMode(0)
    if name == "" then
        name = "FM0"
    end
    local yGv = hh + 1
    local yFm0 = yGv + rs
    lcd.drawText(0, yFm0, name, LZ_ui.font + LEFT)
    if curModeIndex == 0 then
        lcd.drawText(lcd.getLastPos(), yFm0, "*", LZ_ui.font + BLINK + LEFT)
    end

    lcd.drawLine(0, yFm0 - 1, LCD_W, yFm0 - 1, DOTTED, 0)

    local yList0 = yFm0 + rs
    for i = scrollLine + 2, 9, 1 do
        local y = yList0 + (i - scrollLine - 2) * rs
        index, name = getFlightMode(i - 1)
        if name == "" then
            name = "FM" .. i - 1
        end
        lcd.drawText(0, y, name, LZ_ui.font + LEFT)
        if curModeIndex == i - 1 then
            lcd.drawText(lcd.getLastPos(), y, "*", LZ_ui.font + BLINK + LEFT)
        end
    end

    for i = scrollCol + 1, 6, 1 do
        local x = 48 + (i - 1 - scrollCol) * 25
        IVdraw(gvNameEditArray[i], x, yGv, invers, LZ_ui.font + RIGHT)
        IVdraw(gvNumEditArray[1][i], x, yFm0, invers, LZ_ui.font + RIGHT)
        for j = scrollLine + 2, scrollLine + 7, 1 do
            if j > 9 then
                break
            end
            local y = yList0 + (j - scrollLine - 2) * rs
            IVdraw(gvNumEditArray[j][i], x, y, invers, LZ_ui.font + RIGHT)
        end
    end
    return doKey(event)
end

local function bg()

end

--local function init()
    loadModule()
    outputCfg = CFGC:new()
	outputCfg:readFromFile(configFileName)

    viewMatrix = VMnewViewMatrix()
    viewMatrix.matrix[1] = {}
    for j=1, 6, 1 do
        gvNameEditArray[j] = TEnewTextEdit()
        gvNameEditArray[j].str = tostring(j)
        TEsetOnChange(gvNameEditArray[j], onTextEditChange)
        viewMatrix.matrix[1][j] = gvNameEditArray[j]
    end

    for i=1, 9, 1 do 
        gvNumEditArray[i] = {}
        viewMatrix.matrix[i+1] = {}
        for j=1, 6, 1 do
            gvNumEditArray[i][j] = NEnewNumEdit()
            NEsetOnChange(gvNumEditArray[i][j], onNumEditChange)
            gvNumEditArray[i][j].num = 0
            gvNumEditArray[i][j].mode = i - 1
            gvNumEditArray[i][j].index = j - 1
            viewMatrix.matrix[i+1][j] = gvNumEditArray[i][j]
        end
    end
    viewMatrix.selectedRow = 2
    IVsetFocusState(viewMatrix.matrix[viewMatrix.selectedRow][viewMatrix.selectedCol], 1)
    getGVName()
    startGetAllGVValue()
--end

this = {run=run, bg=bg, pageState=0}

return this