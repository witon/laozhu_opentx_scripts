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
end

function FieldsUnload()
    FIELDS_CHANNEL = nil
    FIELDS_INPUT = nil
    FIELDS_SWITCH = nil
    filterTable = nil
    initFieldsInfo = nil
    FieldsUnload = nil
end

