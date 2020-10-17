function testAddFlightRecordsAndGet()
    local F3kFlightRecord = dofile(HOME_DIR .. "LAOZHU/F3kFlightRecord.lua")
    local flightTime = 1000
    local launchAlt = 50
    local flightStartTime = 10000
    local flightRecords = F3kFlightRecord.getFlightArray()
    luaunit.assertEquals(0, #flightRecords)

    F3kFlightRecord.addFlight(flightTime, launchAlt, flightStartTime)
    flightRecords = F3kFlightRecord.getFlightArray()
    luaunit.assertEquals(1, #flightRecords)
    record1 = flightRecords[1]
    luaunit.assertEquals(1000, record1.flightTime)
    luaunit.assertEquals(50, record1.launchAlt)
    luaunit.assertEquals(10000, record1.flightStartTime)

    flightTime = 1500
    launchAlt = 60
    flightStartTime = 20000
    F3kFlightRecord.addFlight(flightTime, launchAlt, flightStartTime)
    flightRecords = F3kFlightRecord.getFlightArray()
    luaunit.assertEquals(2, #flightRecords)
    record1 = flightRecords[2]
    luaunit.assertEquals(1500, record1.flightTime)
    luaunit.assertEquals(60, record1.launchAlt)
    luaunit.assertEquals(20000, record1.flightStartTime)
end

function testAddMoreThen25Flights()
    local F3kFlightRecord = dofile(HOME_DIR .. "LAOZHU/F3kFlightRecord.lua")
    local flightTime = 1000
    local launchAlt = 5
    local flightStartTime = 10000

    for i = 1, 27, 1 do
        F3kFlightRecord.addFlight(flightTime, launchAlt, flightStartTime)
        flightTime = flightTime + 1000
        launchAlt = launchAlt + 1
        flightStartTime = flightStartTime + 10000
    end

    flightRecords = F3kFlightRecord.getFlightArray()
    luaunit.assertEquals(25, #flightRecords)
    record1 = flightRecords[2]
    luaunit.assertEquals(27000, record1.flightTime)
    luaunit.assertEquals(31, record1.launchAlt)
    luaunit.assertEquals(270000, record1.flightStartTime)
end


HOME_DIR = os.getenv("HOME_DIR")
if not HOME_DIR then
    HOME_DIR = "./"
else
    HOME_DIR = HOME_DIR .. "/"
end
dofile(HOME_DIR .. "test/utils4Test.lua")