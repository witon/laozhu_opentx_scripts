function testNormalProcess()
    local curDateTime = 100000
    _G.getDateTime = Mock()
    _G.getDateTime:whenCalled {thenReturn = {curDateTime}}

    local F3kState = dofile(HOME_DIR .. "LAOZHU/F3kState.lua")
    F3kState.newFlight()
    local state = F3kState.getFlightState()
    luaunit.assertEquals(state, 0)
    local curTime = 10000
    F3kState.doFlightState(curTime, "preset")
    state = F3kState.getFlightState()
    luaunit.assertEquals(state, 0)

    curTime = 20000
    F3kState.doFlightState(curTime, "zoom")
    state = F3kState.getFlightState()
    luaunit.assertEquals(state, 1)
    luaunit.assertEquals(curTime, F3kState.getLaunchTime())
    luaunit.assertEquals(F3kState.getLaunchDateTime(), curDateTime)

    curTime = 30000
    F3kState.doFlightState(curTime, "zoom")
    luaunit.assertEquals(10000, F3kState.getFlightTime())

    curTime = 40000
    F3kState.doFlightState(curTime, "curise")
    state = F3kState.getFlightState()
    luaunit.assertEquals(2, state)
    luaunit.assertEquals(20000, F3kState.getFlightTime())

    curTime = 50000
    F3kState.doFlightState(curTime, "thermal")
    luaunit.assertEquals(2, F3kState.getFlightState())
    luaunit.assertEquals(30000, F3kState.getFlightTime())

    curTime = 60000
    F3kState.doFlightState(curTime, "preset")
    luaunit.assertEquals(3, F3kState.getFlightState())
    luaunit.assertEquals(40000, F3kState.getFlightTime())

    curTime = 70000
    F3kState.doFlightState(curTime, "zoom")
    luaunit.assertEquals(0, F3kState.getFlightState())
    luaunit.assertEquals(0, F3kState.getFlightTime())
end

function testPresetState_presetMode2CuriseMode() --"on preset state, from preset mode to curise mode"
    local curDateTime = 100000
    _G.getDateTime = Mock()
    _G.getDateTime:whenCalled {thenReturn = {curDateTime}}

    local F3kState = dofile(HOME_DIR .. "LAOZHU/F3kState.lua")
    F3kState.newFlight()
    local state = F3kState.getFlightState()
    luaunit.assertEquals(state, 0)
    local curTime = 10000
    F3kState.doFlightState(curTime, "cruise")
    luaunit.assertEquals(0, F3kState.getFlightState())
end

function testZoomState_zoomMode2PresetMode() --on zoom state, from zoom mode to preset mode
    local curDateTime = 100000
    _G.getDateTime = Mock()
    _G.getDateTime:whenCalled {thenReturn = {curDateTime}}

    local F3kState = dofile(HOME_DIR .. "LAOZHU/F3kState.lua")
    F3kState.newFlight()
    local state = F3kState.getFlightState()

    local curTime = 10000
    F3kState.doFlightState(curTime, "zoom")
    luaunit.assertEquals(1, F3kState.getFlightState())

    curTime = 20000
    F3kState.doFlightState(curTime, "preset")
    luaunit.assertEquals(0, F3kState.getFlightState())
end

function testLaunchedState_curiseMode2ZoomMode() --on launched state, from curise mode to zoom mode
    local curDateTime = 100000
    _G.getDateTime = Mock()
    _G.getDateTime:whenCalled {thenReturn = {curDateTime}}

    local F3kState = dofile(HOME_DIR .. "LAOZHU/F3kState.lua")
    F3kState.newFlight()

    local curTime = 10000
    F3kState.doFlightState(curTime, "zoom")
    luaunit.assertEquals(1, F3kState.getFlightState())

    curTime = 20000
    F3kState.doFlightState(curTime, "curise")
    luaunit.assertEquals(2, F3kState.getFlightState())

    curTime = 30000
    F3kState.doFlightState(curTime, "zoom")
    luaunit.assertEquals(2, F3kState.getFlightState())
end

function testLandedState_curiseMode2PresetMode() --on landed state, from curise mode to preset mode
    local curDateTime = 100000
    _G.getDateTime = Mock()
    _G.getDateTime:whenCalled {thenReturn = {curDateTime}}

    local F3kState = dofile(HOME_DIR .. "LAOZHU/F3kState.lua")
    F3kState.newFlight()
    local state = F3kState.getFlightState()

    local curTime = 10000
    F3kState.doFlightState(curTime, "zoom")
    luaunit.assertEquals(1, F3kState.getFlightState())

    curTime = 20000
    F3kState.doFlightState(curTime, "curise")
    luaunit.assertEquals(2, F3kState.getFlightState())

    curTime = 30000
    F3kState.doFlightState(curTime, "preset")
    luaunit.assertEquals(3, F3kState.getFlightState())

    curTime = 40000
    F3kState.doFlightState(curTime, "curise")
    luaunit.assertEquals(3, F3kState.getFlightState())

    curTime = 50000
    F3kState.doFlightState(curTime, "preset")
    luaunit.assertEquals(3, F3kState.getFlightState())
end

function testLaunchAlt() --launch alt
    local curDateTime = 100000
    _G.getDateTime = Mock()
    _G.getDateTime:whenCalled {thenReturn = {curDateTime}}

    local F3kState = dofile(HOME_DIR .. "LAOZHU/F3kState.lua")
    F3kState.newFlight()
    luaunit.assertEquals(0, F3kState.getLaunchAlt())

    local curTime = 10000
    F3kState.doFlightState(curTime, "zoom")
    luaunit.assertEquals(1, F3kState.getFlightState())

    curTime = 10010
    F3kState.setAlt(10)
    F3kState.doFlightState(curTime, "zoom")
    luaunit.assertEquals(10, F3kState.getLaunchAlt())

    curTime = 10015
    F3kState.setAlt(15)
    F3kState.doFlightState(curTime, "curise")
    luaunit.assertEquals(15, F3kState.getLaunchAlt())

    curTime = 10020
    F3kState.setAlt(20)
    F3kState.doFlightState(curTime, "curise")
    luaunit.assertEquals(20, F3kState.getLaunchAlt())

    curTime = 11000
    F3kState.setAlt(25)
    F3kState.doFlightState(curTime, "curise")
    luaunit.assertEquals(20, F3kState.getLaunchAlt())
end

HOME_DIR = os.getenv("HOME_DIR")
if not HOME_DIR then
    HOME_DIR = "."
end
dofile(HOME_DIR .. "/test/utils4Test.lua")