
local function getOutputName(index)
    local output = model.getOutput(index)
    if not output then
        return nil
    end
    if output.name == "" then
        return "ch" .. (index + 1)
    end
    return output.name
end
function OSdoKey(selector, event)
    if event == 35 or event == 67 then
        selector.selectedIndex = selector.selectedIndex + 1
        local outputName = getOutputName(selector.selectedIndex)
        if not outputName then
            selector.selectedIndex = selector.selectedIndex - 1
            return
        end
        selector.selectedName = outputName
        if selector.onChange then
            selector.onChange(selector)
        end
    elseif event == 36 or event == 68 then
        selector.selectedIndex = selector.selectedIndex - 1
        local outputName = getOutputName(selector.selectedIndex)
        if not outputName then
            selector.selectedIndex = selector.selectedIndex + 1
            return
        end
        selector.selectedName = outputName
        if selector.onChange then
            selector.onChange(selector)
        end
    end
end

function OSsetOnChange(selector, onChange)
    selector.onChange = onChange
end


function OSdraw(selector, x, y, invers)
    lcd.drawText(x, y, selector.selectedName, invers)
end

function OSnewOutputSelector()
    return {selectedIndex = 0,
            selectedName = getOutputName(0),
            isFocuse = false,
            focusState = 0,
            draw = OSdraw,
            doKey = OSdoKey}
end
