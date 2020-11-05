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

local function filterTable(fieldTable)
    local newTable = {nameArray = {}, idArray = {}, valueArray = {}}
    for i=#fieldTable.nameArray, 1, -1 do
        local fieldInfo = getFieldInfo(fieldTable.nameArray[i])
        if fieldInfo then
            fieldTable.idArray[i] = fieldInfo.id
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

