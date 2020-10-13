
if os.getenv("VSCODE_DEBUG") == "1" then
    EXPORT_ASSERT_TO_GLOBALS = true
    luaunit = require("luaunit")
    Mock = require "test.mock.Mock"
    luaunit.LuaUnit.run()
end

