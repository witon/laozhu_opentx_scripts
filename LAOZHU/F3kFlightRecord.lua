
local flightArray = {}
local flightIndex = 0


local function addFlight(flightTime, launchAlt, flightStartTime)
	flightIndex = flightIndex + 1
    local flightRecord = {}
    flightRecord.flightTime = flightTime
    flightRecord.launchAlt = launchAlt
    flightRecord.flightStartTime = flightStartTime
    flightRecord.index = flightIndex
    if #flightArray > 24 then
        for i=1, #flightArray-1, 1 do
            flightArray[i] = flightArray[i+1]
        end
        flightArray[25] = nil
    end
    flightArray[#flightArray+1] = flightRecord
end 

local function getFlightArray()
    return flightArray
end


return {addFlight = addFlight, getFlightArray = getFlightArray}