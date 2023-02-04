HOME_DIR = os.getenv("HOME_DIR")
if not HOME_DIR then
    HOME_DIR = "./"
else
    HOME_DIR = HOME_DIR .. "/"
end

dofile(HOME_DIR .. "test/TestF3kFlightRecord.lua")
dofile(HOME_DIR .. "test/TestF3kState.lua")
dofile(HOME_DIR .. "test/TestReadVar.lua")
dofile(HOME_DIR .. "test/TestF5jState.lua")
dofile(HOME_DIR .. "test/TestTimer.lua")
dofile(HOME_DIR .. "test/TestSwitchTrigeDetector.lua")
dofile(HOME_DIR .. "test/TestSinkRateState.lua")
dofile(HOME_DIR .. "test/TestLaozhuUtils.lua")
dofile(HOME_DIR .. "test/TestQueue.lua")
dofile(HOME_DIR .. "test/TestSensor.lua")
dofile(HOME_DIR .. "test/TestF3kRound.lua")
dofile(HOME_DIR .. "test/testF3kTask/TestCommonTask.lua")
dofile(HOME_DIR .. "test/TestF3kCompetitionWF.lua")

















EXPORT_ASSERT_TO_GLOBALS = true
luaunit = require("luaunit")
Mock = require "test.mock.Mock"
--Spy = require "test.mock.Spy"

os.exit(luaunit.LuaUnit.run())