--[[
  SCRIPTS/keymap.cfg 存在且可读时，映射表仅由该文件构建：
  键名 = 硬件 rawEvent（整数字符串），值 = 目标映射 event（:n）。即 keyMap[raw] = target；多颗键可映到同一 target。
  无法打开该文件时，使用 getVersion() 对应的内置电台/固件适配。
  调用 KMgetKeyMap 前须已由 framework 等加载 LAOZHU/CfgO.lua（提供 CFGC）。
  常用目标 event 含义（说明用；写入 cfg 的是数值）：
  36 — 上（ViewMatrix 行上移、列表向上等）
  35 — 下
  38 — 左（列左移）
  37 — 右（列右移）
  EVT_EXIT_BREAK（数值因固件而异，常见如 33）— 返回/退出
  68 — 长按上（NumEdit/Selector/TextEdit 等与「上」等价的长按分支；F3K/F5J 遥测进设置页等）
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
		local raw = tonumber(ks)
		if raw ~= nil and type(v) == "number" then
			keyMap[raw] = v
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
            keyMap[4099] = 38 --左
            keyMap[4100] = 37 --右
            keyMap[35] = 38 --左
            keyMap[36] = 37 --右
            keyMap[43] = 36 --上
            keyMap[44] = 35 --下
            keyMap[76] = 67 --长按下
            keyMap[75] = 68 --长按上
            keyMap[34] = 34 --return
            keyMap[33] = 33 --exit
 
        elseif string.sub(ver, 1, 4) == "2.10" then
            keyMap[4099] = 38 --左
            keyMap[4100] = 37 --右
            keyMap[100] = 38 --左
            keyMap[101] = 37 --右
            keyMap[44] = 36 --上
            keyMap[45] = 35 --下
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
            keyMap[4099] = 36 --上
            keyMap[4100] = 35 --下
            keyMap[515] = 38 --左
            keyMap[516] = 37 --右
            keyMap[1027] = 69 --长按 左
            keyMap[1028] = 70 --长按 右
            keyMap[1035] = 68 --长按上
            keyMap[514] = 34 --return
            keyMap[513] = 33 --exit
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
