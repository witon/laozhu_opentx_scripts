
function SsetTextFun(selector, textFun)
    selector.textFun = textFun
end

function SsetSelectFun(selector, incFun, decFun)
    selector.incFun = incFun
    selector.decFun = decFun
end

function SgetSelectedText(selector)
    if selector.textFun then
        return selector.textFun(selector.selectedIndex)
    else
        return string.tostring(selector.selectedIndex)
    end
end

function SdoKey(selector, event)
    if event == 35 or event == 67 then
        local changed = selector.incFun(selector)
        if changed and selector.onChange then
            selector.onChange(selector)
        end
    elseif event == 36 or event == 68 then
        local changed = selector.decFun(selector)
        if changed and selector.onChange then
            selector.onChange(selector)
        end
    end
end

function SsetOnChange(selector, onChange)
    selector.onChange = onChange
end

function Sdraw(selector, x, y, invers, option)
    lcd.drawText(x, y, SgetSelectedText(selector), option)
end

function SnewSelector()
    return {selectedIndex = -1,
            textFun = nil,
            focusState = 0,
            draw = Sdraw,
            doKey = SdoKey}
end

function Sunload()
    SsetTextFun = nil
    SsetSelectFun = nil
    SgetSelectedText = nil
    SdoKey = nil
    SsetOnChange = nil
    Sdraw = nil
    SnewSelector = nil
    Sunload = nil
end
