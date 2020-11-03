FIELDS_CHANNEL = {
    nameArray = {
        "ch1",
        "ch2",
        "ch3",
        "ch4",
        "ch5",
        "ch6",
        "ch7",
        "ch8",
        "ch9",
        "ch10",
        "ch11",
        "ch12",
        "ch13",
        "ch14",
        "ch15",
        "ch16"
    },
    idArray = {
        1,
        2,
        3,
        4,
        5,
        6,
        7,
        8,
        9,
        10,
        11,
        12,
        13,
        14,
        15,
        16
    }
}

FIELDS_SWITCH = {
    nameArray = {
        "sa",
        "sb",
        "sc",
        "sd",
        "se",
        "sf",
        "sg",
        "sh"
    },
    idArray = {
        1,
        2,
        3,
        4,
        5,
        6,
        7,
        8
    }

}

FIELDS_INPUT = {
    nameArray = {
        "ail",
        "ele",
        "rud",
        "thr",
        "s1",
        "s2",
        "s3",
        "ls",
        "rs"
    },
    idArray = {
        1,
        2,
        3,
        4,
        5,
        6,
        7,
        8,
        9
    }
}

local selectedIndex = 1
local fieldTable = FIELDS_CHANNEL
local isFocuse = false
local focusState = 0    --0: unselected, 1: selected, 2: editing

local function setFocusState(state)
    focusState = state
end

local function filterTable(fieldTable)
    local newTable = {nameArray = {}, idArray = {}}
    for i=#fieldTable.nameArray, 1, -1 do
        local fieldInfo = getFieldInfo(fieldTable.nameArray[i])
        if fieldInfo then
            fieldTable.idArray[i] = fieldInfo.id
            newTable.idArray[#newTable.idArray+1] = fieldInfo.id 
            newTable.nameArray[#newTable.nameArray+1] = fieldInfo.name
        end
    end
    return newTable
end

function initFieldsInfo()
    FIELDS_CHANNEL = filterTable(FIELDS_CHANNEL)
    FIELDS_INPUT = filterTable(FIELDS_INPUT)
    FIELDS_SWITCH = filterTable(FIELDS_SWITCH)
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
end

return {drawSelector = drawSelector, initFieldsInfo = initFieldsInfo, setFieldType = setFieldType, setFocusState = setFocusState, doKey=doKey}