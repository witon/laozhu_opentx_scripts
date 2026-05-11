--[[
  SCRIPTS/keymap.cfg 存在且可读时，映射表仅由该文件构建（键名 = 目标映射 event 整数字符串，值 = 硬件 raw :n），不执行下方内置电台/固件适配。
  无法打开该文件时，使用 getVersion() 对应的内置适配分支。
  调用 KMgetKeyMap 前须已由 framework 等加载 LAOZHU/CfgO.lua（提供 CFGC）。
  下列为脚本内使用的「目标映射值」中文含义（与 keymap.cfg 键一致；说明用）：
  36 — 上（ViewMatrix 行上移、列表向上等）
  35 — 下
  38 — 左（列左移）
  37 — 右（列右移）
  EVT_EXIT_BREAK（数值因固件而异，常见如 33）— 返回/退出（框架退出、关闭编辑等）
  68 — 长按上（NumEdit/Selector/TextEdit 等与「上」等价的长按分支；F3K/F5J 遥测进设置页等原「长按更多」亦用此值）
  67 — 长按下
  70 — 长按左
  69 — 长按右
  EVT_ENTER_BREAK（及常见映射 34）— 确定/进入编辑；由固件语义处理，一般不写入 keymap.cfg
]]

--    按  松  连按连续触发    触发一次
-- xlite				
-- Flysky PA01：独立分支，见下方 pa01
-- 左  102	38	70	134
-- 右	101	37	69	132
-- 上	100	36	68	132
-- 下	99	35	67	131


function KMmergeKeyMapFromKvs(keyMap, kvs)
	if keyMap == nil or kvs == nil then
		return
	end
	for ks, v in pairs(kvs) do
		local canon = tonumber(ks)
		if canon ~= nil and type(v) == "number" then
			keyMap[v] = canon
		end
	end
end

function KMgetKeyMap()
    local cfg = CFGC:new()
    if cfg:readFromFile("keymap.cfg") then
        local keyMap = {}
        KMmergeKeyMapFromKvs(keyMap, cfg.kvs)
        return keyMap
    end
    local ver, radio = getVersion();
    print("ver: " .. ver .. " radio: " .. radio)
    local keyMap = {};
    if string.sub(radio, 1, 5) == "zorro" then
        if string.sub(ver, 1, 4) == "2.11" or string.sub(ver, 1, 4) == "2.12" then
            keyMap[4099] = 38 --滚轮向左 --左
            keyMap[4100] = 37 --滚轮向右 --右
            keyMap[35] = 38 --page< 左
            keyMap[36] = 37 --page> 右
            --keyMap[67] =  --长按page< 左
            --keyMap[68] =  --page> 右
            keyMap[43] = 36 --MDL 上
            keyMap[44] = 35 --TEL 下
            keyMap[76] = 67 --长按下
            keyMap[75] = 68 --长按上
            keyMap[34] = 34 --return
            keyMap[33] = 33 --exit
 
        elseif string.sub(ver, 1, 4) == "2.10" then
            keyMap[4099] = 38 --滚轮向左 --左
            keyMap[4100] = 37 --滚轮向右 --右
            keyMap[100] = 38 --page< 左
            keyMap[101] = 37 --page> 右
            keyMap[44] = 36 --MDL 上
            keyMap[45] = 35 --TEL 下
            keyMap[77] = 67 --长按下
            keyMap[76] = 68 --长按上
            keyMap[34] = 34 --return
            keyMap[33] = 33 --exit
        else
            keyMap[4099] = 38
            keyMap[4100] = 37
            keyMap[37] = 36
            keyMap[38] = 35
            keyMap[70] = 67
            keyMap[69] = 68
            keyMap[34] = 34 --return
            keyMap[33] = 33 --exit
        end
    elseif string.sub(radio, 1, 4) == "pa01" then
        if string.sub(ver, 1, 4) == "2.11" or string.sub(ver, 1, 4) == "2.12" then
            keyMap[4099] = 36 --滚轮向上 --上
            keyMap[4100] = 35 --滚轮向下 --下
            keyMap[515] = 38 --page< 左
            keyMap[516] = 37 --page> 右
            --keyMap[67] =  --长按page< 左
            --keyMap[68] =  --page> 右
            keyMap[525] = 36 --MDL 上
            --keyMap[513] = 35 --TEL 下
            --keyMap[76] = 67 --长按下
            keyMap[1035] = 68 --长按上
            --keyMap[514] = 34 --return
            --keyMap[513] = 33 --exit
        end
    elseif string.sub(radio, 1, 4) == "gx12" then
        keyMap[4099] = 38
        keyMap[4100] = 37
        keyMap[44] = 38
        keyMap[43] = 37
        keyMap[100] = 36
        keyMap[99] = 35
        keyMap[75] = 68 --长按上
        keyMap[34] = 34 --return
        keyMap[33] = 33 --exit
    else
        keyMap[38] = 38
        keyMap[37] = 37
        keyMap[36] = 36
        keyMap[35] = 35
        keyMap[34] = 34 --return
        keyMap[33] = 33 --exit
    end
    return keyMap;
end

function KMunload()
    KMgetKeyMap = nill
    KMmergeKeyMapFromKvs = nill
    KMunload = nill
end
