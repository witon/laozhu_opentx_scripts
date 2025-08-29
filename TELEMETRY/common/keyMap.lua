--    按  松  连按连续触发    触发一次
-- xlite				
-- 左  102	38	70	134
-- 右	101	37	69	133
-- 上	100	36	68	132
-- 下	99	35	67	131



	
function KMgetKeyMap()
    local ver, radio = getVersion();
    --print("ver: " .. ver .. " radio: " .. radio)
    local keyMap = {};
    if string.sub(radio, 1, 5) == "zorro"  then
        if string.sub(ver, 1, 4) == "2.11" then
            keyMap[4099] = 38 --滚轮向左 --左
            keyMap[4100] = 37 --滚轮向右 --右
            keyMap[35] = 38 --page< 左
            keyMap[36] = 37 --page> 右
            --keyMap[67] =  --长按page< 左
            --keyMap[68] =  --page> 右
            keyMap[43] = 36 --MDL 上
            keyMap[44] = 35 --TEL 下
            keyMap[76] = 67 --长按TEL
            keyMap[75] = 133 --长按MDL
 
        elseif string.sub(ver, 1, 4) == "2.10" then
            keyMap[4099] = 38 --滚轮向左 --左
            keyMap[4100] = 37 --滚轮向右 --右
            keyMap[100] = 38 --page< 左
            keyMap[101] = 37 --page> 右
            keyMap[44] = 36 --MDL 上
            keyMap[45] = 35 --TEL 下
            keyMap[77] = 67 --长按TEL
            keyMap[76] = 133 --长按MDL
        else
            keyMap[4099] = 38
            keyMap[4100] = 37
            keyMap[37] = 36
            keyMap[38] = 35
            keyMap[70] = 67
            keyMap[69] = 68
        end
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
