
function KMgetKeyMap()
    local ver, radio = getVersion();
    local keyMap = {};
    if string.sub(radio, 1, 5) == "zorro" then
        -- before after
        keyMap[4099] = 38
        keyMap[4100] = 37
        keyMap[37] = 36
        keyMap[38] = 35
        keyMap[70] = 67
        keyMap[69] = 68
    else
        keyMap[38] = 38
        keyMap[37] = 37
        keyMap[36] = 36
        keyMap[35] = 35
    end
    return keyMap;
end

function KMunload()
    KMgetKeyMap = nill
    KMunload = nill
end
