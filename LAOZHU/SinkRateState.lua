function SRSnewSinkRateState()
    return {startTime = -1,
            startAlt = -1000,
            stopTime = -1,
            stopAlt = -1000,
        }
end

function SRSreset(sinkRateState)
    sinkRateState.startTime = -1
    sinkRateState.startAlt = -1000
    sinkRateState.stopTime = -1
    sinkRateState.stopAlt = -1000
end

function SRSisStart(sinkRateState)
    if sinkRateState.startTime < 0 or sinkRateState.stopTime >= 0 then
        return false
    end
    return true
end

function SRSgetDuration(sinkRateState)
    return (sinkRateState.stopTime - sinkRateState.startTime)
end

function SRSgetCurDuration(sinkRateState, time)
    if not SRSisStart(sinkRateState) then
        return 0
    end
    return time - sinkRateState.startTime
end

function SRSgetCurSinkAlt(sinkRateState, alt)
    if not SRSisStart(sinkRateState) then
        return 0
    end
    return sinkRateState.startAlt - alt
end

function SRSgetCurSinkRate(sinkRateState, time, alt)
    local dur = time - sinkRateState.startTime
    if dur == 0 then
        return 0
    end
    local sinkAlt = sinkRateState.startAlt - alt
    return sinkAlt / dur
end


function SRSgetSinkAlt(sinkRateState)
    return sinkRateState.startAlt - sinkRateState.stopAlt
end

function SRSsetOnStateChange(sinkRateState, onStateChange)
    sinkRateState.onStateChange = onStateChange
end


function SRSgetSinkRate(sinkRateState)
    local dur = sinkRateState.stopTime - sinkRateState.startTime
    if dur == 0 then
        return 0
    end
    local sinkAlt = sinkRateState.startAlt - sinkRateState.stopAlt
    return sinkAlt / dur
end


function SRSrun(sinkRateState, time, alt, testSwitchValue)
    if SRSisStart(sinkRateState) then
        if testSwitchValue < 100 then
            sinkRateState.stopTime = time
            sinkRateState.stopAlt = alt
            if sinkRateState.onStateChange then
                sinkRateState.onStateChange(sinkRateState, false)
            end
        end
    else
        if testSwitchValue > 100 then
            sinkRateState.startTime = time
            sinkRateState.startAlt = alt
            if sinkRateState.onStateChange then
                sinkRateState.onStateChange(sinkRateState, true)
            end
        end
    end
end


function SRSunload()
    SRSnewSinkRateState = nil
    SRSreset = nil
    SRSisStart = nil
    SRSgetDuration = nil
    SRSgetCurDuration = nil
    SRSgetCurSinkAlt = nil
    SRSgetCurSinkRate = nil
    SRSgetSinkAlt = nil
    SRSgetSinkRate = nil
    SRSrun = nil
    SRSunload = nil
end