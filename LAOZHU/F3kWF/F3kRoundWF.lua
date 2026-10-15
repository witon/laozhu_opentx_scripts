local preparationTime = 120
local testTime = 40
local startTime = 0
local task = nil
local loadedTaskPath = nil
local timer = nil
local roundState = 1 --1: begin; 2: preparationTime; 3: testTime; 4: taskTime; 5: end; 6: task nofly; 7: task flight; 8: task land;
local isTimerMuted = false
local preparationCallback = nil

local function setPreparationCallback(callback)
    preparationCallback = callback
end

local function applyTaskParam(taskName, noflyTime)
    if taskName == "LastFl" then
        task.setTaskParam("LastFl", 420, noflyTime, isTimerMuted)
    elseif taskName == "Train" or taskName == "-" then
        task.setTaskParam("Train", 600, noflyTime, isTimerMuted)
    elseif taskName == "OtherTask" then
        task.setTaskParam("Train", 600, noflyTime, isTimerMuted)
    elseif taskName == "AULD" then
        task.setTaskParam(3, noflyTime, isTimerMuted)
    elseif taskName == "TEST" then
        task.setTaskParam("TEST", 5, noflyTime, isTimerMuted)
    elseif taskName == "Normal" then
        task.setTaskParam("Normal", 5999, noflyTime, isTimerMuted)
    end
end

local function setTask(taskName, noflyTime, p1, p2)
    local path
    if taskName == "AULD" then
        path = gSDCardDir .. "LAOZHU/F3kWF/AULDWF.lua"
    elseif taskName == "LastFl" or taskName == "Train" or taskName == "-"
        or taskName == "OtherTask" or taskName == "TEST" or taskName == "Normal" then
        path = gSDCardDir .. "LAOZHU/F3kWF/CommonTaskWF.lua"
    else
        return
    end
    if task ~= nil and loadedTaskPath == path then
        applyTaskParam(taskName, noflyTime)
        return
    end
    local loaded = LZ_runModule(path)
    if loaded == nil then
        DBG_err("F3k task load failed", path)
        return
    end
    if task ~= nil then
        LZ_clearTable(task)
        task = nil
        collectgarbage()
    end
    task = loaded
    loadedTaskPath = path
    applyTaskParam(taskName, noflyTime)
end

local function  getTask()
    return task
end

local function stop()
    startTime = 0
    timer:setDowncount(0)
    timer.mute = true
    timer:stop()
    roundState = 1
end

local function setRoundParam(oTime, tTime, taskName, noflyTime, mute)
    stop()
    preparationTime = oTime
    testTime = tTime
    isTimerMuted = mute
    setTask(taskName, noflyTime)
end

local function isStart()
    return startTime ~= 0
end

local function start(time)
    startTime = time
    roundState = 1
end

local function beforeTestCallback(t)
    LZ_playTime(10)
    LZ_playFile("LAOZHU/be-tst.wav", true)
end

local function beforeNoFlyCallback(t)
    LZ_playTime(20)
    LZ_playFile("LAOZHU/be-nfl.wav", true)
end

local function setAnnounceCallback()
    if roundState == 1 then
        goto prep
    elseif roundState == 2 then
        goto test
    elseif roundState == 3 then
        goto task
    end
    ::prep::
    if preparationTime > 0 then
        return
    end
    ::test::
    if testTime > 0 then
        timer.announceTime = 10
        timer.announceCallback = beforeTestCallback
        return
    end
    ::task::
    if task.getNoFlyTime() > 0 then
        timer.announceTime = 20
        timer.announceCallback = beforeNoFlyCallback
        return
    end
end

local function change2StateTaskTime()
    timer:stop()
    roundState = 4
    task.start(timer)
end


local function change2StateTestTime()
    if testTime > 0 then
        LZ_playFile("LAOZHU/test.wav", true)
        roundState = 3
        timer:stop()
        timer:resetTimer(testTime)
        timer:setDowncount(15)
        setAnnounceCallback()
        timer.mute = isTimerMuted
        timer:start()
    else
        change2StateTaskTime()
    end
end

local function change2StateOperationTime()
    if preparationTime > 0 then
        LZ_playTime(preparationTime)
        LZ_playFile("LAOZHU/prep.wav")
        roundState = 2
        timer:resetTimer(preparationTime)
        timer:setDowncount(5)
        timer.mute = isTimerMuted
        setAnnounceCallback()
        timer:start()
        if preparationCallback then
            preparationCallback()
        end
    else
        change2StateTestTime()
    end
end

local function change2StateEnd()
    roundState = 5
    timer:stop()
    timer:setDowncount(0)
    timer.mute = true
end

local function init()
	timer = Timer:new()
	timer.mute = isTimerMuted
    timer.isReadZero = false
	timer:setForward(false)
    timer:setDuration(preparationTime)
end

local function run(time)
	timer:setCurTime(time)
	timer:run()
    if roundState == 1 then --doBegin()
        if startTime > 0 then
            change2StateOperationTime()
        end
    elseif roundState == 2 then --doPreparationTime()
        if timer:getRemainTime() <= 0 then
            change2StateTestTime()
        end
    elseif roundState == 3 then --doTestTime()
        if timer:getRemainTime() <= 0 then
            change2StateTaskTime()
        end
    elseif roundState == 4 then --doTaskTime()
        if task.run(timer) then
            change2StateEnd()
        end
    elseif roundState == 5 then
        --doEnd()
    end
end

local function getState()
    return roundState
end

local function getTimer()
    return timer
end


local function addFlight(flightTime, launchAlt, flightStartTime)
    if roundState == 4 then
        task.addFlight(flightTime, launchAlt, flightStartTime)
    end
end

return {run = run,
        init = init,
        start = start,
        setRoundParam = setRoundParam,
        getState = getState,
        stop = stop,
        getTimer = getTimer,
        getTask = getTask,
        isStart = isStart,
        addFlight = addFlight
    }