function Timer_new()
    return {startTime=0,
            stopTime = 0,
            duration = -1,
            lastReadTime = -1,
            downcountSeconds = -1,
            isForward = true,
            curTime = 0,
            mute = false,
            announceTime = 0,
            announceCallback = nil
        }
end

function Timer_setDuration(timer, d)
    timer.duration = d
end

function Timer_resetTimer(timer, d)
    timer.startTime = 0
    timer.stopTime = 0
    timer.duration = d
    timer.lastReadTime = -1
    timer.announceTime = 0
    timer.announceCallback = nil
end

function Timer_setCurTime(timer, t)
    timer.curTime = t
end

function Timer_setForward(timer, forward)
    timer.isForward = forward
end

function Timer_setDowncount(timer, seconds)
    timer.downcountSeconds = seconds
end

function Timer_start(timer)
    timer.startTime = timer.curTime
end

function Timer_isstart(timer)
    if timer.startTime > 0 and timer.stopTime == 0 then
        return true
    else
        return false
    end
end

function Timer_stop(timer)
    timer.stopTime = timer.curTime
end

function Timer_getRemainTime(timer)
    if timer.startTime == 0 then
        return timer.duration
    end
    if timer.duration < 0 then
        return timer.duration
    end

    if timer.stopTime > 0 then
        return timer.duration - math.floor((timer.stopTime- timer.startTime) / 100)
    else
        return timer.duration - math.floor((timer.curTime - timer.startTime) / 100)
    end
end

function Timer_getRunTime(timer)
    if timer.startTime == 0 then
        return 0
    end
    if timer.stopTime > 0 then
        return math.floor((timer.stopTime- timer.startTime) / 100)
    else
        return math.floor((timer.curTime - timer.startTime) / 100)
    end
end

function Timer_getDuration(timer)
    if timer.stopTime <= 0 then
        return Timer_getRunTime(timer)
    end
    return math.floor((timer.stopTime - timer.startTime) / 100)
end

local function readDowncount(timer, time)
    if timer.downcountSeconds > 0 and time <= timer.downcountSeconds then
        timer.lastReadTime = time
        LZ_playNumber(time, 0)
        return
    end
end

local function readIntegralTime(timer, time)
    if timer.downcountSeconds ~= -1 and time == 0 then
        return
    end

    if time % 30 == 0 then
        timer.lastReadTime = time
        LZ_playTime(time)
    end
end


function Timer_readRemainTime(timer)
    if timer.duration <= 0 then
        return
    end
    local remainSeconds = Timer_getRemainTime(timer)
    if remainSeconds == timer.lastReadTime then
        return
    end
    if remainSeconds < 0 then
        return
    end

    if remainSeconds == timer.duration then
        return
    end
    
    readDowncount(timer, remainSeconds)
    readIntegralTime(timer, remainSeconds)
end

function Timer_readRunTime(timer)
    local remainSeconds = Timer_getRemainTime(timer)
    if remainSeconds < timer.downcountSeconds and remainSeconds >= 0 then
        if timer.duration <= 0 then
            return
        end
        if remainSeconds == timer.lastReadTime then
            return
        end
        readDowncount(timer, remainSeconds)
        return
    end
    local runSeconds = Timer_getRunTime(timer)
    if runSeconds == 0 or runSeconds == timer.lastReadTime then
        return
    end
    readIntegralTime(timer, runSeconds)
end

function Timer_run(timer)
    if timer.startTime == 0 then
        return
    end
    if timer.announceTime ~= 0 and timer.announceCallback then
        if (timer.isForward and timer.announceTime == Timer_getRunTime(timer)) or
            ((not timer.isForward) and timer.announceTime == Timer_getRemainTime(timer)) then
            timer.announceCallback(timer)
            timer.announceTime = 0
        end
    end

    if timer.mute then
        return
    end
    if timer.isForward then
        Timer_readRunTime(timer)
    else
        Timer_readRemainTime(timer)
    end

end

function Timer_unload()
    Timer_new = nil
    Timer_setDuration = nil
    Timer_resetTimer = nil
    Timer_setCurTime = nil
    Timer_setForward = nil
    Timer_setDowncount = nil
    Timer_start = nil
    Timer_isstart = nil
    Timer_stop = nil
    Timer_getRemainTime = nil
    Timer_getRunTime = nil
    Timer_getDuration = nil
    readDowncount = nil
    readIntegralTime = nil
    Timer_readRemainTime = nil
    Timer_readRunTime = nil
    Timer_run = nil
end
