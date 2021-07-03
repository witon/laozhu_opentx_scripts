gEmuTime = 1
gIsTestRun = false
gIsEmulate = false
local cfg = nil
local f3kCompetitionWF = nil
local time = 0
local groups = nil
local tasks = nil
local groupNum = 1
local roundNum = 0
local pandora = nil
local lastPandoraSentTime = 0

function LZ_runModule(file)
    return dofile(gScriptDir .. file)
end

local function updateTime()
    if isEmulate or isTestRun then
        gEmuTime = gEmuTime + 1
        time = gEmuTime * 100
    else
        time = os.time()*100
    end
end

local function init()
    LZ_runModule("LAOZHU/comm/TestSound.lua")
    startAudio()
    LZ_runModule("LAOZHU/LuaUtils.lua")
    LZ_runModule("LAOZHU/comm/PCIO.lua")
    LZ_runModule("LAOZHU/CfgO.lua")
    cfg = CFGC:new()
    cfg:readFromFile(".CompetitionBroadcast")

    pandora = LZ_runModule("CompetitionBroadcast/Pandora.lua")
    local comPort = cfg:getStrField('com_port', "com6")
    if not pandora.open(comPort) then
        print("open com failed, port: " .. comPort)
    end
    local soundPath = cfg:getStrField('sound_path', "./SOUND/")
    local testWindow = cfg:getNumberField('test_window', 45)
    local prepareWindow = cfg:getNumberField('prepare_window', 120)
    local noflyWindow = cfg:getNumberField('nofly_window', 60)
    local optParse = LZ_runModule("CompetitionBroadcast/ParseInputOpt.lua")
    local ret, tasksFilePath, groupsFilePath, isSingleGroup, isReadPilotName, isTestRun, isEmulate = optParse.parse(arg)
    gIsTestRun = isTestRun
    gIsEmulate = isEmulate
    if not ret then
        optParse.printHelp(arg)
        return false
    end
    LZ_runModule("LAOZHU/comm/Timer.lua")
    LZ_runModule("LAOZHU/LuaUtils.lua")
    LZ_runModule("LAOZHU/OTUtils.lua")
    LZ_runModule("LAOZHU/F3k/F3kFlightRecord.lua")
    setSoundPath(soundPath)
    setTestRun(isTestRun)
    f3kCompetitionWF = LZ_runModule("LAOZHU/F3kWF/F3kCompetitionWF.lua")
    local taskFileParser = LZ_runModule("CompetitionBroadcast/TaskFileParser.lua")
    local tasks = taskFileParser.parse(tasksFilePath)
    if not tasks then
        print("parse tasks file " .. tasksFilePath .. " failed.")
        return false
    end
    local groupFileParser = LZ_runModule("CompetitionBroadcast/GroupFileParser.lua")
    groups = groupFileParser.parse(groupsFilePath)
    if not groups then
        print("parse groups file " .. groupsFilePath .. " failed.")
        return false
    end
    roundNum = #groups
    groupNum = #groups[1]
    if isSingleGroup then
        groupNum = 1
    end

    f3kCompetitionWF.setGroups(groups)
    f3kCompetitionWF.setCompetitionParam(noflyWindow, prepareWindow, testWindow, groupNum, isSingleGroup, roundNum, isReadPilotName)

    for roundIndex, task in pairs(tasks) do
        f3kCompetitionWF.addTask(task)
    end
    updateTime()
    f3kCompetitionWF.start(time)
    return true
end

local function exit()
    cleanAudioQueue()
    stopAudio()
end


local function forward()
    cleanAudioQueue()
    if not f3kCompetitionWF.startNextUnit(time) then
        print("Competition complete.")
        f3kCompetitionWF.resetCompetition()
        return false
    end
    return true
end

local function backward()
    cleanAudioQueue()
    f3kCompetitionWF.startPreUnit(time)
    return true
end

local function getStateDesc(roundState, taskState)
    local stateStr = ""
    if roundState == 2 then
        stateStr = "Preparation Time"
    elseif roundState == 3 then
        stateStr = "Test Window"
    elseif roundState == 4 then
        if taskState == 1 then
            stateStr = "No Fly Window"
        elseif taskState == 2 then
            stateStr = "Working Window"
        elseif taskState == 3 then
            stateStr = "Landing Window"
        else
            stateStr = "ST"
        end
    else
        stateStr = "ST"
    end
    return stateStr
end


local function getRoundInfo()
    local competitionState, curRound, curGroup, roundWorkflow = f3kCompetitionWF.getCurStep()
    local remainTime = roundWorkflow.getTimer():getRemainTime()
    local roundState = roundWorkflow.getState()
    local task = roundWorkflow.getTask()
    local taskState = task.getState()
    local stateDesc = getStateDesc(roundState, taskState)
    return competitionState, curRound, curGroup, remainTime, stateDesc, task.getTaskName()
end


local function run()
    updateTime()
    f3kCompetitionWF.run(time)
    local competitionState, curRound, curGroup, roundWorkflow = f3kCompetitionWF.getCurStep()
    local remainTime = roundWorkflow.getTimer():getRemainTime()
    if lastPandoraSentTime ~= remainTime then
        pandora.send(curRound, curGroup, roundWorkflow)
        lastPandoraSentTime = remainTime
    end
    local competitionWFState = f3kCompetitionWF.getCurStep()
    if competitionWFState == 3 then
        return false
    end
    return true
end

return {
    init=init,
    run=run,
    exit=exit,
    forward=forward,
    backward=backward,
    getRoundInfo=getRoundInfo
}