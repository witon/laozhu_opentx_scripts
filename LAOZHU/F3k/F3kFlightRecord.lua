
function F3KFRaddFlight(fr, flightTime, launchAlt, flightStartTime)
	fr.flightIndex = fr.flightIndex + 1
    local flightRecord = {}
    flightRecord.flightTime = flightTime
    flightRecord.launchAlt = launchAlt
    flightRecord.flightStartTime = flightStartTime
    flightRecord.index = fr.flightIndex
    if #fr.flightArray >= fr.maxNum then
        for i=1, #fr.flightArray-1, 1 do
            fr.flightArray[i] = fr.flightArray[i+1]
        end
        fr.flightArray[fr.maxNum] = nil
    end
    fr.flightArray[#fr.flightArray+1] = flightRecord
end 

function F3KFRgetFlightArray(fr)
    return fr.flightArray
end

function F3KFRnewFlightRecord()
    local fr = {}
    fr.flightArray = {}
    fr.flightIndex = 0
    fr.maxNum = 10
    return fr
end

function F3KFRunload()
    F3KFRaddFlight = nil
    F3KFRgetFlightArray = nil
    F3KFRnewFlightRecord = nil
    F3KFRunload = nil
end