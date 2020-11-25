

function ISnewInputSelector()
    return {selectedIndex = 1, fieldTable = FIELDS_CHANNEL, isFocuse = false, focusState = 0}
    --focusState --0: unselected, 1: selected, 2: editing
end

function ISgetSelectedItemId(selector)
    return selector.fieldTable.idArray[selector.selectedIndex]
end

local function startDetectField(selector)
    for i=1, #selector.fieldTable.valueArray, 1 do
        selector.fieldTable.valueArray[i] = getValue(selector.fieldTable.idArray[i])
    end
end


function ISsetFocusState(selector, state)
    selector.focusState = state
    if selector.state == 2 then
        startDetectField(selector)
    end
end

local function detectField(selector)
    for i=1, #selector.fieldTable.valueArray, 1 do
        local v = getValue(selector.fieldTable.idArray[i])
        if math.abs(selector.fieldTable.valueArray[i] - v) > 256 then
            selector.selectedIndex = i
            selector.fieldTable.valueArray[i] = v
            return
        else
            selector.fieldTable.valueArray[i] = v
        end
    end
end

function ISsetSelectedItemById(selector, id)
    for i=1, #selector.fieldTable.idArray, 1 do
        if selector.fieldTable.idArray[i] == id then
            selector.selectedIndex = i
            return
        end
    end
    selector.selectedIndex = 1
end

function ISsetFieldType(selector, type)
    selector.fieldTable = type
end

function ISdoKey(selector, event)
    if event == 35 or event == 67 then
        selector.selectedIndex = selector.selectedIndex + 1
        if selector.selectedIndex > #selector.fieldTable.nameArray then
            selector.selectedIndex = #selector.fieldTable.nameArray
        end
    elseif event == 36 or event == 68 then
        selector.selectedIndex = selector.selectedIndex - 1
        if selector.selectedIndex < 1 then
            selector.selectedIndex = 1
        end
    end
end


function ISdrawSelector(selector, x, y, invers)
    local drawOption = 0
    if selector.focusState == 2 and invers then
        drawOption = drawOption + INVERS
    elseif selector.focusState == 1 then
        drawOption = drawOption + INVERS
    end
    lcd.drawText(x, y, selector.fieldTable.nameArray[selector.selectedIndex], drawOption)
    if selector.focusState == 2 then
        detectField(selector)
    end
end