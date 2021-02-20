
function OSdoKey(selector, event)
    if event == 35 or event == 67 then
        selector.selectedIndex = selector.selectedIndex + 1
        local outputName = LZ_getOutputName(selector.selectedIndex)
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
        local outputName = LZ_getOutputName(selector.selectedIndex)
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


function OSdraw(selector, x, y, invers, option)
    lcd.drawText(x, y, selector.selectedName, option)
end

function OSnewOutputSelector()
    return {selectedIndex = 0,
            selectedName = LZ_getOutputName(0),
            focusState = 0,
            draw = OSdraw,
            doKey = OSdoKey}
end

function OSunload()
    OSdoKey = nil
    OSsetOnChange = nil
    OSdraw = nil
    OSnewOutputSelector = nil
    OSunload = nil
end