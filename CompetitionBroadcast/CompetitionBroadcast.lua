gScriptDir = "./"
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

local function init()
    LZ_runModule("LAOZHU/comm/TestSound.lua")
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
    return true


end

local function run(time)
    f3kCompetitionWF.run(time)
    local competitionState, curRound, curGroup, roundWorkflow = f3kCompetitionWF.getCurStep()
    local remainTime = roundWorkflow.getTimer():getRemainTime()
    if lastPandoraSentTime ~= remainTime then
        pandora.send(curRound, curGroup, roundWorkflow)
        lastPandoraSentTime = remainTime
    end
    local event = getEvent()
    if event == 77 or event == 67 then
        print("Forward")
        cleanAudioQueue()
        if not f3kCompetitionWF.startNextUnit(time) then
            print("Competition complete.")
            return false
        end
    elseif event == 75 or event == 68 then
        print("Backward")
        cleanAudioQueue()
        f3kCompetitionWF.startPreUnit(time)
    elseif event == 17 or event == 113 then
        print("Quit")
        cleanAudioQueue()
        unInit()
        return false
    end
    local competitionWFState = f3kCompetitionWF.getCurStep()
    if competitionWFState == 3 then
        print("Time: ", LZ_formatTimeStamp(gEmuTime), "Competition completed")
        if (not isEmulate) and (not isTestRun) then
            sleep(5000)
        end
        unInit();
        return false
    end
    return true
end



if not init() then
    print("init failed")
    return
end

if gIsEmulate or gIsTestRun then
    time = gEmuTime * 100
else
    time = os.time()*100
end

f3kCompetitionWF.start(time)
 
while true do
    if isEmulate or isTestRun then
        gEmuTime = gEmuTime + 1
        time = gEmuTime * 100
    else
        time = os.time()*100
    end
    if not run(time) then
        break
    end
end
