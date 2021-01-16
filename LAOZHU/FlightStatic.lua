
local maxAlt = 0
local minRssi = 100
local minRxVol = 10

local function update(rxVol, rssi, alt)
    if maxAlt < alt then
        maxAlt = alt
    end
    if minRssi > rssi then
        minRssi = rssi
    end
    if minRxVol > rxVol then
        minRxVol = rxVol
    end
end

local function reset()
    maxAlt = 0
    minRssi = 100
    minRxVol = 10
end

local function getMaxAlt()
    return maxAlt
end

local function getMinRssi()
    return minRssi
end

local function getMinRxVol()
    return minRxVol
end

return {update = update,
        reset = reset,
        getMaxAlt = getMaxAlt,
        getMinRssi = getMinRssi,
        getMinRxVol = getMinRxVol
}