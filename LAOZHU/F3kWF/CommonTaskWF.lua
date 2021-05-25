local workTime = 600
local state = 1
local taskName = "Comm"
local noFlyTime = 60
local isTimerMuted = false
--1: no noFly
--2: flight
--3: landing

local flightRecord = F3KFRnewFlightRecord()
flightRecord.maxNum = 8

local function addFlight(flightTime, launchAlt, flightStartTime)
    if state == 2 or state == 3 then
        F3KFRaddFlight(flightRecord, flightTime, launchAlt, flightStartTime)
    end
end

local function announceCallback(timer)
    if state == 1 then
        LZ_playTime(15)
        LZ_playFile("LAOZHU/be-wok.wav", true)
    end
end

local function getFlightRecord()
    return flightRecord
end

local function getStateDisc()
    if state == 1 then
        return "NFLY"
    elseif state == 2 then
        return "FLY"
    elseif state == 3 then
        return "LAND"
    end
    return ""
end
local function changeState2Flight(timer)
    LZ_playFile("LAOZHU/work.wav", true)
    state = 2
    Timer_resetTimer(timer, workTime)
    Timer_setDowncount(timer, 0)
    timer.mute = true
    Timer_start(timer)
end

local function changeState2Landing(timer)
    LZ_playFile("LAOZHU/land.wav", true)
    state = 3
    Timer_resetTimer(timer, 30)
    Timer_setDowncount(timer, 15)
    timer.mute = isTimerMuted 
    Timer_start(timer)
end

local function doNoFly(timer)
    if Timer_getRemainTime(timer) <= 0 then
        Timer_stop(timer)
        changeState2Flight(timer)
    end
end

local function doFlight(timer)
    if Timer_getRemainTime(timer) <= 0 then
        Timer_stop(timer)
        changeState2Landing(timer)
    end
end

local function doLanding(timer)
    if Timer_getRemainTime(timer) <= 0 then
        Timer_stop(timer)
        return true
    end
    return false
end


local function run(timer)
    if state == 1 then
        doNoFly(timer)
    elseif state == 2 then
        doFlight(timer)
    elseif state == 3 then
        if doLanding(timer) then
            return true
        end
    end
    return false
end

local function getTaskName()
    return taskName
end

local function start(timer)
    if noFlyTime > 0 then
        LZ_playFile("LAOZHU/nofly.wav", true)
        state = 1
        Timer_resetTimer(timer, noFlyTime)
        Timer_setDowncount(timer, 10)
        timer.announceTime = 15
        timer.announceCallback = announceCallback
        timer.mute = isTimerMuted
        Timer_start(timer)
    else
        changeState2Flight(timer)
    end
end

local function getState()
    return state
end

local function getWorkTime()
    return workTime
end

local function setTaskParam(tName, wTime, nflyTime, mute)
    taskName = tName
    workTime = wTime
    noFlyTime = nflyTime
    isTimerMuted = mute
end

local function getNoFlyTime()
    return noFlyTime
end

return {
    run = run,
    getTaskName = getTaskName,
    start = start,
    getState = getState,
    getStateDisc = getStateDisc,
    setTaskParam = setTaskParam,
    getWorkTime = getWorkTime,
    getFlightRecord = getFlightRecord,
    addFlight = addFlight,
    getNoFlyTime = getNoFlyTime
}

