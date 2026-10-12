local function loadWindow()
    return dofile(gSDCardDir .. "LAOZHU/3k/rxVoltWindow.lua")
end

function testRxVoltWindowEmpty()
    local w = loadWindow()
    luaunit.assertEquals(w.span(0), 0)
end

function testRxVoltWindowSingleSample()
    local w = loadWindow()
    w.note(0, 4.2)
    luaunit.assertEquals(w.span(0), 0)
end

function testRxVoltWindowSameBucket()
    local w = loadWindow()
    w.note(0, 4.2)
    w.note(500, 3.9)
    w.note(900, 4.5)
    luaunit.assertAlmostEquals(w.span(900), 0.6, 0.0001)
end

function testRxVoltWindowAcrossBuckets()
    local w = loadWindow()
    w.note(0, 4.0)
    w.note(1000, 4.2)
    w.note(2500, 3.5)
    luaunit.assertAlmostEquals(w.span(2500), 0.7, 0.0001)
end

function testRxVoltWindowDropsOldBucket()
    local w = loadWindow()
    w.note(0, 3.0)
    w.note(1000, 4.0)
    luaunit.assertAlmostEquals(w.span(5900), 1.0, 0.0001)
    luaunit.assertEquals(w.span(6000), 0)
end

function testRxVoltWindowIgnoresNonPositive()
    local w = loadWindow()
    w.note(0, 0)
    w.note(100, -1)
    luaunit.assertEquals(w.span(200), 0)
    w.note(200, 4.2)
    luaunit.assertEquals(w.span(200), 0)
end

function testRxVoltWindowSlotReuse()
    local w = loadWindow()
    w.note(0, 2.0)
    w.note(6000, 4.0)
    w.note(6100, 4.2)
    luaunit.assertAlmostEquals(w.span(6100), 0.2, 0.0001)
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
