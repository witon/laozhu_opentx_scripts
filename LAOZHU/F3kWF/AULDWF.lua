local flightTime = 183
local state = 1
local curFlight = 1
local flightCount = 3
local noflyTime = 60
local workTime = 183 * 3 + 30 * 3 + 120
local isTimerMuted = false
--1: no fly
--2: flight
--3: landing

local flightRecord = F3KFRnewFlightRecord()
flightRecord.maxNum = 15

local function getNoFlyTime()
    return noflyTime
end

local function addFlight(flightTime, launchAlt, flightStartTime)
    if state == 2 or state == 3 then
        F3KFRaddFlight(flightRecord, flightTime, launchAlt, flightStartTime)
    end
end


local function getFlightRecord()
    return flightRecord
end

local function getState()
    return state, curFlight
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
    timer:resetTimer(getNoFlyTime())
    timer:setDowncount(5)
    timer.announceTime = 10
    timer.announceCallback = announceCallback
    timer.mute = isTimerMuted
    timer:start()
end


local function changeState2Flight(timer)
    playTone(1000, 3000, 0, PLAY_BACKGROUND)
    state = 2
    timer:resetTimer(flightTime)
    timer:setDowncount(0)
    timer.mute = isTimerMuted
    timer:start()
end

local function changeState2Landing(timer)
    state = 3
    playTone(1000, 3000, 0, PLAY_BACKGROUND)
    LZ_playFile("LAOZHU/land.wav", true)
    timer:resetTimer(30)
    timer:setDowncount(10)
    timer.announceTime = 15
    timer.announceCallback = announceCallback
    timer.mute = isTimerMuted
    timer:start()
end

local function doNoFly(timer)
    if timer:getRemainTime() <= 0 then
        changeState2Flight(timer)
    end
end

local function doFlight(timer)
    if timer:getRemainTime() <= 0 then
        changeState2Landing(timer)
    end
end

local function doLanding(timer)
    if timer:getRemainTime() <= 0 then
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

local function setTaskParam(count, nTime, mute)
    flightCount = count
    noflyTime = nTime
    isTimerMuted = mute
end

local function getWorkTime()
    return workTime
end

return {run=run,
        getTaskName = getTaskName,
        start=changeState2NoFly,
        setTaskParam = setTaskParam,
        getState = getState,
        getStateDisc=getStateDisc,
        addFlight=addFlight,
        getFlightRecord=getFlightRecord,
        getWorkTime = getWorkTime,
        getNoFlyTime = getNoFlyTime
    }
