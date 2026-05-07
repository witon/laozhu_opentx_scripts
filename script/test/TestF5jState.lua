gScriptDir = HOME_DIR
function testNormalProcess()

    local curDateTime = 100000



    local f5jState = dofile(HOME_DIR .. "LAOZHU/F5jState.lua")

    LZ_playNumber = Mock()
    LZ_playNumber:whenCalled{with={any, 36}, thenReturn = {}}

    f5jState.setThrottleThreshold(-80)
    local state = f5jState.getFlightState()
    luaunit.assertEquals(state, 0)

    local curTime = 10000
    local resetSwitch = -1000
    local throttle = -1000
    local flightSwitch = -1000
    local curAlt = 10
    f5jState.setAlt(curAlt)
    f5jState.doFlightState(curTime, resetSwitch, throttle, flightSwitch)
    state = f5jState.getFlightState()
    luaunit.assertEquals(state, 0)


    curTime = 10001
    resetSwitch = -1000
    throttle = -700
    curAlt = 10
    flightSwitch = 1000

    f5jState.setAlt(curAlt)
    f5jState.doFlightState(curTime, resetSwitch, throttle, flightSwitch)
    state = f5jState.getFlightState()
    luaunit.assertEquals(state, 1)

    curTime = 10002
    resetSwitch = -1000
    throttle = -700
    curAlt = 20

    f5jState.setAlt(curAlt)
    f5jState.doFlightState(curTime, resetSwitch, throttle, flightSwitch)
    state = f5jState.getFlightState()
    local launchAlt = f5jState.getLaunchAlt()
    luaunit.assertEquals(state, 1)
    luaunit.assertEquals(launchAlt, 20)

    curTime = 10003
    resetSwitch = -1000
    throttle = -1000
    curAlt = 30

    f5jState.setAlt(curAlt)
    f5jState.doFlightState(curTime, resetSwitch, throttle, flightSwitch)
    state = f5jState.getFlightState()
    local launchAlt = f5jState.getLaunchAlt()
    luaunit.assertEquals(state, 2)
    luaunit.assertEquals(launchAlt, 30)

    curTime = 10102
    resetSwitch = -1000
    throttle = -1000
    curAlt = 50

    f5jState.setAlt(curAlt)
    f5jState.doFlightState(curTime, resetSwitch, throttle, flightSwitch)
    state = f5jState.getFlightState()
    local launchAlt = f5jState.getLaunchAlt()
    luaunit.assertEquals(state, 2)
    luaunit.assertEquals(launchAlt, 50)

    curTime = 11004
    resetSwitch = -1000
    throttle = -1000
    curAlt = 55

    LZ_playTime = Mock()
    LZ_playTime:whenCalled{with={any}, thenReturn={}}
 
    f5jState.setAlt(curAlt)
    f5jState.doFlightState(curTime, resetSwitch, throttle, flightSwitch)
    state = f5jState.getFlightState()
    local launchAlt = f5jState.getLaunchAlt()
    luaunit.assertEquals(state, 3)
    luaunit.assertEquals(launchAlt, 55)

    LZ_playNumber:assertAnyCallMatches{arguments={0, 0}}
    LZ_playNumber:assertCallCount(1)


    curTime = 11005
    resetSwitch = -1000
    throttle = -1000
    curAlt = 155
    flightSwitch = -1000

    f5jState.setAlt(curAlt)
    f5jState.doFlightState(curTime, resetSwitch, throttle, flightSwitch)
    state = f5jState.getFlightState()
    local launchAlt = f5jState.getLaunchAlt()
    luaunit.assertEquals(state, 4)
    luaunit.assertEquals(launchAlt, 55)
end


HOME_DIR = os.getenv("HOME_DIR")
if not HOME_DIR then
    HOME_DIR = "./"
else
    HOME_DIR = HOME_DIR .. "/"
end
dofile(HOME_DIR .. "test/utils4Test.lua")