
function MSgetText(index)
    if index < 0 then
        return "-"
    end
    local modeIndex, modeName= getFlightMode(index)
    if modeName == nil or modeName == "" then
        return "FM" .. index
    end
    return modeName 
end

function MSinc(selector)
    if selector.selectedIndex >= 8 then
        return false
    end
    selector.selectedIndex = selector.selectedIndex + 1
    return true
end

function MSdec(selector)
    if selector.selectedIndex < 0 then
        return false
    end
    selector.selectedIndex = selector.selectedIndex - 1
    return true
end



function SsetSelectFun(selector, incFun, decFun)
    selector.incFun = incFun
    selector.decFun = decFun
end


function MSnewModeSelector()
    local modeSelector = SnewSelector()
    SsetSelectFun(modeSelector, MSinc, MSdec)
    SsetTextFun(modeSelector, MSgetText)
    return modeSelector
end
