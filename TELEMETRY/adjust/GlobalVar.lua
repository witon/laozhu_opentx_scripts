
local gvNumEditArray = {}
local ivArray = nil
local scrollLine = 0

local function getGVValue(index, mode)
    local value = model.getGlobalVariable(index, mode)
    if value >= 1025 then
        return getGVValue(index, value - 1025)
    end
    return value
end

local function setGVValue(index, mode, value)
    local curValue = model.getGlobalVariable(index, mode)
    if curValue >= 1025 then
        setGVValue(index, curValue - 1025, value)
    else
        model.setGlobalVariable(index, mode, value)
    end
end

local function readGVValue()
    for i=1, 4, 1 do
        for j=1, 9, 1 do
            gvNumEditArray[i][j].num = getGVValue(i-1, j-1)
        end
    end

end

local function onNumEditChange(numEdit)
    setGVValue(numEdit.index, numEdit.mode, numEdit.num)
    readGVValue()
end

local curIvIndex = 1
local curIvColIndex = 1
local editingIv = nil

local function init()
    for i=1, 4, 1 do 
        gvNumEditArray[i] = {}
        for j=1, 9, 1 do
            gvNumEditArray[i][j] = NEnewNumEdit()
            gvNumEditArray[i][j].num = -10
            NEsetOnChange(gvNumEditArray[i][j], onNumEditChange)
            --NEsetRange(gvNumEditArray[i][j], -150, 150)
            gvNumEditArray[i][j].num = getGVValue(i-1, j-1)
            gvNumEditArray[i][j].mode = j - 1
            gvNumEditArray[i][j].index = i - 1
        end
    end
    ivArray = gvNumEditArray[curIvColIndex]
    dofile(gScriptDir .. "TELEMETRY/adjust/ReplaceMix.lua")
end


local function doKey(event)
    if editingIv then
        if(event == EVT_EXIT_BREAK or event == EVT_ENTER_BREAK) then
            IVsetFocusState(editingIv, 1)
            editingIv = nil
            return true
        end
        editingIv.doKey(editingIv, event)
        return true
    end
 
    if(event == EVT_ENTER_BREAK) then
        editingIv = ivArray[curIvIndex]
        IVsetFocusState(editingIv, 2)
        return true
    end
    local eventProcessed = false

    local preFocus = ivArray[curIvIndex]
	if (event==36 or event==68) then
        if curIvIndex > 1 then
            curIvIndex = curIvIndex - 1
            if scrollLine - curIvIndex > -2 and scrollLine > 0 then
                scrollLine = scrollLine - 1
            end
 
        end
        eventProcessed = true
	elseif (event==35 or event==67) then
        if curIvIndex < #ivArray then
            curIvIndex = curIvIndex + 1
            if curIvIndex - scrollLine > 5 then
                scrollLine = scrollLine + 1
            end
        end
        eventProcessed = true
    elseif (event==38) then
        if curIvColIndex > 1 then
            curIvColIndex = curIvColIndex - 1
            ivArray = gvNumEditArray[curIvColIndex]
        end
        eventProcessed = true
    elseif (event == 37) then
        if curIvColIndex < 4 then
            curIvColIndex = curIvColIndex + 1
            ivArray = gvNumEditArray[curIvColIndex]
        end
        eventProcessed = true
    end
    IVsetFocusState(preFocus, 0)
    IVsetFocusState(ivArray[curIvIndex], 1)
    return eventProcessed
end

local function run(event, time)
    local invers = false
    if getRtcTime() % 2 == 1 then
        invers = true
    end
    lcd.drawText(2, 0, "mode", SMLSIZE + LEFT)
    lcd.drawText(2 + 48 + adjustCfg.getNumberField("flapGvIndex", 0) * 24, 0, "flap", SMLSIZE + RIGHT)
    lcd.drawText(2 + 48 + adjustCfg.getNumberField("eleGvIndex", 0) * 24, 0, "ele", SMLSIZE + RIGHT)
    lcd.drawText(2 + 48 + adjustCfg.getNumberField("drGvIndex", 0) * 24, 0, "dr", SMLSIZE + RIGHT)
    lcd.drawText(2 + 48 + adjustCfg.getNumberField("edrGvIndex", 0) * 24, 0, "edr", SMLSIZE + RIGHT)
    

    local curModeIndex = getFlightMode()
    local index, name = getFlightMode(0)
    lcd.drawText(1, 10, name, SMLSIZE + LEFT)
    if curModeIndex==0 then
        lcd.drawText(lcd.getLastPos(), 10, "*", SMLSIZE + BLINK +  LEFT)
    end
 
    for j=1, 4, 1 do
        IVdraw(gvNumEditArray[j][1], 48 + (j-1) * 25, 10, invers)
    end

    for i=scrollLine + 2, 9, 1 do
        --lcd.drawText(4, (i-scrollLine)*10, i-1, SMLSIZE + LEFT)
        index, name = getFlightMode(i-1)
        lcd.drawText(1, (i-scrollLine)*10, name, SMLSIZE + LEFT)
        if curModeIndex==i-1 then
            lcd.drawText(lcd.getLastPos(), (i-scrollLine)*10, "*", SMLSIZE + BLINK +  LEFT)
        end
 
    end

    for i = 1, 4, 1 do
        for j=scrollLine + 2, 9, 1 do
            IVdraw(gvNumEditArray[i][j], 48 + (i-1) * 25, 10*(j-scrollLine), invers)
        end
    end
    return doKey(event)
end

return {run = run, init=init}