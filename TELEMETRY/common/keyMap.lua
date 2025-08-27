
function KMgetKeyMap()
    local ver, radio = getVersion();
    --print("ver: " .. ver .. " radio: " .. radio)
    local keyMap = {};
    if string.sub(radio, 1, 5) == "zorro"  then
        -- before after
        keyMap[4099] = 38
        keyMap[4100] = 37
        keyMap[37] = 36
        keyMap[38] = 35
        keyMap[70] = 67
        keyMap[69] = 68
        keyMap[75] = 133 --长按MDL
    elseif string.sub(radio, 1, 4) == "gx12" then
        keyMap[4099] = 38
        keyMap[4100] = 37
        keyMap[44] = 38
        keyMap[43] = 37
        keyMap[100] = 36
        keyMap[99] = 35
        keyMap[75] = 133 --长按MDL
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
