local noflyTime = 0
local preparationTime = 0
local testTime = 0
local competitionUnits = {}
--[round][group][name]
--
--
local curRound = 1
local curGroup = 1
local groupNum = 1
local isSingleGroup = false
local isReadPilotName = false
local roundWorkflow = LZ_runModule("LAOZHU/F3kWF/F3kRoundWF.lua")
local competitionState = 1  --1: begin; 2: task running; 3:end
local tasks = {}
local groups = {}
roundWorkflow.init()
--unit.roundIndex
--unit.taskName
--unit.groupIndex
--unit.competitors


local function setGroups(g)
    groups = g
end

local function setCompetitionParam(nTime, pTime, tTime, gNum, isSG, rNum, isRPN)
    noflyTime = nTime
    preparationTime = pTime
    testTime = tTime
    groupNum = gNum
    isSingleGroup = isSG
    isReadPilotName = isRPN
    for round=1, rNum, 1 do
        competitionUnits[round] = {}
        for group=1, gNum, 1 do
            competitionUnits[round][group] = {}
        end
    end
end

local function addCompetitionUnit(roundIndex, groupIndex, competitor)
    local unit = competitionUnits[roundIndex][groupIndex]
    unit[#unit + 1] = competitor
end

local function addTask(task)--taskName)
    tasks[#tasks + 1] = task
end

local function clearTasks()
    tasks = {}
end

local function taskNameMap(taskID)
    local taskName = ''
    if taskID == 'A' then
        taskName = 'LastFl'
    elseif taskID == 'C' then
        taskName = 'AULD'
    else 
        taskName = 'OtherTask'
    end
    return taskName
end

local function getTaskVoiceFilePath(taskID)
    return "LAOZHU/task-" .. string.lower(taskID) .. ".wav"
end

local function broadcastCurUnitInfo()
    local task = tasks[curRound]
    if gIsEmulate or gIsTestRun then
        print("Time: ", LZ_formatTimeStamp(gEmuTime), "Round: " .. curRound, "Group: " .. curGroup, "Task: " .. task.id)
    else
        print("Round: " .. curRound, "Group: " .. curGroup, "Task: " .. task.id)
    end
 
    LZ_playFile("LAOZHU/round.wav")
    LZ_playNumber(curRound, 0)
    if not isSingleGroup then
        LZ_playFile("LAOZHU/group.wav")
        LZ_playNumber(curGroup, 0)
    end

    LZ_playFile(getTaskVoiceFilePath(task.id))

    if not isReadPilotName then
        return
    end
    if isSingleGroup then
        LZ_playFile("LAOZHU/pilot.wav")
    end
    if groups then
        local group = groups[curRound][curGroup]
        for i, pilotName in pairs(group) do
            LZ_playFile("pilot/".. pilotName .. ".wav")
        end
        if isSingleGroup then
            local group = groups[curRound][2]
            if #group > 0 then
                LZ_playFile("LAOZHU/assis.wav")
                for i, pilotName in pairs(group) do
                    LZ_playFile("pilot/".. pilotName .. ".wav")
                end
            end
        end
    end

end

local function startPreUnit(curTime)
    roundWorkflow.stop()
    if curGroup == 1 and curRound == 1 then
        broadcastCurUnitInfo()
        roundWorkflow.start(curTime)
        return true
    end

    curGroup = curGroup - 1
    if curGroup < 1 then
        curRound = curRound - 1
        curGroup = groupNum
    end
    broadcastCurUnitInfo()
    local task = tasks[curRound]
    local unit = competitionUnits[curRound][curGroup]
    local taskName = taskNameMap(task.id)
	roundWorkflow.setRoundParam(preparationTime, testTime, taskName, noflyTime, false)
    roundWorkflow.start(curTime)
    return true
end

local function startNextUnit(curTime)
    roundWorkflow.stop()
    curGroup = curGroup + 1
    if curGroup > groupNum then
        curRound = curRound + 1
        if curRound > #tasks then
            return false
        end
        curGroup = 1
    end

    broadcastCurUnitInfo()

    local task = tasks[curRound]
    local unit = competitionUnits[curRound][curGroup]
    local taskName = taskNameMap(task.id)

	roundWorkflow.setRoundParam(preparationTime, testTime, taskName, noflyTime, false)
    roundWorkflow.start(curTime)
    return true
end

local function doBegin(time)
end


local function doRunning(time)
    if roundWorkflow.getState() == 5 then   --round end
        if not startNextUnit(time) then --competion end
            competitionState = 3
            return
        end
    end
    roundWorkflow.run(time)
end

local function doEnd(time)
end


local function run(time)
    if competitionState == 1 then
        doBegin(time)
    elseif competitionState == 2 then
        doRunning(time)
    elseif competitionState == 3 then
        doEnd(time)
    end
end

local function start(time)
    competitionState = 2
    curRound = 1
    curGroup = 0
    startNextUnit(time)
end

local function resetCompetion()
    competitionState = 1
    curRound = 1
    curGroup = 1
end

local function getCurStep()
    return competitionState, curRound, curGroup, roundWorkflow
end

return {run = run,
        start = start,
        addTask = addTask,
        clearTasks = clearTasks,
        setCompetitionParam = setCompetitionParam,
        getCurStep = getCurStep,
        setGroups = setGroups,
        startNextUnit = startNextUnit,
        startPreUnit = startPreUnit
    }