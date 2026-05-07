function SRSnewSinkRateState()
    return {startTime = -1,
            startAlt = -1000,
            stopTime = -1,
            stopAlt = -1000,
            curTime = -1,
            curAlt = -1
        }
end

function SRSreset(sinkRateState)
    sinkRateState.startTime = -1
    sinkRateState.startAlt = -1000
    sinkRateState.stopTime = -1
    sinkRateState.stopAlt = -1000
    sinkRateState.curTime = -1
    sinkRateState.curAlt = -1
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

function SRSgetCurDuration(sinkRateState)
    if not SRSisStart(sinkRateState) then
        return 0
    end
    return sinkRateState.curTime - sinkRateState.startTime
end

function SRSgetCurSinkAlt(sinkRateState)
    if not SRSisStart(sinkRateState) then
        return 0
    end
    return sinkRateState.startAlt - sinkRateState.curAlt
end

function SRSgetCurSinkRate(sinkRateState)
    local dur = sinkRateState.curTime - sinkRateState.startTime
    if dur == 0 then
        return 0
    end
    local sinkAlt = sinkRateState.startAlt - sinkRateState.curAlt
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
    sinkRateState.curTime = time
    sinkRateState.curAlt = alt
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
    SRSsetOnStateChange = nil
end