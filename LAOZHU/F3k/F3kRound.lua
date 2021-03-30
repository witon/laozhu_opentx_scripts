local preparationTime = 120
local testTime = 40
local startTime = 0
local task = nil
local timer = nil
local roundState = 1 --1: begin; 2: preparationTime; 3: testTime; 4: taskTime; 5: end

local function setTask(taskName)
    if task ~= nil then
		LZ_clearTable(task)
		task = nil
		collectgarbage()
    end
    if taskName == "LastFl" then
        task = LZ_runModule(gScriptDir .. "LAOZHU/F3k/Task/CommonTask.lua")
        task.setTaskParam("LastFl", 420, 60)
    elseif taskName == "Train" or taskName == "-" then
        task = LZ_runModule(gScriptDir .. "LAOZHU/F3k/Task/CommonTask.lua")
        task.setTaskParam("Train", 600, 0)
    elseif taskName == "OtherTask" or taskName == "-" then
        task = LZ_runModule(gScriptDir .. "LAOZHU/F3k/Task/CommonTask.lua")
        task.setTaskParam("Train", 600, 60)
    elseif taskName == "AULD" then
        task = LZ_runModule(gScriptDir .. "LAOZHU/F3k/Task/AULD.lua")
    elseif taskName == "TEST" then
        task = LZ_runModule(gScriptDir .. "LAOZHU/F3k/Task/CommonTask.lua")
        task.setTaskParam("TEST", 5, 5)
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
    preparationTime = oTime
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
    Timer_resetTimer(timer, preparationTime)
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

local function init()
	timer = Timer_new()
	timer.mute = false
	Timer_setForward(timer, false)
    Timer_setDuration(timer, preparationTime)
end

local function run(time)
	Timer_setCurTime(timer, time)
	Timer_run(timer)
    if roundState == 1 then --doBegin()
        if startTime > 0 then
            if preparationTime > 0 then
                change2StateOperationTime()
            elseif testTime > 0 then
                change2StateTestTime()
            else
                change2StateTaskTime()
            end
        end
    elseif roundState == 2 then --doPreparationTime()
        if Timer_getRemainTime(timer) <= 0 then
            if testTime > 0 then
                change2StateTestTime()
            else
                change2StateTaskTime()
            end
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