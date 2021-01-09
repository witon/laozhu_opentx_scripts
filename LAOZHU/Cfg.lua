local cfgs = {}

local function getCfgs()
    return cfgs
end

local function getNumberField(fieldName, default)
    local v = cfgs[fieldName]
    if v == nil and default then
        return default
    end
    if v == nil then
        v = 0
    end
    return v
end

local function getStrField(fieldName)
    local v = cfgs[fieldName]
    if v == nil then
        return ""
    end
    return v
end


local function readFromFile(fileName)
    local cfgFilePath = gScriptDir .. fileName
    local cfgFile = io.open(cfgFilePath, 'r')
    if cfgFile == nil then
        return false
    end

    local content = io.read(cfgFile, 200)
    io.close(cfgFile)

    for line in string.gmatch(content, '([^\r\n]+)') do
        local k, v, t = string.match(line, '([^=]+)=(.+):(.)')
        if k and v and t then
            if t == 's' then
                cfgs[k] = v
            else
                cfgs[k] = tonumber(v)
            end
        end
    end
    return true
end

local function writeToFile(fileName)
    local cfgFilePath = gScriptDir .. fileName
    local cfgFile = io.open(cfgFilePath, 'w')
    if cfgFile == nil then
        return
    end
    for k, v in pairs(cfgs) do
        if type(v) == "string" then
           io.write(cfgFile, k, '=', v, ':s\r\n')
        else
           io.write(cfgFile, k, '=',  v, ':n\r\n')
        end
    end
    io.close(cfgFile)
end

return {readFromFile = readFromFile,
        writeToFile = writeToFile,
        getCfgs = getCfgs,
        getNumberField = getNumberField,
        getStrField = getStrField
    }