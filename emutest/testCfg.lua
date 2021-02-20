
local function testCfgLM()
    dofile(gScriptDir .. "LAOZHU/Cfg.lua")
    local cfg1 = CFGnewCfg()
    local cfg2 = CFGnewCfg()

    cfg1.id = 1
    cfg1.name = "haha"
    CFGwriteToFile(cfg1, '3k')

    CFGreadFromFile(cfg2, '3k')
    assert(cfg2.id == 1, gAssertFlag)
    assert(cfg2.name == "haha", gAssertFlag)
end


return {testCfgLM}
