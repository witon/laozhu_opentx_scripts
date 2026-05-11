LZ_TEST_HARNESS = true

HOME_DIR = os.getenv("HOME_DIR")
if not HOME_DIR then
    if io.open("test/test.lua", "r") then
        HOME_DIR = ""
    elseif io.open("../test/test.lua", "r") then
        HOME_DIR = "../"
    elseif io.open("SCRIPTS/test/test.lua", "r") then
        HOME_DIR = "SCRIPTS/"
    else
        HOME_DIR = "./"
    end
else
    HOME_DIR = HOME_DIR .. "/"
end

if not gSDCardDir then
    local fh = io.open("LAOZHU/Cfg.lua", "r")
    if fh then
        fh:close()
        gSDCardDir = "./"
    else
        fh = io.open("../LAOZHU/Cfg.lua", "r")
        if fh then
            fh:close()
            gSDCardDir = "../"
        else
            gSDCardDir = "./"
        end
    end
end

function LZ_runModule(file)
    return dofile(file)
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
dofile(HOME_DIR .. "test/TestKeyFramework.lua")
dofile(HOME_DIR .. "test/TestSensor.lua")
dofile(HOME_DIR .. "test/TestF3kRound.lua")
dofile(HOME_DIR .. "test/testF3kTask/TestCommonTask.lua")
dofile(HOME_DIR .. "test/TestF3kCompetitionWF.lua")








EXPORT_ASSERT_TO_GLOBALS = true
luaunit = require("luaunit")
Mock = require "test.mock.Mock"
local ValueMatcher = require "test.mock.ValueMatcher"
_G.any = ValueMatcher.any
--Spy = require "test.mock.Spy"

os.exit(luaunit.LuaUnit.run())
