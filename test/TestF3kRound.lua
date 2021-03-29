
function LZ_runModule(file)
    return dofile(file)
end

function testF3kRoundNormal()
    dofile(HOME_DIR .. "LAOZHU/Timer.lua")
    LZ_playFile = function (filepath)
    end
    local f3kRound = dofile(HOME_DIR .. "LAOZHU/F3k/F3kRound.lua")
    f3kRound.init()
    f3kRound.setRoundParam(120, 40, "Train")
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

    time = time + 6000
    f3kRound.run(time)
    luaunit.assertEquals(f3kRound.getState(), 4) --task time flight

    time = time + 60000
    f3kRound.run(time)
    luaunit.assertEquals(f3kRound.getState(), 4) --task time landing

    time = time + 3000
    f3kRound.run(time)
    luaunit.assertEquals(f3kRound.getState(), 5) --task time end -- round end


end

function testF3kRoundStopAndStart()
    dofile(HOME_DIR .. "LAOZHU/Timer.lua")
    local f3kRound = dofile(HOME_DIR .. "LAOZHU/F3k/F3kRound.lua")
    LZ_playFile = function (filepath)
    end
 
    f3kRound.init()
    f3kRound.setRoundParam(120, 40, "Train")
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


HOME_DIR = os.getenv("HOME_DIR")
if not HOME_DIR then
    HOME_DIR = "./"
else
    HOME_DIR = HOME_DIR .. "/"
end
dofile(HOME_DIR .. "test/utils4Test.lua")