gScriptDir = "./"
function LZ_runModule(file)
    return dofile(gScriptDir .. file)
end

gEmuTime = 1
gIsTestRun = false
LZ_runModule("LAOZHU/LuaUtils.lua")
LZ_runModule("LAOZHU/comm/PCIO.lua")
LZ_runModule("LAOZHU/CfgO.lua")

local cfg = CFGC:new()
cfg:readFromFile(".CompetitionBroadcast")
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
    return
end
LZ_runModule("LAOZHU/comm/Timer.lua")
LZ_runModule("LAOZHU/LuaUtils.lua")
LZ_runModule("LAOZHU/OTUtils.lua")
LZ_runModule("LAOZHU/F3k/F3kFlightRecord.lua")
LZ_runModule("LAOZHU/comm/TestSound.lua")
setSoundPath(soundPath)
setTestRun(isTestRun)
local f3kCompetitionWF = LZ_runModule("LAOZHU/F3kWF/F3kCompetitionWF.lua")
local time = 0

local taskFileParser = LZ_runModule("CompetitionBroadcast/TaskFileParser.lua")
local tasks = taskFileParser.parse(tasksFilePath)
if not tasks then
    print("parse tasks file " .. tasksFilePath .. " failed.")
    return
end

local groupFileParser = LZ_runModule("CompetitionBroadcast/GroupFileParser.lua")
local groups = groupFileParser.parse(groupsFilePath)
if not groups then
    print("parse groups file " .. groupsFilePath .. " failed.")
    return
end

local roundNum = #groups
local groupNum = #groups[1]
if isSingleGroup then
    groupNum = 1
end

f3kCompetitionWF.setGroups(groups)
f3kCompetitionWF.setCompetitionParam(noflyWindow, prepareWindow, testWindow, groupNum, isSingleGroup, roundNum, isReadPilotName)

for roundIndex, task in pairs(tasks) do
    f3kCompetitionWF.addTask(task)
end

if isEmulate or isTestRun then
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
    f3kCompetitionWF.run(time)
    local event = getEvent()
    if event == 77 or event == 68 then
        print("Forward")
        cleanAudioQueue()
        if not f3kCompetitionWF.startNextUnit(time) then
            print("Competition complete.")
            break
        end
    elseif event == 75 or event == 67 then
        print("Backward")
        cleanAudioQueue()
        f3kCompetitionWF.startPreUnit(time)
    elseif event == 17 then
        print("Quit")
        cleanAudioQueue()
        return
    end
    local competitionWFState = f3kCompetitionWF.getCurStep()
    if competitionWFState == 3 then
        print("Time: ", LZ_formatTimeStamp(gEmuTime), "Competition completed")
        if (not isEmulate) and (not isTestRun) then
            sleep(5000)
        end
        unInit();
        break;
    end
end
