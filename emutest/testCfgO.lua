
local function testCfg()
    dofile(gScriptDir .. "LAOZHU/CfgO.lua")
    local cfg1 = CFGC:new()
    local cfg2 = CFGC:new()

    cfg1.kvs.id = 1
    cfg1.kvs.name = "haha"
    CFGC:writeToFile('3k')

    CFGC:readFromFile('3k')
    assert(cfg2.kvs.id == 1, gAssertFlag)
    assert(cfg2.kvs.name == "haha", gAssertFlag)
end


return {testCfg}
