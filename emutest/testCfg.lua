
local function testCfg()
    local cfg1 = dofile(gScriptDir .. "LAOZHU/Cfg.lua")
    local cfg2 = dofile(gScriptDir .. "LAOZHU/Cfg.lua")

    local cfgs = cfg1.getCfgs()
    cfgs.id = 1
    cfgs.name = "haha"
    cfg1.writeToFile('3k')

    cfgs = {}
    cfg2.readFromFile('3k')
    cfgs = cfg2.getCfgs()
    assert(cfgs.id == 1, gAssertFlag)
    assert(cfgs.name == "haha", gAssertFlag)
end


return {testCfg}
