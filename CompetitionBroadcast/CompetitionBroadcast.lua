gScriptDir = "./"
dofile("LAOZHU/LuaUtils.lua")
dofile("LAOZHU/comm/PCIO.lua")
dofile("LAOZHU/Cfg.lua")
local cfg = CFGnewCfg()
CFGreadFromFile(cfg, ".CompetitionBroadcast")
local soundPath = CFGgetStrField(cfg, 'sound_path', "./SOUND/")
local testWindow = CFGgetNumberField(cfg, 'test_window', 45)
local prepareWindow = CFGgetNumberField(cfg, 'prepare_window', 120)
local noflyWindow = CFGgetNumberField(cfg, 'nofly_window', 60)
local optParse = dofile("CompetitionBroadcast/ParseInputOpt.lua")
local ret, tasksFilePath, groupsFilePath, isSingleGroup, isReadPilotName = optParse.parse(arg)
if not ret then
    optParse.printHelp(arg)
    return
end
dofile("LAOZHU/comm/Timer.lua")
dofile("LAOZHU/LuaUtils.lua")
function LZ_runModule(file)
    return dofile(file)
end
dofile("LAOZHU/F3k/F3kFlightRecord.lua")
dofile("LAOZHU/comm/TestSound.lua")
setSoundPath(soundPath)

local f3kCompetitionWF = dofile("LAOZHU/F3kWF/F3kCompetitionWF.lua")
local time = 0

local taskFileParser = dofile("CompetitionBroadcast/TaskFileParser.lua")
local tasks = taskFileParser.parse(tasksFilePath)
if not tasks then
    print("parse tasks file " .. tasksFilePath .. " failed.")
    return
end

local groupFileParser = dofile("CompetitionBroadcast/GroupFileParser.lua")
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

time = os.time()*100
f3kCompetitionWF.start(time)
 
while true do
    time = os.time()*100
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
        print("Competition complete.")
        sleep(5000)
        break
    end
end
