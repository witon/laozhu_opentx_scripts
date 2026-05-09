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
        if selectedRow - scrollLine > 5 then
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
    lcd.drawFilledRectangle(0, 0, 128, 9, FORCE)
    lcd.drawText(2, 1, "name", LZ_ui.font + LEFT + INVERS)
    lcd.drawText(68, 1, "value", LZ_ui.font + RIGHT + INVERS)
    lcd.drawText(128, 1, "selected", LZ_ui.font + RIGHT + INVERS)
 
    for i=scrollLine + 1, scrollLine + 6, 1 do
        local output = model.getOutput(i-1)
        local option = 0
        if i <= 16 then
            if i==selectedRow then
                option = INVERS
                lcd.drawFilledRectangle(1, 9 * (i-scrollLine) + 1, 126, 9, FORCE)
            end
            if output.name == "" then
                lcd.drawText(2, 9 * (i-scrollLine)+2, i, LZ_ui.font + LEFT + option)
            else
                lcd.drawText(2, 9 * (i-scrollLine)+2, output.name, LZ_ui.font + LEFT + option)
            end
            lcd.drawText(68, 9 * (i-scrollLine)+2, getValue(i), LZ_ui.font + RIGHT + option)
            if channels[i] then
                lcd.drawText(128, 9 * (i-scrollLine)+2, "y", LZ_ui.font + RIGHT + option)
            else
                lcd.drawText(128, 9 * (i-scrollLine)+2, "n", LZ_ui.font + RIGHT + option)
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