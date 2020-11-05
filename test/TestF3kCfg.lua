function testSetSwitchsAndRead()
    local f3kCfg = dofile(HOME_DIR .. "LAOZHU/F3kCfg.lua")
    f3kCfg.setVarSelectorSlider(1)
    f3kCfg.setVarReadSwitch(2)
    f3kCfg.setWorkTimeSwitch(3)

    local id = f3kCfg.getVarSelectorSlider()
    luaunit.assertEquals(id, 1)

    id, name = f3kCfg.getVarReadSwitch()
    luaunit.assertEquals(id, 2)

    id, name = f3kCfg.getWorkTimeSwitch()
    luaunit.assertEquals(id, 3)
end


HOME_DIR = os.getenv("HOME_DIR")
if not HOME_DIR then
    HOME_DIR = "./"
else
    HOME_DIR = HOME_DIR .. "/"
end
dofile(HOME_DIR .. "test/utils4Test.lua")