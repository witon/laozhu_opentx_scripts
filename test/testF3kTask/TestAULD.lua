
function LZ_runModule(file)
    return dofile(file)
end

function testTrainNormal()
    dofile(HOME_DIR .. "LAOZHU/comm/Timer.lua")
    local task = dofile(HOME_DIR .. "LAOZHU/F3kWF/AULDWF.lua")

    local timer = Timer_new()
    local time = 10
    Timer_setCurTime(timer, time)
    task.setTaskParam(2, 60)
    task.start(timer)
    luaunit.assertEquals(task.getState(), 1) --no fly

    time = time + 6000
    Timer_setCurTime(timer, time)
    local isFinished = task.run(timer)
    luaunit.assertFalse(isFinished)
    luaunit.assertEquals(task.getState(), 2) --flight

    time = time + 18000
    Timer_setCurTime(timer, time)
    isFinished = task.run(timer)
    luaunit.assertFalse(isFinished)
    luaunit.assertEquals(task.getState(), 3) --landing

    time = time + 3000
    Timer_setCurTime(timer, time)
    isFinished = task.run(timer)
    luaunit.assertFalse(isFinished)
    luaunit.assertEquals(task.getState(), 1) --no fly

    time = time + 6000
    Timer_setCurTime(timer, time)
    local isFinished = task.run(timer)
    luaunit.assertFalse(isFinished)
    luaunit.assertEquals(task.getState(), 2) --flight

    time = time + 18000
    Timer_setCurTime(timer, time)
    isFinished = task.run(timer)
    luaunit.assertFalse(isFinished)
    luaunit.assertEquals(task.getState(), 3) --landing

    time = time + 3000
    Timer_setCurTime(timer, time)
    isFinished = task.run(timer)
    luaunit.assertTrue(isFinished)
 
end

HOME_DIR = os.getenv("HOME_DIR")
if not HOME_DIR then
    HOME_DIR = "./"
else
    HOME_DIR = HOME_DIR .. "/"
end
dofile(HOME_DIR .. "test/utils4Test.lua")