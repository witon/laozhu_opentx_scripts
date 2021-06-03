local function parse(args)
    local tasksFilePath = ""
    local gropusFilePath = ""
    local pilotsNameVoiceDir = ""
    local isReadPilotName = false
    local isSingleGroup = false
    local isTestRun = false
    local isEmulate = false
    for i, arg in pairs(args) do
        local fields = splitStr(arg, "=")
        if fields[1] == "t" then
            tasksFilePath = fields[2]
        elseif fields[1] == "g" then
            gropusFilePath = fields[2]
        elseif arg == "singlegroup" then
            isSingleGroup = true
        elseif arg=="readname" then
            isReadPilotName = true
        elseif arg=="test" then
            isTestRun = true
        elseif arg=="emulate" then
            isEmulate = true
        end
    end
    if tasksFilePath == "" then
        return false
    end
    if gropusFilePath == "" then
        return false
    end
    return true, tasksFilePath, gropusFilePath, isSingleGroup, isReadPilotName, isTestRun, isEmulate
end

local function printHelp(args)
    print("usage: \r\nlua " .. args[0] .. " t=<tasks file path> g=<groups file path> <singlegroup> <readname> <test> <emulate>")
end

return {parse=parse, printHelp=printHelp}