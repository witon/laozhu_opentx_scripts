

function CSdoKey(selector, event)
    if event == 35 or event == 67 or event == 4100 then
        selector.selectedIndex = selector.selectedIndex + 1
        local curveName = LZ_getCurveName(selector.selectedIndex)
        if not curveName then
            selector.selectedIndex = selector.selectedIndex - 1
            return
        end
        selector.selectedName = curveName 
        if selector.onChange then
            selector.onChange(selector)
        end
    elseif event == 36 or event == 68 or event == 4099 then
        selector.selectedIndex = selector.selectedIndex - 1
        local curveName = LZ_getCurveName(selector.selectedIndex)
        if not curveName then
            selector.selectedIndex = selector.selectedIndex + 1
            return
        end
        selector.selectedName = curveName
        if selector.onChange then
            selector.onChange(selector)
        end
    end
end

function CSsetOnChange(selector, onChange)
    selector.onChange = onChange
end


function CSdraw(selector, x, y, invers, option)
    lcd.drawText(x, y, selector.selectedName, option)
end

function CSnewCurveSelector()
    return {selectedIndex = -1,
            selectedName = LZ_getCurveName(-1),
            focusState = 0,
            draw = CSdraw,
            doKey = CSdoKey}
end

function CSunload()
    CSdoKey = nil
    CSsetOnChange = nil
    CSdraw = nil
    CSnewCurveSelector = nil
    CSunload = nil
end
