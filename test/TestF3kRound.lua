
function testF3kRoundNormal()
    dofile(gSDCardDir .. "LAOZHU/comm/Timer.lua")
    LZ_playFile = function (filepath)
    end
    LZ_playTime = function () end
    local f3kRound = dofile(gSDCardDir .. "LAOZHU/F3kWF/F3kRoundWF.lua")
    f3kRound.init()
    f3kRound.setRoundParam(120, 40, "TEST", 5)
    luaunit.assertEquals(f3kRound.getState(), 1) --begin
    local time = 10
    f3kRound.start(time)
    f3kRound.run(time)
    luaunit.assertEquals(f3kRound.getState(), 2) --operation
    time = time + 6000
    f3kRound.run(time)
    luaunit.assertEquals(f3kRound.getState(), 2) --operation
    time = time + 5990
    f3kRound.run(time)
    luaunit.assertEquals(f3kRound.getState(), 2) --operation
    time = time + 10
    f3kRound.run(time)
    luaunit.assertEquals(f3kRound.getState(), 3) --test
    time = time + 3900
    f3kRound.run(time)
    luaunit.assertEquals(f3kRound.getState(), 3) --test
    time = time + 90
    f3kRound.run(time)
    luaunit.assertEquals(f3kRound.getState(), 3) --test

    time = time + 10
    f3kRound.run(time)
    luaunit.assertEquals(f3kRound.getState(), 4) --task time nofly

    time = time + 500
    f3kRound.run(time)
    luaunit.assertEquals(f3kRound.getState(), 4) --task time flight

    time = time + 500
    f3kRound.run(time)
    luaunit.assertEquals(f3kRound.getState(), 4) --task time landing

    time = time + 3000
    f3kRound.run(time)
    luaunit.assertEquals(f3kRound.getState(), 5) --task time end -- round end


end

local function runRoundCase(fn)
    dofile(gSDCardDir .. "LAOZHU/comm/Timer.lua")
    dofile(gSDCardDir .. "LAOZHU/LuaUtils.lua")
    dofile(gSDCardDir .. "LAOZHU/F3k/F3kFlightRecord.lua")
    LZ_playFile = function () end
    LZ_playTime = function () end
    playTone = function () end
    local origRun = LZ_runModule
    local origErr = DBG_err
    local f3kRound = dofile(gSDCardDir .. "LAOZHU/F3kWF/F3kRoundWF.lua")
    f3kRound.init()
    local ok, err = pcall(fn, f3kRound)
    LZ_runModule = origRun
    DBG_err = origErr
    if not ok then
        error(err)
    end
end

function testF3kRoundReuseCommonTask()
    runRoundCase(function (f3kRound)
        local commonLoads = 0
        local orig = LZ_runModule
        LZ_runModule = function (file)
            if string.find(file, "CommonTaskWF.lua", 1, true) then
                commonLoads = commonLoads + 1
            end
            return orig(file)
        end
        local function expect(taskName, workTime, noflyTime, name)
            f3kRound.setRoundParam(120, 40, taskName, noflyTime)
            local task = f3kRound.getTask()
            luaunit.assertEquals(task.getTaskName(), name)
            luaunit.assertEquals(task.getWorkTime(), workTime)
            luaunit.assertEquals(task.getNoFlyTime(), noflyTime)
            luaunit.assertEquals(commonLoads, 1)
        end
        expect("Train", 600, 60, "Train")
        expect("TEST", 5, 5, "TEST")
        expect("LastFl", 420, 10, "LastFl")
        expect("Normal", 5999, 20, "Normal")
        expect("OtherTask", 600, 30, "Train")
        expect("-", 600, 15, "Train")
    end)
end

function testF3kRoundResetTaskOnSwitch()
    runRoundCase(function (f3kRound)
        f3kRound.setRoundParam(0, 0, "TEST", 5)
        local time = 10
        f3kRound.start(time)
        f3kRound.run(time)
        time = time + 500
        f3kRound.run(time)
        local task = f3kRound.getTask()
        luaunit.assertEquals(task.getState(), 2)
        task.addFlight(100, 50, time)
        local arr = task.getFlightRecord().flightArray
        luaunit.assertEquals(#arr, 1)

        f3kRound.setRoundParam(0, 0, "LastFl", 10)
        task = f3kRound.getTask()
        luaunit.assertEquals(f3kRound.getState(), 1)
        luaunit.assertEquals(task.getState(), 1)
        luaunit.assertEquals(task.getTaskName(), "LastFl")
        luaunit.assertEquals(task.getFlightRecord().flightArray, arr)
        luaunit.assertEquals(#arr, 0)
        luaunit.assertEquals(task.getFlightRecord().flightIndex, 0)
    end)
end

function testF3kRoundSwitchAuldAndTest()
    runRoundCase(function (f3kRound)
        f3kRound.setRoundParam(0, 0, "AULD", 60)
        luaunit.assertEquals(f3kRound.getTask().getTaskName(), "AULD")
        f3kRound.setRoundParam(0, 0, "TEST", 5)
        luaunit.assertEquals(f3kRound.getTask().getTaskName(), "TEST")
        luaunit.assertEquals(f3kRound.getTask().getWorkTime(), 5)
        f3kRound.setRoundParam(0, 0, "AULD", 60)
        luaunit.assertEquals(f3kRound.getTask().getTaskName(), "AULD")
        luaunit.assertEquals(f3kRound.getTask().getState(), 1)
    end)
end

function testF3kRoundNilLoadDoesNotIndexTask()
    runRoundCase(function (f3kRound)
        local orig = LZ_runModule
        LZ_runModule = function (file)
            if string.find(file, "AULDWF.lua", 1, true) then
                return nil
            end
            return orig(file)
        end
        DBG_err = function () end
        f3kRound.setRoundParam(0, 0, "Train", 60)
        luaunit.assertEquals(f3kRound.getTask().getTaskName(), "Train")
        f3kRound.setRoundParam(0, 0, "AULD", 60)
        luaunit.assertEquals(f3kRound.getTask().getTaskName(), "Train")
    end)
end

function testF3kRoundStopAndStart()
    dofile(gSDCardDir .. "LAOZHU/comm/Timer.lua")
    local f3kRound = dofile(gSDCardDir .. "LAOZHU/F3kWF/F3kRoundWF.lua")
    LZ_playFile = function (filepath)
    end

    LZ_playTime = function () end
    f3kRound.init()
    f3kRound.setRoundParam(120, 40, "TEST", 5)
    luaunit.assertEquals(f3kRound.getState(), 1) --begin
    local time = 10
    f3kRound.start(time)
    f3kRound.run(time)
    luaunit.assertEquals(f3kRound.getState(), 2) --operation
    time = time + 6000
    f3kRound.run(time)
    luaunit.assertEquals(f3kRound.getState(), 2) --operation
    time = time + 5990
    f3kRound.stop()
    luaunit.assertEquals(f3kRound.getState(), 1) --begin

    time = time + 10
    f3kRound.start(time)
    f3kRound.run(time)
    luaunit.assertEquals(f3kRound.getState(), 2) --operation
    time = time + 6000
    f3kRound.run(time)
    luaunit.assertEquals(f3kRound.getState(), 2) --operation
    time = time + 5990
    f3kRound.stop()
    luaunit.assertEquals(f3kRound.getState(), 1) --begin


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