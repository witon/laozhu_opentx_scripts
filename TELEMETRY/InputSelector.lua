
local selectedIndex = 1
local fieldTable = FIELDS_CHANNEL
local isFocuse = false
local focusState = 0    --0: unselected, 1: selected, 2: editing

local function getSelectedItemId()
    return fieldTable.idArray[selectedIndex]
end

local function startDetectField()
    for i=1, #fieldTable.valueArray, 1 do
        fieldTable.valueArray[i] = getValue(fieldTable.idArray[i])
    end
end


local function setFocusState(state)
    focusState = state
    if state == 2 then
        startDetectField()
    end
end

local function detectField()
    for i=1, #fieldTable.valueArray, 1 do
        local v = getValue(fieldTable.idArray[i])
        if math.abs(fieldTable.valueArray[i] - v) > 256 then
            selectedIndex = i
            fieldTable.valueArray[i] = v
            return
        else
            fieldTable.valueArray[i] = v
        end
    end
end

local function setSelectedItemById(id)
    for i=1, #fieldTable.idArray, 1 do
        if fieldTable.idArray[i] == id then
            selectedIndex = i
            return
        end
    end
    selectedIndex = 1
end

local function setFieldType(type)
    fieldTable = type
end

local function doKey(event)
    if event == 35 or event == 67 then
        selectedIndex = selectedIndex + 1
        if selectedIndex > #fieldTable.nameArray then
            selectedIndex = #fieldTable.nameArray
        end
    elseif event == 36 or event == 68 then
        selectedIndex = selectedIndex - 1
        if selectedIndex < 1 then
            selectedIndex = 1
        end
    end
end


local function drawSelector(x, y, invers)
    local drawOption = 0
    if focusState == 2 and invers then
        drawOption = drawOption + INVERS
    elseif focusState == 1 then
        drawOption = drawOption + INVERS
    end
    lcd.drawText(x, y, fieldTable.nameArray[selectedIndex], drawOption)
    if focusState == 2 then
        detectField()
    end
end

return {drawSelector = drawSelector,
        setFieldType = setFieldType,
        setFocusState = setFocusState,
        doKey=doKey,
        setSelectedItemById=setSelectedItemById,
        getSelectedItemId=getSelectedItemId}