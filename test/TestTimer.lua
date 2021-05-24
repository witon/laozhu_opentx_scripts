
function testTimerNormal()
    dofile(HOME_DIR .. "LAOZHU/OTUtils.lua")
    dofile(HOME_DIR .. "LAOZHU/LuaUtils.lua")
 
    dofile(HOME_DIR .. "LAOZHU/comm/Timer.lua")
    local timer = Timer_new()
    Timer_resetTimer(timer, 100)
    local curTime = 10
    Timer_setCurTime(timer, curTime)
    Timer_start(timer)
    luaunit.assertEquals(Timer_getRemainTime(timer), 100)
    luaunit.assertEquals(Timer_getRunTime(timer), 0)

    curTime = 200
    Timer_setCurTime(timer, curTime)
    luaunit.assertEquals(Timer_getRemainTime(timer), 99)
    luaunit.assertEquals(Timer_getRunTime(timer), 1)
 
    curTime = 210
    Timer_setCurTime(timer, curTime)
    luaunit.assertEquals(Timer_getRemainTime(timer), 98)
    luaunit.assertEquals(Timer_getRunTime(timer), 2)
    Timer_resetTimer(timer, 100)
    luaunit.assertEquals(Timer_getRemainTime(timer), 100)
    luaunit.assertEquals(Timer_getRunTime(timer), 0)

end

function testStop()
    dofile(HOME_DIR .. "LAOZHU/OTUtils.lua")
    dofile(HOME_DIR .. "LAOZHU/LuaUtils.lua")
 
    dofile(HOME_DIR .. "LAOZHU/comm/Timer.lua")
    local timer = Timer_new()
    Timer_resetTimer(timer, 100)
    local curTime = 10
    Timer_setCurTime(timer, curTime)
    Timer_start(timer)

    luaunit.assertEquals(Timer_getRemainTime(timer), 100)
    luaunit.assertEquals(Timer_getRunTime(timer), 0)

    curTime = 200
    Timer_setCurTime(timer, curTime)

    luaunit.assertEquals(Timer_getRemainTime(timer), 99)
    luaunit.assertEquals(Timer_getRunTime(timer), 1)
 
    curTime = 210
    Timer_setCurTime(timer, curTime)
    luaunit.assertEquals(Timer_getRemainTime(timer), 98)
    luaunit.assertEquals(Timer_getRunTime(timer), 2)

    Timer_stop(timer)
    curTime = 510
    Timer_setCurTime(timer, curTime)
    luaunit.assertEquals(Timer_getRemainTime(timer), 98)
    luaunit.assertEquals(Timer_getRunTime(timer), 2)

end

function testReadRunTime30s()

    dofile(HOME_DIR .. "LAOZHU/OTUtils.lua")
    dofile(HOME_DIR .. "LAOZHU/LuaUtils.lua")
 
    dofile(HOME_DIR .. "LAOZHU/comm/Timer.lua")
    local timer = Timer_new()
    Timer_resetTimer(timer, 120)
    local curTime = 10
    Timer_setCurTime(timer, curTime)
    Timer_start(timer)

    LZ_playTime = Mock()
    LZ_playTime:whenCalled{with={30}, thenReturn = {}}
    
    Timer_readRunTime(timer)
    LZ_playTime:assertCallCount(0)

    curTime = 3010
    Timer_setCurTime(timer, curTime)
    Timer_readRunTime(timer)
    LZ_playTime:assertAnyCallMatches{arguments={30}}
    LZ_playTime:assertCallCount(1)
end

function testReadRunTimeMultiIn1s()
    dofile(HOME_DIR .. "LAOZHU/OTUtils.lua")
    dofile(HOME_DIR .. "LAOZHU/LuaUtils.lua")
 
    dofile(HOME_DIR .. "LAOZHU/comm/OTSound.lua")
    dofile(HOME_DIR .. "LAOZHU/comm/Timer.lua")
    local timer = Timer_new()
    Timer_resetTimer(timer, 120)
    local curTime = 10
    Timer_setCurTime(timer, curTime)
    Timer_start(timer)

    playNumber = Mock()
    playNumber:whenCalled{with={30, 37}, thenReturn = {}}
    
    Timer_readRunTime(timer)
    playNumber:assertCallCount(0)

    getTime = Mock()
    getTime:whenCalled{thenReturn={3010}}
    curTime = 3010
    Timer_setCurTime(timer, curTime)
    Timer_readRunTime(timer)
    playNumber:assertAnyCallMatches{arguments={30, 37}}
    playNumber:assertCallCount(1)
    curTime = 3030
    getTime:whenCalled{thenReturn={3030}}
    Timer_setCurTime(timer, curTime)
    Timer_readRunTime(timer)
    playNumber:assertCallCount(1)

end

function testReadRunTime60s()
    dofile(HOME_DIR .. "LAOZHU/OTUtils.lua")
    dofile(HOME_DIR .. "LAOZHU/LuaUtils.lua")
 
    dofile(HOME_DIR .. "LAOZHU/comm/Timer.lua")
 
    local timer = Timer_new()
    Timer_resetTimer(timer, 120)
    local curTime = 10
    Timer_setCurTime(timer, curTime)
    Timer_start(timer)

    LZ_playTime = Mock()
    LZ_playTime:whenCalled{with={60}, thenReturn = {}}
    
    Timer_readRunTime(timer)
    LZ_playTime:assertCallCount(0)

    curTime = 6010
    Timer_setCurTime(timer, curTime)
    Timer_readRunTime(timer)
    LZ_playTime:assertAnyCallMatches{arguments={60}}
    LZ_playTime:assertCallCount(1)
end

function testReadRunTime90s()
    dofile(HOME_DIR .. "LAOZHU/OTUtils.lua")
    dofile(HOME_DIR .. "LAOZHU/LuaUtils.lua")
 
    dofile(HOME_DIR .. "LAOZHU/comm/Timer.lua")
 
    local timer = Timer_new()
    Timer_resetTimer(timer, 120)
    local curTime = 10
    Timer_setCurTime(timer, curTime)
    Timer_start(timer)

    LZ_playTime = Mock()
    LZ_playTime:whenCalled{with={90}, thenReturn = {}}
    
    curTime = 9010
    Timer_setCurTime(timer, curTime)
    Timer_readRunTime(timer)
    LZ_playTime:assertAnyCallMatches{arguments={90}}
    LZ_playTime:assertCallCount(1)
end

function testReadRemainTime91s()
    dofile(HOME_DIR .. "LAOZHU/OTUtils.lua")
    dofile(HOME_DIR .. "LAOZHU/LuaUtils.lua")
 
    dofile(HOME_DIR .. "LAOZHU/comm/Timer.lua")
 
    local timer = Timer_new()
    Timer_resetTimer(timer, 95)
    local curTime = 10
    Timer_setCurTime(timer, curTime)
    Timer_start(timer)

    LZ_playNumber = Mock()
    LZ_playNumber:whenCalled{with={1, 36}, thenReturn = {}}
    LZ_playNumber:whenCalled{with={30, 37}, thenReturn = {}}
    
    curTime = 410 
    Timer_setCurTime(timer, curTime)
    Timer_readRemainTime(timer)
    LZ_playNumber:assertCallCount(0)
end


function testReadRemainTime90s()
    dofile(HOME_DIR .. "LAOZHU/OTUtils.lua")
    dofile(HOME_DIR .. "LAOZHU/LuaUtils.lua")
 
    dofile(HOME_DIR .. "LAOZHU/comm/Timer.lua")
 
    local timer = Timer_new()
    Timer_resetTimer(timer, 95)
    local curTime = 10
    Timer_setCurTime(timer, curTime)
    Timer_start(timer)

    LZ_playTime = Mock()
    LZ_playTime:whenCalled{with={90}, thenReturn = {}}
    
    curTime = 510 
    Timer_setCurTime(timer, curTime)
    Timer_readRemainTime(timer)
    LZ_playTime:assertAnyCallMatches{arguments={90}}
    LZ_playTime:assertCallCount(1)
end

function testReadRemainTime60s()
    dofile(HOME_DIR .. "LAOZHU/OTUtils.lua")
    dofile(HOME_DIR .. "LAOZHU/LuaUtils.lua")
 
    dofile(HOME_DIR .. "LAOZHU/comm/Timer.lua")
 
    local timer = Timer_new()
    Timer_resetTimer(timer, 95)
    local curTime = 10
    Timer_setCurTime(timer, curTime)
    Timer_start(timer)

    LZ_playTime = Mock()
    LZ_playTime:whenCalled{with={60}, thenReturn = {}}
    
    curTime = 3510 
    Timer_setCurTime(timer, curTime)
    Timer_readRemainTime(timer)
    LZ_playTime:assertAnyCallMatches{arguments={60}}
    LZ_playTime:assertCallCount(1)
end

function testReadRemainTime30s()
    dofile(HOME_DIR .. "LAOZHU/OTUtils.lua")
    dofile(HOME_DIR .. "LAOZHU/LuaUtils.lua")
 
    dofile(HOME_DIR .. "LAOZHU/comm/Timer.lua")
 
    local timer = Timer_new()
    Timer_resetTimer(timer, 95)
    local curTime = 10
    Timer_setCurTime(timer, curTime)
    Timer_start(timer)

    LZ_playTime = Mock()
    LZ_playTime:whenCalled{with={30}, thenReturn = {}}
    
    curTime = 6510 
    Timer_setCurTime(timer, curTime)
    Timer_readRemainTime(timer)
    LZ_playTime:assertAnyCallMatches{arguments={30}}
    LZ_playTime:assertCallCount(1)
end

function testDowncount()
    dofile(HOME_DIR .. "LAOZHU/OTUtils.lua")
    dofile(HOME_DIR .. "LAOZHU/LuaUtils.lua")
 
    dofile(HOME_DIR .. "LAOZHU/comm/Timer.lua")
 
    local timer = Timer_new()
    Timer_resetTimer(timer, 95)
    local curTime = 10
    Timer_setCurTime(timer, curTime)
    Timer_start(timer)

    Timer_setDowncount(timer, 21)

    LZ_playNumber = Mock()
    LZ_playNumber:whenCalled{with={any, 0}, thenReturn = {}}

    LZ_playTime = Mock()
    LZ_playTime:whenCalled{with={0}, thenReturn={0}}
    

    curTime = 7410 
    Timer_setCurTime(timer, curTime)
    Timer_readRemainTime(timer)
    LZ_playNumber:assertAnyCallMatches{arguments={21, 0}}
    LZ_playNumber:assertCallCount(1)

    curTime = 7610 
    Timer_setCurTime(timer, curTime)
    Timer_readRemainTime(timer)
    curTime = 7620

    Timer_setCurTime(timer, curTime)
    Timer_readRemainTime(timer)
    LZ_playNumber:assertAnyCallMatches{arguments={19, 0}}
    LZ_playNumber:assertCallCount(2)

    curTime = 9510 
    Timer_setCurTime(timer, curTime)
    Timer_readRemainTime(timer)
    LZ_playNumber:assertCallCount(3)


    curTime = 9610 
    Timer_setCurTime(timer, curTime)
    Timer_readRemainTime(timer)
    LZ_playNumber:assertCallCount(3)

end

function testForwardTimer()
    dofile(HOME_DIR .. "LAOZHU/OTUtils.lua")
    dofile(HOME_DIR .. "LAOZHU/LuaUtils.lua")
 
    dofile(HOME_DIR .. "LAOZHU/comm/Timer.lua")
 
    local timer = Timer_new()
    Timer_resetTimer(timer, 65)
    local curTime = 10
    Timer_setCurTime(timer, curTime)
    Timer_start(timer)

    Timer_setDowncount(timer, 10)

    LZ_playNumber = Mock()
    LZ_playNumber:whenCalled{with={any, 37}, thenReturn = {}}
    LZ_playNumber:whenCalled{with={any, 36}, thenReturn = {}}
    LZ_playNumber:whenCalled{with={any, 0}, thenReturn = {}}

    LZ_playTime = Mock()
    LZ_playTime:whenCalled{with={30}, thenReturn = {}}

   

    curTime = 3010 
    Timer_setCurTime(timer, curTime)
    Timer_run(timer)
    LZ_playTime:assertAnyCallMatches{argumets={30}}
    LZ_playTime:assertCallCount(1)

    curTime = 6010 
    Timer_setCurTime(timer, curTime)
    Timer_run(timer)
    LZ_playNumber:assertAnyCallMatches{arguments={5, 0}}
    LZ_playNumber:assertCallCount(1)

    curTime = 6110 
    Timer_setCurTime(timer, curTime)
    Timer_run(timer)
    LZ_playNumber:assertAnyCallMatches{arguments={4, 0}}
    LZ_playNumber:assertCallCount(2)
    curTime = 6610 
    Timer_setCurTime(timer, curTime)
    Timer_run(timer)
    LZ_playNumber:assertCallCount(2)

end

function testBackwardTimer()
    dofile(HOME_DIR .. "LAOZHU/OTUtils.lua")
    dofile(HOME_DIR .. "LAOZHU/LuaUtils.lua")
 
    dofile(HOME_DIR .. "LAOZHU/comm/Timer.lua")
 
    local timer = Timer_new()
    Timer_resetTimer(timer, 65)
    local curTime = 10
    Timer_setCurTime(timer, curTime)
    Timer_setForward(timer, false)
    Timer_start(timer)

    Timer_setDowncount(timer, 10)

    LZ_playNumber = Mock()
    LZ_playNumber:whenCalled{with={any, 0}, thenReturn = {}}
    LZ_playTime = Mock()
    LZ_playTime:whenCalled{with={30}, thenReturn={}}
    

    curTime = 3510 
    Timer_setCurTime(timer, curTime)
    Timer_run(timer)
    LZ_playTime:assertAnyCallMatches{arguments={30}}
    LZ_playTime:assertCallCount(1)

    curTime = 6110 
    Timer_setCurTime(timer, curTime)
    Timer_run(timer)
    LZ_playNumber:assertAnyCallMatches{arguments={4, 0}}
    LZ_playNumber:assertCallCount(1)
    curTime = 6610 
    Timer_setCurTime(timer, curTime)
    Timer_run(timer)
    LZ_playNumber:assertCallCount(1)

end

function testGetDuration()
    dofile(HOME_DIR .. "LAOZHU/OTUtils.lua")
    dofile(HOME_DIR .. "LAOZHU/LuaUtils.lua")
 
    dofile(HOME_DIR .. "LAOZHU/comm/Timer.lua")
 
    local timer = Timer_new()
    Timer_resetTimer(timer, 65)
    local curTime = 10
    Timer_setForward(timer, false)
    Timer_setCurTime(timer, curTime)
    Timer_setDowncount(timer, 10)

    LZ_playNumber = Mock()
    LZ_playNumber:whenCalled{with={any, 37}, thenReturn = {}}
    LZ_playNumber:whenCalled{with={any, 36}, thenReturn = {}}

    local duration = Timer_getDuration(timer)
    luaunit.assertEquals(duration, 0)

    Timer_start(timer)
    curTime = 1010
    Timer_setCurTime(timer, curTime)
    duration = Timer_getDuration(timer)
    luaunit.assertEquals(duration, 10)

    curTime = 3510 
    Timer_setCurTime(timer, curTime)
    Timer_stop(timer)
    duration = Timer_getDuration(timer)
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
 
    local timer = Timer_new()
    Timer_resetTimer(timer, 0)
    local curTime = 10
    Timer_setForward(timer, true)
    Timer_setCurTime(timer, curTime)
    timer.announceTime = 10
    timer.announceCallback = announceCallback
    Timer_start(timer)

    curTime = 910
    Timer_setCurTime(timer, curTime)
    Timer_run(timer)
    luaunit.assertFalse(haveDoneCallback)

    curTime = 1010
    Timer_setCurTime(timer, curTime)
    Timer_run(timer)
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
 
    local timer = Timer_new()
    Timer_resetTimer(timer, 10)
    local curTime = 10
    Timer_setForward(timer, false)
    Timer_setCurTime(timer, curTime)
    timer.announceTime = 3
    timer.announceCallback = announceCallback
    Timer_start(timer)

    curTime = 110
    Timer_setCurTime(timer, curTime)
    Timer_run(timer)
    luaunit.assertFalse(haveDoneCallback)

    curTime = 710
    Timer_setCurTime(timer, curTime)
    Timer_run(timer)
    luaunit.assertTrue(haveDoneCallback)
end


HOME_DIR = os.getenv("HOME_DIR")
if not HOME_DIR then
    HOME_DIR = "./"
else
    HOME_DIR = HOME_DIR .. "/"
end
dofile(HOME_DIR .. "test/utils4Test.lua")