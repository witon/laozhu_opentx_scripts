gScriptDir = HOME_DIR
function testNormalProcess()
    local curDateTime = 100000
    _G.getDateTime = Mock()
    _G.getDateTime:whenCalled {thenReturn = {curDateTime}}

    local F3kState = dofile(HOME_DIR .. "LAOZHU/F3k/F3kState.lua")
    F3kState.newFlight()
    local state = F3kState.getFlightState()
    luaunit.assertEquals(state, 0)
    local curTime = 10000
    local curRtcTime = 100000
    F3kState.doFlightState(curTime, "preset", curRtcTime)
    state = F3kState.getFlightState()
    luaunit.assertEquals(state, 0)

    curTime = 20000
    F3kState.doFlightState(curTime, "zoom", curRtcTime)
    state = F3kState.getFlightState()
    luaunit.assertEquals(state, 1)
    luaunit.assertEquals(curTime, F3kState.launchTime)
    luaunit.assertEquals(F3kState.launchRtcTime, curRtcTime)

    curTime = 30000
    F3kState.doFlightState(curTime, "zoom", curRtcTime)
    luaunit.assertEquals(10000, F3kState.getFlightTime())

    curTime = 40000
    F3kState.doFlightState(curTime, "curise", curRtcTime)
    state = F3kState.getFlightState()
    luaunit.assertEquals(2, state)
    luaunit.assertEquals(20000, F3kState.getFlightTime())

    curTime = 50000
    F3kState.doFlightState(curTime, "thermal", curRtcTime)
    luaunit.assertEquals(2, F3kState.getFlightState())
    luaunit.assertEquals(30000, F3kState.getFlightTime())

    curTime = 60000
    F3kState.doFlightState(curTime, "preset", curRtcTime)
    luaunit.assertEquals(3, F3kState.getFlightState())
    luaunit.assertEquals(F3kState.getFlightTime(), 40000)
    
    local flightArray = F3kState.getFlightRecord().getFlightArray()
    local flight = flightArray[1]
    luaunit.assertEquals(flight.flightTime, 40000)
    luaunit.assertEquals(flight.flightStartTime, 100000)
    
    curTime = 70000
    F3kState.doFlightState(curTime, "zoom", curRtcTime)
    luaunit.assertEquals(0, F3kState.getFlightState())
    luaunit.assertEquals(0, F3kState.getFlightTime())
end

function testPresetState_presetMode2CuriseMode() --"on preset state, from preset mode to curise mode"
    local curDateTime = 100000
    _G.getDateTime = Mock()
    _G.getDateTime:whenCalled {thenReturn = {curDateTime}}

    local F3kState = dofile(HOME_DIR .. "LAOZHU/F3k/F3kState.lua")
    F3kState.newFlight()
    local state = F3kState.getFlightState()
    luaunit.assertEquals(state, 0)
    local curTime = 10000
    local curRtcTime = 10000
    F3kState.doFlightState(curTime, "cruise", curRtcTime)
    luaunit.assertEquals(0, F3kState.getFlightState())
end

function testZoomState_zoomMode2PresetMode() --on zoom state, from zoom mode to preset mode
    local curDateTime = 100000
    _G.getDateTime = Mock()
    _G.getDateTime:whenCalled {thenReturn = {curDateTime}}

    local F3kState = dofile(HOME_DIR .. "LAOZHU/F3k/F3kState.lua")
    F3kState.newFlight()
    local state = F3kState.getFlightState()

    local curTime = 10000
    local curRtcTime = 100000
 
    F3kState.doFlightState(curTime, "zoom", curRtcTime)
    luaunit.assertEquals(1, F3kState.getFlightState())

    curTime = 20000
    F3kState.doFlightState(curTime, "preset", curRtcTime)
    luaunit.assertEquals(0, F3kState.getFlightState())
end

function testLaunchedState_curiseMode2ZoomMode() --on launched state, from curise mode to zoom mode
    local curDateTime = 100000
    _G.getDateTime = Mock()
    _G.getDateTime:whenCalled {thenReturn = {curDateTime}}

    local F3kState = dofile(HOME_DIR .. "LAOZHU/F3k/F3kState.lua")
    F3kState.newFlight()

    local curTime = 10000
    local curRtcTime = 100000
    F3kState.doFlightState(curTime, "zoom", curRtcTime)
    luaunit.assertEquals(1, F3kState.getFlightState())

    curTime = 20000
    F3kState.doFlightState(curTime, "curise", curRtcTime)
    luaunit.assertEquals(2, F3kState.getFlightState())

    curTime = 30000
    F3kState.doFlightState(curTime, "zoom", curRtcTime)
    luaunit.assertEquals(2, F3kState.getFlightState())
end

function testLandedState_curiseMode2PresetMode() --on landed state, from curise mode to preset mode
    local curDateTime = 100000
    _G.getDateTime = Mock()
    _G.getDateTime:whenCalled {thenReturn = {curDateTime}}

    local F3kState = dofile(HOME_DIR .. "LAOZHU/F3k/F3kState.lua")
    F3kState.newFlight()
    local state = F3kState.getFlightState()

    local curTime = 10000
    local curRtcTime = 100000
    F3kState.doFlightState(curTime, "zoom", curRtcTime)
    luaunit.assertEquals(1, F3kState.getFlightState())

    curTime = 20000
    F3kState.doFlightState(curTime, "curise", curRtcTime)
    luaunit.assertEquals(2, F3kState.getFlightState())

    curTime = 30000
    F3kState.doFlightState(curTime, "preset", curRtcTime)
    luaunit.assertEquals(3, F3kState.getFlightState())

    curTime = 40000
    F3kState.doFlightState(curTime, "curise", curRtcTime)
    luaunit.assertEquals(3, F3kState.getFlightState())

    curTime = 50000
    F3kState.doFlightState(curTime, "preset", curRtcTime)
    luaunit.assertEquals(3, F3kState.getFlightState())
end

function testLaunchAlt() --launch alt
    local curDateTime = 100000
    _G.getDateTime = Mock()
    _G.getDateTime:whenCalled {thenReturn = {curDateTime}}

    local F3kState = dofile(HOME_DIR .. "LAOZHU/F3k/F3kState.lua")
    F3kState.newFlight()
    luaunit.assertEquals(0, F3kState.launchAlt)

    local curTime = 10000
    local curRtcTime = 100000
    F3kState.doFlightState(curTime, "zoom", curRtcTime)
    luaunit.assertEquals(1, F3kState.getFlightState())

    curTime = 10010
    F3kState.curAlt = 10
    F3kState.doFlightState(curTime, "zoom", curRtcTime)
    luaunit.assertEquals(10, F3kState.launchAlt)

    curTime = 10015
    F3kState.curAlt = 15
    F3kState.doFlightState(curTime, "curise", curRtcTime)
    luaunit.assertEquals(15, F3kState.launchAlt)

    curTime = 10020
    F3kState.curAlt = 20
    F3kState.doFlightState(curTime, "curise", curRtcTime)
    luaunit.assertEquals(20, F3kState.launchAlt)

    curTime = 11000
    F3kState.curAlt = 25
    F3kState.doFlightState(curTime, "curise", curRtcTime)
    luaunit.assertEquals(20, F3kState.launchAlt)
end

function testSetAndGetDestFlightTime()
    local F3kState = dofile(HOME_DIR .. "LAOZHU/F3k/F3kState.lua")
    F3kState.newFlight()
    F3kState.setDestFlightTime(10)
    local destFlightTime = F3kState.destFlightTime
    luaunit.assertEquals(10, destFlightTime)
end

HOME_DIR = os.getenv("HOME_DIR")
if not HOME_DIR then
    HOME_DIR = "./"
else
    HOME_DIR = HOME_DIR .. "/"
end
dofile(HOME_DIR .. "test/utils4Test.lua")