
function TSgetText(index)
    if index == 0 then
        return "Train"
    elseif index == 1 then
        return "LastFl"
    elseif index == 2 then
        return "AULD"
    elseif index == 3 then
        return "TEST"
    else
        return "-"
    end
end

function TSsetTask(selector, taskName)
    if taskName == "Train" then
        selector.selectedIndex = 0
    elseif taskName == "LastFl" then
        selector.selectedIndex = 1
    elseif taskName == "AULD" then
        selector.selectedIndex = 2
    elseif taskName == "TEST" then
        selector.selectedIndex = 3
    else
        selector.selectedIndex = -1
    end
end


function TSinc(selector)
    if selector.selectedIndex >= 3 then
        return false
    end
    selector.selectedIndex = selector.selectedIndex + 1
    return true
end

function TSdec(selector)
    if selector.selectedIndex <= 0 then
        return false
    end
    selector.selectedIndex = selector.selectedIndex - 1
    return true
end



function TSnewTaskSelector()
    local taskSelector = SnewSelector()
    taskSelector.selectedIndex = 0
    SsetSelectFun(taskSelector, TSinc, TSdec)
    SsetTextFun(taskSelector, TSgetText)
    return taskSelector
end

function TSunload()
    TSgetText = nil
    TSsetTask = nil
    TSinc = nil
    TSdec = nil
    TSnewTaskSelector = nil
    TSunload = nil
end
