
function testTrainNormal()
    dofile(gSDCardDir .. "LAOZHU/comm/Timer.lua")
    LZ_playFile = function (path)
    end
    local task = dofile(gSDCardDir .. "LAOZHU/F3kWF/CommonTaskWF.lua")
    task.setTaskParam("train", 600, 60)

    local timer = Timer:new()
    local time = 10
    timer:setCurTime(time)
    task.start(timer)
    luaunit.assertEquals(task.getState(), 1) --no fly

    time = time + 6000
    timer:setCurTime(time)
    local isFinished = task.run(timer)
    luaunit.assertFalse(isFinished)
    luaunit.assertEquals(task.getState(), 2) --flight

    time = time + 60000
    timer:setCurTime(time)
    isFinished = task.run(timer)
    luaunit.assertFalse(isFinished)
    luaunit.assertEquals(task.getState(), 3) --landing

    time = time + 3000
    timer:setCurTime(time)
    isFinished = task.run(timer)
    luaunit.assertTrue(isFinished) --finished
 
end

if not LZ_TEST_HARNESS then
HOME_DIR = os.getenv("HOME_DIR")
if not HOME_DIR then
    HOME_DIR = "./"
else
    HOME_DIR = HOME_DIR .. "/"
end
dofile(HOME_DIR .. "test/utils4Test.lua")
end