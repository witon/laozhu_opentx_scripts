local varSelectorSliderId = 0
local varSelectorSliderName = nil
local varReadSwitchId = 0
local varReadSwitchName = nil
local workTimeSwitchId = 0
local workTimeSwitchName = 0

local function getVarSelectorSlider()
    return varSelectorSliderId, varSelectorSliderName
end
local function setVarSelectorSlider(id, name)
    varSelectorSliderId = id
    varSelectorSliderName = name 
end

local function getVarReadSwitch()
    return varReadSwitchId, varReadSwitchName
end

local function setVarReadSwitch(id, name)
    varReadSwitchId = id
    varReadSwitchName = name
end

local function getWorkTimeSwitch()
    return workTimeSwitchId, workTimeSwitchName 
end

local function setWorkTimeSwitch(id, name)
    workTimeSwitchId = id
    workTimeSwitchName = name
end


local function readFromFile()
end

local function writeToFile()
end

return {readFromFile = readFromFile,
        writeToFile = writeToFile,
        getVarReadSwitch = getVarReadSwitch,
        setVarReadSwitch = setVarReadSwitch,
        getVarSelectorSlider = getVarSelectorSlider,
        setVarSelectorSlider = setVarSelectorSlider,
        getWorkTimeSwitch = getWorkTimeSwitch,
        setWorkTimeSwitch = setWorkTimeSwitch}