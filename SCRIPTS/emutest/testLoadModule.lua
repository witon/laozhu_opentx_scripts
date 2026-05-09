
local function testLoadModule()
    if not gSDCardDir then
        gSDCardDir = "/"
    end
    dofile(gSDCardDir .. "LAOZHU/uilib/LoadModule.lua")
    local fun = LZ_loadModule(gSDCardDir .. "SCRIPTS/emutest/luaForTestLoadModule.lua")
    assert(fun)
    local luaForTestLoadModule = fun()
    assert(3 == luaForTestLoadModule.add(1, 2))
end


return {testLoadModule}
