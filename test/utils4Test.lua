
if os.getenv("VSCODE_DEBUG") == "1" then
    EXPORT_ASSERT_TO_GLOBALS = true
    luaunit = require("luaunit")
    Mock = require "test.mock.Mock"
    
    HOME_DIR = os.getenv("HOME_DIR")
    if not HOME_DIR then
        HOME_DIR = "./"
    end
    luaunit.LuaUnit.run()
end

