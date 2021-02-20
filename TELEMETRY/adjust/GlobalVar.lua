
local gvNameEditArray = {}
local gvNumEditArray = {}
local scrollLine = 0
local scrollCol = 0
local viewMatrix = nil
local this = nil
local curGetGVIndex = -1
local adjustCfg = nil

local function loadModule()
    LZ_runModule(gScriptDir .. "TELEMETRY/common/InputView.lua")
    LZ_runModule(gScriptDir .. "TELEMETRY/common/ViewMatrix.lua")
    LZ_runModule(gScriptDir .. "TELEMETRY/common/TextEdit.lua")
    LZ_runModule(gScriptDir .. "TELEMETRY/common/NumEdit.lua")
end

local function unloadModule()
    IVunload()
    VMunload()
    TEunload()
    NEunload()
end

local function startGetAllGVValue()
    curGetGVIndex = 1
end

local function getGVName()
    for i=1, 6, 1 do
        gvNameEditArray[i].str = adjustCfg.getStrField("gvname" .. i)
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
    local cfgs = adjustCfg.getCfgs()
    for i=1, #gvNameEditArray, 1 do
        cfgs["gvname" .. i] = gvNameEditArray[i].str
    end
    adjustCfg.writeToFile(gConfigFileName)
end

local function init()
    loadModule()
	adjustCfg = LZ_runModule(gScriptDir .. "/LAOZHU/Cfg.lua")
	adjustCfg.readFromFile(gConfigFileName)

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
end


local function doKey(event)
    local ret = viewMatrix.doKey(viewMatrix, event)
	if (event==36 or event==68) then
        if viewMatrix.selectedRow - scrollLine < 3 and scrollLine > 0 then
            scrollLine = scrollLine - 1
        end
	elseif (event==35 or event==67) then
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
        if curGetGVIndex == 6 then
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
    if name == "" then
        name = "FM0"
    end
    lcd.drawText(0, 12, name, SMLSIZE + LEFT)
    
    if curModeIndex==0 then
        lcd.drawText(lcd.getLastPos(), 10, "*", SMLSIZE + BLINK +  LEFT)
    end

    lcd.drawLine(0, 9, 128, 9, DOTTED, 0)

    for i=scrollLine + 2, 9, 1 do
        local y = (i-scrollLine)*8 + 4
        index, name = getFlightMode(i-1)
        if name == "" then
            name = "FM" .. i - 1
        end
        lcd.drawText(0, y, name, SMLSIZE + LEFT)
        if curModeIndex==i-1 then
            lcd.drawText(lcd.getLastPos(), y, "*", SMLSIZE + BLINK +  LEFT)
        end
 
    end

    for i = scrollCol+1, 6, 1 do
        local x = 48 + (i-1-scrollCol) * 25
        IVdraw(gvNameEditArray[i], x, 1, invers, SMLSIZE + RIGHT)
        IVdraw(gvNumEditArray[1][i], x, 12, invers, SMLSIZE + RIGHT)
        for j=scrollLine + 2, scrollLine + 7, 1 do
            if j>9 then
                break
            end
            local y = (j-scrollLine)*8 + 4
            IVdraw(gvNumEditArray[j][i], x, y, invers, SMLSIZE + RIGHT)
        end
    end
    return doKey(event)
end

local function bg()

end

this = {run=run, init=init, bg=bg, pageState=0}

return this