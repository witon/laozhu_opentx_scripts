-- 清空表
function LZ_clearTable(t)
    if type(t) == "table" then
        for i, v in pairs(t) do
            if type(v) == "table" then
                LZ_clearTable(v)
            end
            t[i] = nil
        end
    end
    return t
end

-- 分割字符串  
function splitStr(inputstr, sep)
    if sep == nil then
        sep = "%s"
    end
    local t = {}
    for str in string.gmatch(inputstr, "([^" .. sep .. "]+)") do
        table.insert(t, str)
    end
    return t
end
