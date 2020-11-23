local curVar = -1
local curReadSwitchState = 0
local varMap = nil
local lastReadTime = 0

local function setVarMap(map)
    varMap = map
end

local function getSelectedVar(varSelect)
    local v = 1
    if varSelect < -750 then
        v = 1
    elseif varSelect >= -750 and varSelect < 0 then
        v = 2
    elseif varSelect >= 0 and varSelect < 750 then
        v = 3
    elseif varSelect >= 750 then
        v = 4
    end
    return v
end

local function readVar(time)
    if time - lastReadTime < 10 then
        return
    end
    lastReadTime = time
    local fun = varMap[curVar]
    local value, unit = fun()
    playNumber(value, unit)
end

local function doReadVar(varSelect, readSwitch, time)
    local v = getSelectedVar(varSelect)
    if curVar == -1 then
        curVar = v
    elseif curVar ~= v then
        curVar = v
        readVar(time)
        return
    end

    if readSwitch ~= curReadSwitchState then
        if readSwitch < 0 then
            readVar(time)
        end
        curReadSwitchState = readSwitch
    end
end

return {
    doReadVar = doReadVar,
    setVarMap = setVarMap
}
