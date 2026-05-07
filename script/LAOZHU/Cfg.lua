
function CFGgetNumberField(cfg, fieldName, default)
    local v = cfg[fieldName]
    if v == nil and default then
        return default
    end
    if v == nil then
        v = 0
    end
    return v
end

function CFGgetStrField(cfg, fieldName, default)
    local v = cfg[fieldName]
    if v == nil and default then
        return default
    end
    if v == nil then
        return ""
    end
    return v
end

function CFGreadFromFile(cfg, fileName)
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
                cfg[k] = v
            else
                cfg[k] = tonumber(v)
            end
        end
    end
    return true
end

function CFGwriteToFile(cfg, fileName)
    local cfgFilePath = gScriptDir .. fileName
    local cfgFile = io.open(cfgFilePath, 'w')
    if cfgFile == nil then
        return
    end
    for k, v in pairs(cfg) do
        if type(v) == "string" then
           io.write(cfgFile, k, '=', v, ':s\r\n')
        else
           io.write(cfgFile, k, '=',  v, ':n\r\n')
        end
    end
    io.close(cfgFile)
end

function CFGnewCfg()
    return {}
end

function CFGunload()
    CFGgetNumberField = nil
    CFGgetStrField = nil
    CFGreadFromFile = nil
    CFGwriteToFile = nil
    CFGnewCfg = nil
    CFGunload = nil
end