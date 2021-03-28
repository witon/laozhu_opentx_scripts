
local function testLoadModule()
    dofile(gScriptDir .. "TELEMETRY/common/LoadModule.lua")
    local fun = LZ_loadModule(gScriptDir .. "emutest/luaForTestLoadModule.lua")
    assert(fun)
    local luaForTestLoadModule = fun()
    assert(3 == luaForTestLoadModule.add(1, 2))
end


return {testLoadModule}
