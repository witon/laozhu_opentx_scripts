local channels = {}
local scrollLine = 0
local selectedRow = 1
local function init()
    for i=1, 16, 1 do
        channels[i] = false
    end
end

local function doKey(event)
    if event==36 then
        selectedRow = selectedRow - 1
        if selectedRow < 1 then
            selectedRow = 1
        end
        if selectedRow - scrollLine < 1 then
            scrollLine = scrollLine - 1
        end
    elseif event==35 then
        selectedRow = selectedRow + 1
        if selectedRow > 16 then
            selectedRow = 16
        end
        if selectedRow - scrollLine > 4 then
                scrollLine = scrollLine + 1
        end
        if scrollLine > 12 then
            scrollLine = 12 
        end
    elseif event==EVT_ENTER_BREAK then
        channels[selectedRow] = not channels[selectedRow]
    end
end

local function run(event, time)
    lcd.drawText(2, 1, "thr:", SMLSIZE + LEFT)
    lcd.drawText(34, 1, getValue("thr"), SMLSIZE+LEFT)
    lcd.drawText(64, 1, "adj:", SMLSIZE + LEFT)
    lcd.drawText(2, 11, "name", SMLSIZE + LEFT)
    lcd.drawText(68, 11, "value", SMLSIZE + RIGHT)
    lcd.drawText(128, 11, "selected", SMLSIZE + RIGHT)
 
    for i=scrollLine + 1, scrollLine + 6, 1 do
        local output = model.getOutput(i-1)
        local option = 0
        if i <= 16 then
            if i==selectedRow then
                option = INVERS
                lcd.drawFilledRectangle(1, 10 * (i-scrollLine + 1) - 1, 127, 10)
            end
            if output.name == "" then
                lcd.drawText(2, 10 * (i-scrollLine + 1), i, SMLSIZE + LEFT + option)
            else
                lcd.drawText(2, 10 * (i-scrollLine + 1), output.name, SMLSIZE + LEFT + option)
            end
            lcd.drawText(68, 10 * (i-scrollLine + 1), getValue(i), SMLSIZE + RIGHT + option)
            if channels[i] then
                lcd.drawText(128, 10 * (i-scrollLine + 1), "y", SMLSIZE + RIGHT + option)
            else
                lcd.drawText(128, 10 * (i-scrollLine + 1), "n", SMLSIZE + RIGHT + option)
            end
        end
    end
    return doKey(event)
end

local function getSelectedChannels(selectedChannels)
    for i=1, #channels, 1 do
        if channels[i] then
            selectedChannels[#selectedChannels + 1] = i
        end
    end
end

local function setSelectedChannels(selectedChannels)
    for i=1, #selectedChannels, 1 do
        channels[selectedChannels[i]] = true
    end
end

return {run = run, init=init, getSelectedChannels=getSelectedChannels, setSelectedChannels=setSelectedChannels}