CFGC = {kvs={}}


function CFGC:getNumberField(fieldName, default)
    local v = self.kvs[fieldName]
    if v == nil and default then
        return default
    end
    if v == nil then
        v = 0
    end
    return v
end

function CFGC:getStrField(fieldName, default)
    local v = self.kvs[fieldName]
    if v == nil and default then
        return default
    end
    if v == nil then
        return ""
    end
    return v
end


function CFGC:readFromFile(fileName)
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
                self.kvs[k] = v
            else
                self.kvs[k] = tonumber(v)
            end
        end
    end
    return true
end

function CFGC:writeToFile(fileName)
    local cfgFilePath = gScriptDir .. fileName
    local cfgFile = io.open(cfgFilePath, 'w')
    if cfgFile == nil then
        return
    end
    for k, v in pairs(self.kvs) do
        if type(v) == "string" then
           io.write(cfgFile, k, '=', v, ':s\r\n')
        else
           io.write(cfgFile, k, '=',  v, ':n\r\n')
        end
    end
    io.close(cfgFile)
end

function CFGC:new()
    local o = {}
    setmetatable(o, self)
    self.__index = self
    return o
end