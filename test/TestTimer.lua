
function testTimerNormal()
    dofile(HOME_DIR .. "LAOZHU/OTUtils.lua")
    dofile(HOME_DIR .. "LAOZHU/LuaUtils.lua")
 
    dofile(HOME_DIR .. "LAOZHU/comm/Timer.lua")
    local timer = Timer:new()
 
    timer:resetTimer(100)
    local curTime = 10
    timer:setCurTime(curTime)
    timer:start()
    luaunit.assertEquals(timer:getRemainTime(), 100)
    luaunit.assertEquals(timer:getRunTime(), 0)

    curTime = 200
    timer:setCurTime(curTime)
    luaunit.assertEquals(timer:getRemainTime(), 99)
    luaunit.assertEquals(timer:getRunTime(), 1)
 
    curTime = 210
    timer:setCurTime(curTime)
    luaunit.assertEquals(timer:getRemainTime(), 98)
    luaunit.assertEquals(timer:getRunTime(), 2)
    timer:resetTimer(100)
    luaunit.assertEquals(timer:getRemainTime(), 100)
    luaunit.assertEquals(timer:getRunTime(), 0)

end

function testStop()
    dofile(HOME_DIR .. "LAOZHU/OTUtils.lua")
    dofile(HOME_DIR .. "LAOZHU/LuaUtils.lua")
 
    dofile(HOME_DIR .. "LAOZHU/comm/Timer.lua")
    local timer = Timer:new()
    timer:resetTimer(100)
    local curTime = 10
    timer:setCurTime(curTime)
    timer:start()

    luaunit.assertEquals(timer:getRemainTime(), 100)
    luaunit.assertEquals(timer:getRunTime(), 0)

    curTime = 200
    timer:setCurTime(curTime)

    luaunit.assertEquals(timer:getRemainTime(), 99)
    luaunit.assertEquals(timer:getRunTime(), 1)
 
    curTime = 210
    timer:setCurTime(curTime)
    luaunit.assertEquals(timer:getRemainTime(), 98)
    luaunit.assertEquals(timer:getRunTime(), 2)

    timer:stop()
    curTime = 510
    timer:setCurTime(curTime)
    luaunit.assertEquals(timer:getRemainTime(), 98)
    luaunit.assertEquals(timer:getRunTime(), 2)

end

function testReadRunTime30s()

    dofile(HOME_DIR .. "LAOZHU/OTUtils.lua")
    dofile(HOME_DIR .. "LAOZHU/LuaUtils.lua")
 
    dofile(HOME_DIR .. "LAOZHU/comm/Timer.lua")
    local timer = Timer:new()
    timer:resetTimer(120)
    local curTime = 10
    timer:setCurTime(curTime)
    timer:start()

    LZ_playTime = Mock()
    LZ_playTime:whenCalled{with={30}, thenReturn = {}}
    
    timer:readRunTime()
    LZ_playTime:assertCallCount(0)

    curTime = 3010
    timer:setCurTime(curTime)
    timer:readRunTime()
    LZ_playTime:assertAnyCallMatches{arguments={30}}
    LZ_playTime:assertCallCount(1)
end

function testReadRunTimeMultiIn1s()
    dofile(HOME_DIR .. "LAOZHU/OTUtils.lua")
    dofile(HOME_DIR .. "LAOZHU/LuaUtils.lua")
 
    dofile(HOME_DIR .. "LAOZHU/comm/OTSound.lua")
    dofile(HOME_DIR .. "LAOZHU/comm/Timer.lua")
    local timer = Timer:new()
    timer:resetTimer(120)
    local curTime = 10
    timer:setCurTime(curTime)
    timer:start()

    playNumber = Mock()
    playNumber:whenCalled{with={30, 37}, thenReturn = {}}
    
    timer:readRunTime()
    playNumber:assertCallCount(0)

    getTime = Mock()
    getTime:whenCalled{thenReturn={3010}}
    curTime = 3010
    timer:setCurTime(curTime)
    timer:readRunTime()
    playNumber:assertAnyCallMatches{arguments={30, 37}}
    playNumber:assertCallCount(1)
    curTime = 3030
    getTime:whenCalled{thenReturn={3030}}
    timer:setCurTime(curTime)
    timer:readRunTime()
    playNumber:assertCallCount(1)

end

function testReadRunTime60s()
    dofile(HOME_DIR .. "LAOZHU/OTUtils.lua")
    dofile(HOME_DIR .. "LAOZHU/LuaUtils.lua")
 
    dofile(HOME_DIR .. "LAOZHU/comm/Timer.lua")
 
    local timer = Timer:new()
    timer:resetTimer(120)
    local curTime = 10
    timer:setCurTime(curTime)
    timer:start()

    LZ_playTime = Mock()
    LZ_playTime:whenCalled{with={60}, thenReturn = {}}
    
    timer:readRunTime()
    LZ_playTime:assertCallCount(0)

    curTime = 6010
    timer:setCurTime(curTime)
    timer:readRunTime()
    LZ_playTime:assertAnyCallMatches{arguments={60}}
    LZ_playTime:assertCallCount(1)
end

function testReadRunTime90s()
    dofile(HOME_DIR .. "LAOZHU/OTUtils.lua")
    dofile(HOME_DIR .. "LAOZHU/LuaUtils.lua")
 
    dofile(HOME_DIR .. "LAOZHU/comm/Timer.lua")
 
    local timer = Timer:new()
    timer:resetTimer(120)
    local curTime = 10
    timer:setCurTime(curTime)
    timer:start()

    LZ_playTime = Mock()
    LZ_playTime:whenCalled{with={90}, thenReturn = {}}
    
    curTime = 9010
    timer:setCurTime(curTime)
    timer:readRunTime()
    LZ_playTime:assertAnyCallMatches{arguments={90}}
    LZ_playTime:assertCallCount(1)
end

function testReadRemainTime91s()
    dofile(HOME_DIR .. "LAOZHU/OTUtils.lua")
    dofile(HOME_DIR .. "LAOZHU/LuaUtils.lua")
 
    dofile(HOME_DIR .. "LAOZHU/comm/Timer.lua")
 
    local timer = Timer:new()
    timer:resetTimer(95)
    local curTime = 10
    timer:setCurTime(curTime)
    timer:start()

    LZ_playNumber = Mock()
    LZ_playNumber:whenCalled{with={1, 36}, thenReturn = {}}
    LZ_playNumber:whenCalled{with={30, 37}, thenReturn = {}}
    
    curTime = 410 
    timer:setCurTime(curTime)
    timer:readRemainTime()
    LZ_playNumber:assertCallCount(0)
end


function testReadRemainTime90s()
    dofile(HOME_DIR .. "LAOZHU/OTUtils.lua")
    dofile(HOME_DIR .. "LAOZHU/LuaUtils.lua")
 
    dofile(HOME_DIR .. "LAOZHU/comm/Timer.lua")
 
    local timer = Timer:new()
    timer:resetTimer(95)
    local curTime = 10
    timer:setCurTime(curTime)
    timer:start()

    LZ_playTime = Mock()
    LZ_playTime:whenCalled{with={90}, thenReturn = {}}
    
    curTime = 510 
    timer:setCurTime(curTime)
    timer:readRemainTime()
    LZ_playTime:assertAnyCallMatches{arguments={90}}
    LZ_playTime:assertCallCount(1)
end

function testReadRemainTime60s()
    dofile(HOME_DIR .. "LAOZHU/OTUtils.lua")
    dofile(HOME_DIR .. "LAOZHU/LuaUtils.lua")
 
    dofile(HOME_DIR .. "LAOZHU/comm/Timer.lua")
 
    local timer = Timer:new()
    timer:resetTimer(95)
    local curTime = 10
    timer:setCurTime(curTime)
    timer:start()

    LZ_playTime = Mock()
    LZ_playTime:whenCalled{with={60}, thenReturn = {}}
    
    curTime = 3510 
    timer:setCurTime(curTime)
    timer:readRemainTime()
    LZ_playTime:assertAnyCallMatches{arguments={60}}
    LZ_playTime:assertCallCount(1)
end

function testReadRemainTime30s()
    dofile(HOME_DIR .. "LAOZHU/OTUtils.lua")
    dofile(HOME_DIR .. "LAOZHU/LuaUtils.lua")
 
    dofile(HOME_DIR .. "LAOZHU/comm/Timer.lua")
 
    local timer = Timer:new()
    timer:resetTimer(95)
    local curTime = 10
    timer:setCurTime(curTime)
    timer:start()

    LZ_playTime = Mock()
    LZ_playTime:whenCalled{with={30}, thenReturn = {}}
    
    curTime = 6510 
    timer:setCurTime(curTime)
    timer:readRemainTime()
    LZ_playTime:assertAnyCallMatches{arguments={30}}
    LZ_playTime:assertCallCount(1)
end

function testDowncount()
    dofile(HOME_DIR .. "LAOZHU/OTUtils.lua")
    dofile(HOME_DIR .. "LAOZHU/LuaUtils.lua")
 
    dofile(HOME_DIR .. "LAOZHU/comm/Timer.lua")
 
    local timer = Timer:new()
    timer:resetTimer(95)
    local curTime = 10
    timer:setCurTime(curTime)
    timer:start()

    timer:setDowncount(21)

    LZ_playNumber = Mock()
    LZ_playNumber:whenCalled{with={any, 0}, thenReturn = {}}

    LZ_playTime = Mock()
    LZ_playTime:whenCalled{with={0}, thenReturn={0}}
    

    curTime = 7410 
    timer:setCurTime(curTime)
    timer:readRemainTime()
    LZ_playNumber:assertAnyCallMatches{arguments={21, 0}}
    LZ_playNumber:assertCallCount(1)

    curTime = 7610 
    timer:setCurTime(curTime)
    timer:readRemainTime()
    curTime = 7620

    timer:setCurTime(curTime)
    timer:readRemainTime()
    LZ_playNumber:assertAnyCallMatches{arguments={19, 0}}
    LZ_playNumber:assertCallCount(2)

    curTime = 9510 
    timer:setCurTime(curTime)
    timer:readRemainTime()
    LZ_playNumber:assertCallCount(3)


    curTime = 9610 
    timer:setCurTime(curTime)
    timer:readRemainTime()
    LZ_playNumber:assertCallCount(3)

end

function testForwardTimer()
    dofile(HOME_DIR .. "LAOZHU/OTUtils.lua")
    dofile(HOME_DIR .. "LAOZHU/LuaUtils.lua")
 
    dofile(HOME_DIR .. "LAOZHU/comm/Timer.lua")
 
    local timer = Timer:new()
    timer:resetTimer(65)
    local curTime = 10
    timer:setCurTime(curTime)
    timer:start()

    timer:setDowncount(10)

    LZ_playNumber = Mock()
    LZ_playNumber:whenCalled{with={any, 37}, thenReturn = {}}
    LZ_playNumber:whenCalled{with={any, 36}, thenReturn = {}}
    LZ_playNumber:whenCalled{with={any, 0}, thenReturn = {}}

    LZ_playTime = Mock()
    LZ_playTime:whenCalled{with={30}, thenReturn = {}}

   

    curTime = 3010 
    timer:setCurTime(curTime)
    timer:run()
    LZ_playTime:assertAnyCallMatches{argumets={30}}
    LZ_playTime:assertCallCount(1)

    curTime = 6010 
    timer:setCurTime(curTime)
    timer:run()
    LZ_playNumber:assertAnyCallMatches{arguments={5, 0}}
    LZ_playNumber:assertCallCount(1)

    curTime = 6110 
    timer:setCurTime(curTime)
    timer:run()
    LZ_playNumber:assertAnyCallMatches{arguments={4, 0}}
    LZ_playNumber:assertCallCount(2)
    curTime = 6610 
    timer:setCurTime(curTime)
    timer:run()
    LZ_playNumber:assertCallCount(2)

end

function testBackwardTimer()
    dofile(HOME_DIR .. "LAOZHU/OTUtils.lua")
    dofile(HOME_DIR .. "LAOZHU/LuaUtils.lua")
 
    dofile(HOME_DIR .. "LAOZHU/comm/Timer.lua")
 
    local timer = Timer:new()
    timer:resetTimer(65)
    local curTime = 10
    timer:setCurTime(curTime)
    timer:setForward(false)
    timer:start()

    timer:setDowncount(10)

    LZ_playNumber = Mock()
    LZ_playNumber:whenCalled{with={any, 0}, thenReturn = {}}
    LZ_playTime = Mock()
    LZ_playTime:whenCalled{with={30}, thenReturn={}}
    

    curTime = 3510 
    timer:setCurTime(curTime)
    timer:run()
    LZ_playTime:assertAnyCallMatches{arguments={30}}
    LZ_playTime:assertCallCount(1)

    curTime = 6110 
    timer:setCurTime(curTime)
    timer:run()
    LZ_playNumber:assertAnyCallMatches{arguments={4, 0}}
    LZ_playNumber:assertCallCount(1)
    curTime = 6610 
    timer:setCurTime(curTime)
    timer:run()
    LZ_playNumber:assertCallCount(1)

end

function testGetDuration()
    dofile(HOME_DIR .. "LAOZHU/OTUtils.lua")
    dofile(HOME_DIR .. "LAOZHU/LuaUtils.lua")
 
    dofile(HOME_DIR .. "LAOZHU/comm/Timer.lua")
 
    local timer = Timer:new()
    timer:resetTimer(65)
    local curTime = 10
    timer:setForward(false)
    timer:setCurTime(curTime)
    timer:setDowncount(10)

    LZ_playNumber = Mock()
    LZ_playNumber:whenCalled{with={any, 37}, thenReturn = {}}
    LZ_playNumber:whenCalled{with={any, 36}, thenReturn = {}}

    local duration = timer:getDuration()
    luaunit.assertEquals(duration, 0)

    timer:start()
    curTime = 1010
    timer:setCurTime(curTime)
    duration = timer:getDuration()
    luaunit.assertEquals(duration, 10)

    curTime = 3510 
    timer:setCurTime(curTime)
    timer:stop()
    duration = timer:getDuration()
    luaunit.assertEquals(duration, 35)
end

function testForwardAnnounce()
    dofile(HOME_DIR .. "LAOZHU/OTUtils.lua")
    dofile(HOME_DIR .. "LAOZHU/LuaUtils.lua")
 
    dofile(HOME_DIR .. "LAOZHU/comm/Timer.lua")

    local haveDoneCallback = false

    local function announceCallback(t)
        haveDoneCallback = true
    end
 
    local timer = Timer:new()
    timer:resetTimer(0)
    local curTime = 10
    timer:setForward(true)
    timer:setCurTime(curTime)
    timer.announceTime = 10
    timer.announceCallback = announceCallback
    timer:start()

    curTime = 910
    timer:setCurTime(curTime)
    timer:run()
    luaunit.assertFalse(haveDoneCallback)

    curTime = 1010
    timer:setCurTime(curTime)
    timer:run()
    luaunit.assertTrue(haveDoneCallback)
end

function testBackwardAnnounce()
    dofile(HOME_DIR .. "LAOZHU/OTUtils.lua")
    dofile(HOME_DIR .. "LAOZHU/LuaUtils.lua")
 
    dofile(HOME_DIR .. "LAOZHU/comm/Timer.lua")

    local haveDoneCallback = false

    local function announceCallback(t)
        haveDoneCallback = true
    end
 
    local timer = Timer:new()
    timer:resetTimer(10)
    local curTime = 10
    timer:setForward(false)
    timer:setCurTime(curTime)
    timer.announceTime = 3
    timer.announceCallback = announceCallback
    timer:start()

    curTime = 110
    timer:setCurTime(curTime)
    timer:run()
    luaunit.assertFalse(haveDoneCallback)

    curTime = 710
    timer:setCurTime(curTime)
    timer:run()
    luaunit.assertTrue(haveDoneCallback)
end


HOME_DIR = os.getenv("HOME_DIR")
if not HOME_DIR then
    HOME_DIR = "./"
else
    HOME_DIR = HOME_DIR .. "/"
end
dofile(HOME_DIR .. "test/utils4Test.lua")