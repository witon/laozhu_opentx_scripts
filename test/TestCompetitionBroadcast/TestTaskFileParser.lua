
function LZ_runModule(file)
    return dofile(file)
end

function testParseTask()
    local taskFileParser = dofile(HOME_DIR .. "CompetitionBroadcast/TaskFileParser.lua")
    local tasks = taskFileParser.parse("test/tasks.txt")
    local destTasks = {'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J'}
    for i=1, #destTasks, 1 do
        local task = tasks[i]
        luaunit.assertEquals(task.id, destTasks[i])
    end
end

HOME_DIR = os.getenv("HOME_DIR")
if not HOME_DIR then
    HOME_DIR = "./"
else
    HOME_DIR = HOME_DIR .. "/"
end
dofile(HOME_DIR .. "test/utils4Test.lua")