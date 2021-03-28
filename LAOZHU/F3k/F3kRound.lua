local operationTime = 120
local testTime = 40
local startTime = 0
local landingTime = 30
local task = nil
local timer = nil
local roundState = 1 --1: begin; 2: operationTime; 3: testTime; 4: taskTime; 5: end


local function setTask(taskName)
    if task ~= nil then
		LZ_clearTable(task)
		task = nil
		collectgarbage()
    end
    if taskName == "LastFl" then
        task = LZ_runModule(gScriptDir .. "LAOZHU/F3k/Task/CommonTask.lua")
        task.setTaskName("LastFl")
        task.setWorkTime(420)
    elseif taskName == "Train" or taskName == "-" then
        task = LZ_runModule(gScriptDir .. "LAOZHU/F3k/Task/CommonTask.lua")
        task.setTaskName("Train")
        task.setWorkTime(600)
    elseif taskName == "AULD" then
        task = LZ_runModule(gScriptDir .. "LAOZHU/F3k/Task/AULD.lua")
    elseif taskName == "TEST" then
        task = LZ_runModule(gScriptDir .. "LAOZHU/F3k/Task/CommonTask.lua")
        task.setTaskName("TEST")
        task.setNoFlyTime(1)
        task.setWorkTime(600)
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

local function setRoundParam(oTime, tTime, taskName)
    stop()
    operationTime = oTime
    testTime = tTime
    setTask(taskName)
end

local function isStart()
    return startTime ~= 0
end

local function start(time)
    startTime = time
    roundState = 1
end

local function change2StateOperationTime()
    LZ_playFile("LAOZHU/prep.wav")
    roundState = 2
    Timer_stop(timer)
    Timer_resetTimer(timer, operationTime)
    Timer_setDowncount(timer, 0)
    timer.mute = true
    Timer_start(timer)
end

local function change2StateTestTime()
    LZ_playFile("LAOZHU/test.wav")
    roundState = 3
    Timer_stop(timer)
    Timer_resetTimer(timer, testTime)
    Timer_setDowncount(timer, 15)
    timer.mute = false
    Timer_start(timer)
end

local function change2StateTaskTime()
    Timer_stop(timer)
    roundState = 4
    task.start(timer)
end

local function change2StateEnd()
    roundState = 5
    Timer_stop(timer)
    Timer_setDowncount(timer, 0)
    timer.mute = true
end

local function doBegin(time)
    if startTime > 0 then
        change2StateOperationTime()
    end
end

local function doOperationTime(time)
    if Timer_getRemainTime(timer) <= 0 then
        change2StateTestTime()
    end
end

local function doTestTime(time)
    if Timer_getRemainTime(timer) <= 0 then
        change2StateTaskTime()
    end
end

local function doTaskTime(time)
    if task.run(timer) then
        change2StateEnd()
    end
end

local function doEnd(time)
end

local function init()
	timer = Timer_new()
	timer.mute = false
	Timer_setForward(timer, false)
    Timer_setDuration(timer, operationTime)
end

local function run(time)
	Timer_setCurTime(timer, time)
	Timer_run(timer)
    if roundState == 1 then
        doBegin(time)
    elseif roundState == 2 then
        doOperationTime(time)
    elseif roundState == 3 then
        doTestTime(time)
    elseif roundState == 4 then
        doTaskTime(time)
    elseif roundState == 5 then
        doEnd(time)
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

