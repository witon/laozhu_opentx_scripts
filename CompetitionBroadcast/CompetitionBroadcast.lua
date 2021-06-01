dofile("LAOZHU/LuaUtils.lua")
local optParse = dofile("CompetitionBroadcast/ParseInputOpt.lua")
local ret, tasksFilePath, groupsFilePath, isSingleGroup, isReadPilotName = optParse.parse(arg)
if not ret then
    optParse.printHelp(arg)
    return
end
dofile("LAOZHU/comm/Timer.lua")
dofile("LAOZHU/LuaUtils.lua")
gScriptDir = "./"
function LZ_runModule(file)
    return dofile(file)
end
dofile("LAOZHU/F3k/F3kFlightRecord.lua")
dofile("LAOZHU/comm/TestSound.lua")
setSoundPath("C:\\opentxsdcard1\\SOUNDS\\")
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
f3kCompetitionWF.setCompetitionParam(60, 60, 45, groupNum, isSingleGroup, roundNum, isReadPilotName)

for roundIndex, task in pairs(tasks) do
    f3kCompetitionWF.addTask(task)
end


time = os.time()*100
f3kCompetitionWF.start(time)
 
while true do
    time = os.time()*500
    f3kCompetitionWF.run(time)
    local event = getEvent()
    if event == 77 then
        print("Forward")
        cleanAudioQueue()
        if not f3kCompetitionWF.startNextUnit(time) then
            print("Competition complete.")
            break
        end
    elseif event == 75 then
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
        local i = 0
        while i < 50000 do
            i = i + 1
        end
        break
    end
end