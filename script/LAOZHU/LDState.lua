function LDSnewLDState()
    return {startTime = -1,
            startAlt = -1000,
            startLon = 0,
            startLat = 0,
            stopTime = -1,
            stopAlt = -1000,
            stopLon = 0,
            stopLat = 0,
            curTime = -1,
            curAlt = -1,
            curLon = 0,
            curLat = 0
        }
end

function LDSreset(ldState)
    ldState.startTime = -1
    ldState.startAlt = -1000
    ldState.startLon = 0
    ldState.startLat = 0

    ldState.stopTime = -1
    ldState.stopAlt = -1000
    ldState.stopLon = 0
    ldState.stopLat = 0

    ldState.curTime = -1
    ldState.curAlt = -1
    ldState.curLon = 0
    ldState.curLat = 0
end

function LDSisStart(ldState)
    if ldState.startTime < 0 or ldState.stopTime >= 0 then
        return false
    end
    return true
end

function LDSgetDuration(ldState)
    return (ldState.stopTime - ldState.startTime)
end

function LDSgetCurDuration(ldState)
    if not LDSisStart(ldState) then
        return 0
    end
    return ldState.curTime - ldState.startTime
end

function LDSgetCurSinkAlt(ldState)
    if not LDSisStart(ldState) then
        return 0
    end
    return ldState.startAlt - ldState.curAlt
end

function LDSgetCurSinkRate(ldState)
    local dur = ldState.curTime - ldState.startTime
    if dur == 0 then
        return 0
    end
    local sinkAlt = ldState.startAlt - ldState.curAlt
    return sinkAlt / dur
end

function LDSgetCurLD(ldState)
    if ldState.startLon == 0 and ldState.startLat == 0 then
        return 0
    end
    local distance = LDSdistance(ldState.startLon, ldState.startLat, ldState.curLon, ldState.curLat)
    if(distance == 0) then
        return 0
    end
    local sink = ldState.startAlt - ldState.curAlt
    if(sink == 0) then
        return 0
    end
    return distance / sink
end

function LDSgetCurDistance(ldState)
    if ldState.startLon == 0 and ldState.startLat == 0 then
        return 0
    end
    return LDSdistance(ldState.startLon, ldState.startLat, ldState.curLon, ldState.curLat)
end

function LDSgetCurSpeed(ldState)
    local dur = ldState.curTime - ldState.startTime
    if dur == 0 then
        return 0
    end
    local distance = LDSdistance(ldState.startLon, ldState.startLat, ldState.curLon, ldState.curLat)
    return distance / dur
end


function LDSgetSinkAlt(ldState)
    return ldState.startAlt - ldState.stopAlt
end

function LDSsetOnStateChange(ldState, onStateChange)
    ldState.onStateChange = onStateChange
end

function LDSgetSpeed(ldState)
    local distance = LDSgetDistance(ldState)
    if(distance == 0) then
        return 0
    end
    local dur = ldState.stopTime - ldState.startTime
    if dur == 0 then
        return 0
    end
    return distance / dur
end

function LDSgetLD(ldState)
    local distance = LDSgetDistance(ldState)
    if(distance == 0) then
        return 0
    end
    local sink = LDSgetSinkAlt(ldState)
    return sink / distance
end

function LDSgetDistance(ldState)
    return LDSdistance(ldState.startLon, ldState.startLat, ldState.stopLon, ldState.stopLat)
end

function LDSgetSinkRate(ldState)
    local dur = ldState.stopTime - ldState.startTime
    if dur == 0 then
        return 0
    end
    local sinkAlt = ldState.startAlt - ldState.stopAlt
    return sinkAlt / dur
end


function LDSrun(ldState, time, alt, lon, lat, testSwitchValue)
    ldState.curTime = time
    ldState.curAlt = alt
    ldState.curLon = lon
    ldState.curLat = lat
    if LDSisStart(ldState) then
        if testSwitchValue < 100 then
            ldState.stopTime = time
            ldState.stopAlt = alt
            ldState.stopLon = lon
            ldState.stopLat = lat
            if ldState.onStateChange then
                ldState.onStateChange(ldState, false)
            end
        end
    else
        if testSwitchValue > 100 then
            ldState.startTime = time
            ldState.startAlt = alt
            ldState.startLon = lon
            ldState.startLat = lat
            if ldState.onStateChange then
                ldState.onStateChange(ldState, true)
            end
        end
    end
end

function LDSdistance(lon1, lat1, lon2, lat2)
    local R = 6371000  -- 地球半径，单位米
    local rad = math.pi / 180
    local dLat = (lat2 - lat1) * rad
    local dLon = (lon2 - lon1) * rad
    local a = math.sin(dLat/2) * math.sin(dLat/2) +
              math.cos(lat1 * rad) * math.cos(lat2 * rad) *
              math.sin(dLon/2) * math.sin(dLon/2)
    local c = 2 * math.atan2(math.sqrt(a), math.sqrt(1-a))
    local d = R * c
    return d
end

function LDSunload()
    LDSnewLDState = nil
    LDSreset = nil
    LDSisStart = nil
    LDSsetOnStateChange = nil

    LDSgetCurDuration = nil
    LDSgetCurSinkAlt = nil
    LDSgetCurSinkRate = nil
    LDSgetCurLD = nil
    LDSgetCurDistance = nil
    LDSgetCurSpeed = nil

    LDSgetDuration = nil
    LDSgetSinkAlt = nil
    LDSgetSpeed = nil
    LDSgetLD = nil
    LDSgetDistance = nil
    LDSgetSinkRate = nil

    LDSrun = nil
    LDSdistance = nil
    LDSunload = nil
end