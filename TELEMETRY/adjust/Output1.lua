local outputNumEditArray = {}
local outputNameArray = {}
local scrollLine = 0
local selectedRow = 1
local selectedCol = 1

local function onOutputSelectorChange(outputSelector)
end

local function onAdjustCheckBoxChange(checkBox)
end

local function onReverseCheckBoxChange(checkBox)
end


local function onNumEditChange(numEdit)
end

local curIvIndex = 1
local editingIv = nil

local function newParamNe()
    local ne = NEnewNumEdit()
    ne.max = 99
    ne.min = -99
    return ne
end

local function getOutputValue(index, neRow)
    local output = model.getOutput(index)
    neRow[1].num = math.ceil(output.min * 99 / 1500)
    neRow[2].num = math.ceil(output.offset * 99 / 1500)
    neRow[3].num = math.ceil(output.max * 99 / 1500)
    neRow[4].num = math.ceil(output.offset * 99 / 1500)
    neRow[5].num = math.ceil(output.max * 99 / 1500)
 
    outputNameArray[index + 1] = output.name
    if output.name == "" then
        outputNameArray[index + 1] = index + 1
    end
end

local function saveOutputValue(index, neRow)
    local output = model.getOutput(index)
    output.min = neRow[1].num
    output.offset = neRow[1].num
    output.max = neRow[2].num
    model.setOutput(index, output)
end

local function init()
    LZ_runModule(gScriptDir .. "TELEMETRY/adjust/ReplaceMix.lua")
    for i=1, 16, 1 do
        local outputNe = {}
        for j=1, 5, 1 do
           outputNe[j] = newParamNe()
        end
        outputNumEditArray[i] = outputNe
        getOutputValue(i-1, outputNe)
    end
    IVsetFocusState(outputNumEditArray[selectedRow][selectedCol], 1)
end



local function doKey(event)
    if event == 38 then
        IVsetFocusState(outputNumEditArray[selectedRow][selectedCol], 0)
        selectedCol = selectedCol - 1
        if selectedCol < 1 then
            selectedCol = 1
        end
       IVsetFocusState(outputNumEditArray[selectedRow][selectedCol], 1)
    elseif event==37 then
        IVsetFocusState(outputNumEditArray[selectedRow][selectedCol], 0)
        selectedCol = selectedCol + 1
        if selectedCol > 3 then
            selectedCol = 3
        end
        IVsetFocusState(outputNumEditArray[selectedRow][selectedCol], 1)
    elseif event==36 then
        IVsetFocusState(outputNumEditArray[selectedRow][selectedCol], 0)
        selectedRow = selectedRow - 1
        if selectedRow < 1 then
            selectedRow = 1
        end
        if selectedRow - scrollLine < 1 then
            scrollLine = scrollLine - 1
        end
        IVsetFocusState(outputNumEditArray[selectedRow][selectedCol], 1)
    elseif event==35 then
        IVsetFocusState(outputNumEditArray[selectedRow][selectedCol], 0)
        selectedRow = selectedRow + 1
        if selectedRow > 16 then
            selectedRow = 16
        end
        if selectedRow - scrollLine > 5 then
                scrollLine = scrollLine + 1
        end
        if scrollLine > 11 then
            scrollLine = 11 
        end

        IVsetFocusState(outputNumEditArray[selectedRow][selectedCol], 1)
    end
end

local function run(event, time)
    local invers = false
    if getRtcTime() % 2 == 1 then
        invers = true
    end
    lcd.drawText(2, 1, "thr:", SMLSIZE + LEFT)
    lcd.drawText(34, 1, getValue("thr"), SMLSIZE+LEFT)
    lcd.drawText(64, 1, "adj:", SMLSIZE + LEFT)
    for i=scrollLine + 1, scrollLine + 6, 1 do
        if i <= 16 then
            lcd.drawText(2, 10 * (i-scrollLine), outputNameArray[i])
            for j=1, 5, 1 do
                if i <= 16 then
                    IVdraw(outputNumEditArray[i][j], 20 + 15 * (j), 10 * (i - scrollLine), invers)
                end
            end
        end
    end

    return doKey(event)
end

return {run = run, init=init}