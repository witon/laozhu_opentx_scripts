
local flightArray = {}
local flightIndex = 0


local function addFlight(flightTime, launchAlt, flightStartTime)
	flightIndex = flightIndex + 1
	if flightIndex > 25 then
		flightIndex = 1
    end
    local flightRecord = {}
    flightRecord.flightTime = flightTime
    flightRecord.launchAlt = launchAlt
    flightRecord.flightStartTime = flightStartTime
    flightArray[flightIndex] = flightRecord
end 

local function getFlightArray()
    return flightArray
end


return {addFlight = addFlight, getFlightArray = getFlightArray}