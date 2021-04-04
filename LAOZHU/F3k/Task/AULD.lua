local flightTime = 180
local state = 1
local curFlight = 1
local flightCount = 3
local workTime = 180 * 3 + 30 * 3 + 120
--1: no fly
--2: flight
--3: landing

local flightRecord = F3KFRnewFlightRecord()
flightRecord.maxNum = 8

local function getNoFlyTime()
    return 60
end

local function addFlight(flightTime, launchAlt, flightStartTime)
    if state == 2 or state == 3 then
        F3KFRaddFlight(flightRecord, flightTime, launchAlt, flightStartTime)
    end
end


local function getFlightRecord()
    return flightRecord
end


local function getStateDisc()
    if state == 1 then
        return "NFLY"
    elseif state == 2 then
        return "FLY" .. curFlight
    elseif state == 3 then
        return "LAND"
    end
    return ""
end

local function announceCallback(timer)
    if state == 1 then
        LZ_playTime(10)
        LZ_playFile("LAOZHU/be-lau.wav", true)
    elseif state == 3 then
        LZ_playTime(15)
        LZ_playFile("LAOZHU/be-nfl.wav", true)
    end
end


local function changeState2NoFly(timer)
    state = 1
    LZ_playFile("LAOZHU/nofly.wav", true)
    Timer_resetTimer(timer, getNoFlyTime())
    Timer_setDowncount(timer, 5)
    timer.announceTime = 10
    timer.announceCallback = announceCallback
    timer.mute = false
    Timer_start(timer)
end


local function changeState2Flight(timer)
    playTone(1000, 3000, 0, PLAY_BACKGROUND)
    state = 2
    Timer_resetTimer(timer, flightTime)
    Timer_setDowncount(timer, 0)
    timer.mute = true
    Timer_start(timer)
end

local function changeState2Landing(timer)
    state = 3
    LZ_playFile("LAOZHU/land.wav", true)
    Timer_resetTimer(timer, 30)
    Timer_setDowncount(timer, 10)
    timer.announceTime = 15
    timer.announceCallback = announceCallback
    timer.mute = false
    Timer_start(timer)
end

local function doNoFly(timer)
    if Timer_getRemainTime(timer) == 0 then
        changeState2Flight(timer)
    end
end

local function doFlight(timer)
    if Timer_getRemainTime(timer) == 0 then
        changeState2Landing(timer)
    end
end

local function doLanding(timer)
    if Timer_getRemainTime(timer) == 0 then
        curFlight = curFlight + 1
        if curFlight > flightCount then
            return true
        end
        changeState2NoFly(timer)
        return false
    end
end

local function run(timer)
    if state == 1 then
        doNoFly(timer)
    elseif state == 2 then
        doFlight(timer)
    elseif state == 3 then
        local isFinished = doLanding(timer)
        if isFinished then
            return true
        end
    end
    return false
end

local function getTaskName()
    return "AULD"
end

local function setFlightCount(count)
    flightCount = count
end

local function getWorkTime()
    return workTime
end

return {run=run,
        getTaskName = getTaskName,
        start=changeState2NoFly,
        setFlightCount=setFlightCount,
        getStateDisc=getStateDisc,
        addFlight=addFlight,
        getFlightRecord=getFlightRecord,
        getWorkTime = getWorkTime,
        getNoFlyTime = getNoFlyTime
    }
