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
    }
}

FIELDS_SWITCH_POSITION = {
    nameArray = {
        "sa"..CHAR_UP, "sa-", "sa"..CHAR_DOWN,
        "sb"..CHAR_UP, "sb-", "sb"..CHAR_DOWN,
        "sc"..CHAR_UP, "sc-", "sc"..CHAR_DOWN,
        "sd"..CHAR_UP, "sd-", "sd"..CHAR_DOWN,
        "se"..CHAR_UP, "se-", "se"..CHAR_DOWN,
        "sf"..CHAR_UP, "sf-", "sf"..CHAR_DOWN,
        "sg"..CHAR_UP, "sg-", "sg-", "sg"..CHAR_DOWN,
        "sh"..CHAR_UP, "sh-", "sh"..CHAR_DOWN
    }
}

local function filterSwitchPosition(switchPositionTable)
    local newTable = {nameArray = {}, indexArray = {}, valueArray = {}}
    newTable.nameArray[1] = "-"
    newTable.indexArray[1] = 0
    newTable.valueArray[1] = false
    for i=#switchPositionTable.nameArray, 1, -1 do
        local switchIndex = getSwitchIndex(switchPositionTable.nameArray[i])
        local v = getSwitchValue(switchIndex)
        if switchIndex and v ~= nil then
            newTable.indexArray[#newTable.indexArray+1] = switchIndex
            newTable.nameArray[#newTable.nameArray+1] = switchPositionTable.nameArray[i]
            newTable.valueArray[#newTable.valueArray+1] = v
        end
    end
    return newTable
end


local function filterTable(fieldTable)
    local newTable = {nameArray = {}, idArray = {}, valueArray = {}}
    newTable.nameArray[1] = "-"
    newTable.idArray[1] = 0
    newTable.valueArray[1] = 0
    for i=#fieldTable.nameArray, 1, -1 do
        local fieldInfo = getFieldInfo(fieldTable.nameArray[i])
        if fieldInfo then
            newTable.idArray[#newTable.idArray+1] = fieldInfo.id 
            newTable.nameArray[#newTable.nameArray+1] = fieldInfo.name
            newTable.valueArray[#newTable.valueArray+1] = 0
        end
    end
    return newTable
end


function initFieldsInfo()
    FIELDS_CHANNEL = filterTable(FIELDS_CHANNEL)
    FIELDS_INPUT = filterTable(FIELDS_INPUT)
    FIELDS_SWITCH = filterTable(FIELDS_SWITCH)
    FIELDS_SWITCH_POSITION = filterSwitchPosition(FIELDS_SWITCH_POSITION)
end

function FieldsUnload()
    FIELDS_CHANNEL = nil
    FIELDS_INPUT = nil
    FIELDS_SWITCH = nil
    FIELDS_SWITCH_POSITION = nil
    filterTable = nil
    initFieldsInfo = nil
    FieldsUnload = nil
end

