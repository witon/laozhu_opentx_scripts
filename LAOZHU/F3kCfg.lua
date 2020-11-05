local varSelectorSliderId = 0
local varReadSwitchId = 0
local workTimeSwitchId = 0

local function getVarSelectorSlider()
    return varSelectorSliderId
end
local function setVarSelectorSlider(id)
    varSelectorSliderId = id
end

local function getVarReadSwitch()
    return varReadSwitchId
end

local function setVarReadSwitch(id)
    varReadSwitchId = id
end

local function getWorkTimeSwitch()
    return workTimeSwitchId
end

local function setWorkTimeSwitch(id)
    workTimeSwitchId = id
end

local function getCfgNumberField(iter)
    local str = iter()
    if str == nil then
        return 0
    end
    return tonumber(str)
end

local function getCfgStrField(iter)
    local str = iter()
    if str == nil then
        return ""
    end
    return str
end


local function readFromFile()
    local cfgFilePath = gScriptDir .. "3k.cfg"
    local cfgFile = io.open(cfgFilePath, 'r')
    if cfgFile == nil then
        return
    end

    local content = io.read(cfgFile, 200)
    io.close(cfgFile)
    local iter = string.gmatch(content, '([^\r\n]+)') 
    varSelectorSliderId = getCfgNumberField(iter)
    varReadSwitchId = getCfgNumberField(iter)
    workTimeSwitchId = getCfgNumberField(iter)

end

local function writeToFile()
    local cfgFilePath = gScriptDir .. "3k.cfg"
    local cfgFile = io.open(cfgFilePath, 'w')
    if cfgFile == nil then
        return
    end
    io.write(cfgFile, varSelectorSliderId .. "\r\n")
    io.write(cfgFile, varReadSwitchId .. "\r\n")
    io.write(cfgFile, workTimeSwitchId .. "\r\n")

    io.close(cfgFile)
end

return {readFromFile = readFromFile,
        writeToFile = writeToFile,
        getVarReadSwitch = getVarReadSwitch,
        setVarReadSwitch = setVarReadSwitch,
        getVarSelectorSlider = getVarSelectorSlider,
        setVarSelectorSlider = setVarSelectorSlider,
        getWorkTimeSwitch = getWorkTimeSwitch,
        setWorkTimeSwitch = setWorkTimeSwitch}