
local function parse(fileName)
    local rounds = {}
    local groupsFile = io.open(fileName, 'r')
    if groupsFile == nil then
        return nil
    end
    local content = groupsFile:read(2000)
    io.close(groupsFile)
    for line in string.gmatch(content, '([^\r\n]+)') do
        local fields = splitStr(line, "|")
        local fields1 = splitStr(fields[1], ".")
        local round = tonumber(fields1[1])
        local group = tonumber(fields1[2])
        if not rounds[round] then
            rounds[round] = {}
        end
        rounds[round][group] = {}
        for i=2, #fields, 1 do
            rounds[round][group][i-1] = fields[i]
        end
    end
    return rounds
end

return {parse=parse}