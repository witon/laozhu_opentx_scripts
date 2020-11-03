HOME_DIR = os.getenv("HOME_DIR")
if not HOME_DIR then
    HOME_DIR = "./"
else
    HOME_DIR = HOME_DIR .. "/"
end

dofile(HOME_DIR .. "test/TestF3kFlightRecord.lua")
dofile(HOME_DIR .. "test/TestF3kState.lua")
dofile(HOME_DIR .. "test/TestF3kCfg.lua")
dofile(HOME_DIR .. "test/TestReadVar.lua")

EXPORT_ASSERT_TO_GLOBALS = true
luaunit = require("luaunit")
Mock = require "test.mock.Mock"
--Spy = require "test.mock.Spy"

os.exit(luaunit.LuaUnit.run())