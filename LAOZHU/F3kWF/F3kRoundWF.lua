local preparationTime = 120
local testTime = 40
local startTime = 0
local task = nil
local timer = nil
local roundState = 1 --1: begin; 2: preparationTime; 3: testTime; 4: taskTime; 5: end; 6: task nofly; 7: task flight; 8: task land;
local isTimerMuted = false

local function setTask(taskName, noflyTime)
    if task ~= nil then
		LZ_clearTable(task)
		task = nil
		collectgarbage()
    end
    if taskName == "LastFl" then
        task = LZ_runModule(gScriptDir .. "LAOZHU/F3kWF/CommonTaskWF.lua")
        task.setTaskParam("LastFl", 420, noflyTime, isTimerMuted)
    elseif taskName == "Train" or taskName == "-" then
        task = LZ_runModule(gScriptDir .. "LAOZHU/F3kWF/CommonTaskWF.lua")
        task.setTaskParam("Train", 600, noflyTime, isTimerMuted)
    elseif taskName == "OtherTask" or taskName == "-" then
        task = LZ_runModule(gScriptDir .. "LAOZHU/F3kWF/CommonTaskWF.lua")
        task.setTaskParam("Train", 600, noflyTime, isTimerMuted)
    elseif taskName == "AULD" then
        task = LZ_runModule(gScriptDir .. "LAOZHU/F3kWF/AULDWF.lua")
        task.setTaskParam(3, noflyTime, isTimerMuted)
    elseif taskName == "TEST" then
        task = LZ_runModule(gScriptDir .. "LAOZHU/F3kWF/CommonTaskWF.lua")
        task.setTaskParam("TEST", 5, noflyTime, isTimerMuted)
    end
end

local function  getTask()
    return task
end

local function stop()
    startTime = 0
    Timer_setDowncount(timer, 0)
    timer.mute = true
    Timer_stop(timer)
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
    Timer_stop(timer)
    roundState = 4
    task.start(timer)
end


local function change2StateTestTime()
    if testTime > 0 then
        LZ_playFile("LAOZHU/test.wav", true)
        roundState = 3
        Timer_stop(timer)
        Timer_resetTimer(timer, testTime)
        Timer_setDowncount(timer, 15)
        setAnnounceCallback()
        timer.mute = isTimerMuted
        Timer_start(timer)
    else
        change2StateTaskTime()
    end
end

local function change2StateOperationTime()
    if preparationTime > 0 then
        LZ_playFile("LAOZHU/prep.wav")
        roundState = 2
        Timer_resetTimer(timer, preparationTime)
        Timer_setDowncount(timer, 5)
        timer.mute = isTimerMuted
        setAnnounceCallback()
        Timer_start(timer)
    else
        change2StateTestTime()
    end
end

local function change2StateEnd()
    roundState = 5
    Timer_stop(timer)
    Timer_setDowncount(timer, 0)
    timer.mute = true
end

local function init()
	timer = Timer_new()
	timer.mute = isTimerMuted
	Timer_setForward(timer, false)
    Timer_setDuration(timer, preparationTime)
end

local function run(time)
	Timer_setCurTime(timer, time)
	Timer_run(timer)
    if roundState == 1 then --doBegin()
        if startTime > 0 then
            change2StateOperationTime()
        end
    elseif roundState == 2 then --doPreparationTime()
        if Timer_getRemainTime(timer) <= 0 then
            change2StateTestTime()
        end
    elseif roundState == 3 then --doTestTime()
        if Timer_getRemainTime(timer) <= 0 then
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