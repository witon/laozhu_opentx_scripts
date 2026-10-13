local function loadMetric()
    return dofile(gSDCardDir .. "LAOZHU/SensorMetric.lua")
end

local function loadMonitor()
    local m = dofile(gSDCardDir .. "LAOZHU/Monitor.lua")
    m.init()
    return m
end

function testSpanEmpty()
    local Cls = loadMetric()
    local w = Cls:new("span", 6, 10)
    luaunit.assertEquals(w:read(0), 0)
end

function testSpanSingleSample()
    local Cls = loadMetric()
    local w = Cls:new("span", 6, 10)
    w:note(0, 4.2)
    luaunit.assertEquals(w:read(0), 0)
end

function testSpanSameBucket()
    local Cls = loadMetric()
    local w = Cls:new("span", 6, 10)
    w:note(0, 4.2)
    w:note(500, 3.9)
    w:note(900, 4.5)
    luaunit.assertAlmostEquals(w:read(900), 0.6, 0.0001)
end

function testSpanAcrossBuckets()
    local Cls = loadMetric()
    local w = Cls:new("span", 6, 10)
    w:note(0, 4.0)
    w:note(1000, 4.2)
    w:note(2500, 3.5)
    luaunit.assertAlmostEquals(w:read(2500), 0.7, 0.0001)
end

function testSpanDropsOldBucket()
    local Cls = loadMetric()
    local w = Cls:new("span", 6, 10)
    w:note(0, 3.0)
    w:note(1000, 4.0)
    luaunit.assertAlmostEquals(w:read(5900), 1.0, 0.0001)
    luaunit.assertEquals(w:read(6000), 0)
end

function testSpanIgnoresNonPositive()
    local Cls = loadMetric()
    local w = Cls:new("span", 6, 10)
    w:note(0, 0)
    w:note(100, -1)
    luaunit.assertEquals(w:read(200), 0)
    w:note(200, 4.2)
    luaunit.assertEquals(w:read(200), 0)
end

function testSpanSlotReuse()
    local Cls = loadMetric()
    local w = Cls:new("span", 6, 10)
    w:note(0, 2.0)
    w:note(6000, 4.0)
    w:note(6100, 4.2)
    luaunit.assertAlmostEquals(w:read(6100), 0.2, 0.0001)
end

function testSpanResetKeepsWindow()
    local Cls = loadMetric()
    local w = Cls:new("span", 6, 10)
    w:note(0, 4.0)
    w:note(100, 4.5)
    w:reset()
    luaunit.assertAlmostEquals(w:read(100), 0.5, 0.0001)
end

function testExtremumMaxAndReset()
    local Cls = loadMetric()
    local m = Cls:new("max")
    luaunit.assertEquals(m:read(), 0)
    m:note(0, 10)
    m:note(0, 25)
    m:note(0, 20)
    luaunit.assertEquals(m:read(), 25)
    m:reset()
    luaunit.assertEquals(m:read(), 0)
end

function testExtremumMinEmptyAndReset()
    local Cls = loadMetric()
    local m = Cls:new("min")
    luaunit.assertNil(m:read())
    m:note(0, 90)
    m:note(0, 70)
    m:note(0, 80)
    luaunit.assertEquals(m:read(), 70)
    m:reset()
    luaunit.assertNil(m:read())
end

function testMonitorTrackOffDoesNotRaisePeak()
    local m = loadMonitor()
    m.run(0, 4.0, 10, 90, false)
    m.run(100, 4.2, 30, 80, false)
    luaunit.assertEquals(m.tpwrMax(), 0)
    luaunit.assertEquals(m.lqMin(), 80)
    luaunit.assertAlmostEquals(m.rxSpan(100), 0.2, 0.0001)
end

function testMonitorResetTpwrKeepsLqMin()
    local m = loadMonitor()
    m.run(0, 4.0, 10, 100, true)
    m.run(100, 4.2, 25, 90, true)
    luaunit.assertEquals(m.tpwrMax(), 25)
    m.resetTpwr()
    luaunit.assertEquals(m.tpwrMax(), 0)
    luaunit.assertEquals(m.lqMin(), 90)
    m.run(200, 4.2, 15, 90, true)
    luaunit.assertEquals(m.tpwrMax(), 15)
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
