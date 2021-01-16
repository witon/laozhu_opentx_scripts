gScriptDir = HOME_DIR

function testMaxAlt()
    local flightStatic = dofile(HOME_DIR .. "LAOZHU/FlightStatic.lua")
    flightStatic.update(0, 0, 10)
    luaunit.assertEquals(10, flightStatic.getMaxAlt())
    flightStatic.update(0, 0, 9)
    luaunit.assertEquals(10, flightStatic.getMaxAlt())
    flightStatic.update(0, 0, 10)
    luaunit.assertEquals(10, flightStatic.getMaxAlt())
    flightStatic.update(0, 0, 10.1)
    luaunit.assertEquals(10.1, flightStatic.getMaxAlt())
    flightStatic.reset()
    luaunit.assertEquals(0, flightStatic.getMaxAlt())
end

function testMinRxVol()
    local flightStatic = dofile(HOME_DIR .. "LAOZHU/FlightStatic.lua")
    flightStatic.update(10, 0, 0)
    luaunit.assertEquals(10, flightStatic.getMinRxVol())
    flightStatic.update(1.1, 0, 0)
    luaunit.assertEquals(1.1, flightStatic.getMinRxVol())
    flightStatic.update(2, 0, 0)
    luaunit.assertEquals(1.1, flightStatic.getMinRxVol())
    flightStatic.reset()
    luaunit.assertEquals(10, flightStatic.getMinRxVol())
end

function testMinRssi()
    local flightStatic = dofile(HOME_DIR .. "LAOZHU/FlightStatic.lua")
    flightStatic.update(0, 50, 0)
    luaunit.assertEquals(50, flightStatic.getMinRssi())
    flightStatic.update(0, 40.2, 0)
    luaunit.assertEquals(40.2, flightStatic.getMinRssi())
    flightStatic.update(0, 60, 0)
    luaunit.assertEquals(40.2, flightStatic.getMinRssi())
    flightStatic.reset()
    luaunit.assertEquals(100, flightStatic.getMinRssi())
end

HOME_DIR = os.getenv("HOME_DIR")
if not HOME_DIR then
    HOME_DIR = "./"
else
    HOME_DIR = HOME_DIR .. "/"
end
dofile(HOME_DIR .. "test/utils4Test.lua")