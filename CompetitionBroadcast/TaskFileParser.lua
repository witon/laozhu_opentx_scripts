
local function parse(fileName)
    local tasks = {}
    local taskFile = io.open(fileName, 'r')
    if taskFile == nil then
        return nil
    end
    local content = taskFile:read(2000)
    io.close(taskFile)
    for line in string.gmatch(content, '([^\r\n]+)') do
        local fields = splitStr(line, "|")
        local task = {}
        task.id = fields[2]
        task.p1 = fields[3]
        task.p2 = fields[4]
        local round = tonumber(fields[1]) 
        tasks[round] = task
    end
    return tasks
end

return {parse=parse}