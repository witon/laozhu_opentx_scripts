local function parse(args)
    local tasksFilePath = ""
    local gropusFilePath = ""
    local pilotsNameVoiceDir = ""
    local isReadPilotName = false
    local isSingleGroup = false
    local isTestRun = false
    for i, arg in pairs(args) do
        local fields = splitStr(arg, "=")
        if fields[1] == "tasksfile" then
            tasksFilePath = fields[2]
        elseif fields[1] == "groupsfile" then
            gropusFilePath = fields[2]
        elseif fields[1] == "groupnumber" then
            groupNum = fields[2]
        elseif arg == "singlegroup" then
            isSingleGroup = true
        elseif arg=="readname" then
            isReadPilotName = true
        elseif arg=="test" then
            isTestRun = true
        end
    end
    if tasksFilePath == "" then
        return false
    end
    if gropusFilePath == "" then
        return false
    end
    return true, tasksFilePath, gropusFilePath, isSingleGroup, isReadPilotName, isTestRun
end

local function printHelp(args)
    print("usage: \r\nlua " .. args[0] .. " tasksfile=<tasks file path> groupsfile=<groups file path> <singlegroup> <readname>")
end

return {parse=parse, printHelp=printHelp}