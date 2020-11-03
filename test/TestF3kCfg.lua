function testSetSwitchsAndRead()
    local f3kCfg = dofile(HOME_DIR .. "LAOZHU/F3kCfg.lua")
    f3kCfg.setVarSelectorSlider(1, "slider1")
    f3kCfg.setVarReadSwitch(2, "varReadSwitch1")
    f3kCfg.setWorkTimeSwitch(3, "worktimeSwitch1")

    local id, name = f3kCfg.getVarSelectorSlider()
    luaunit.assertEquals(id, 1)
    luaunit.assertEquals(name, "slider1")

    id, name = f3kCfg.getVarReadSwitch()
    luaunit.assertEquals(id, 2)
    luaunit.assertEquals(name, "varReadSwitch1")

    id, name = f3kCfg.getWorkTimeSwitch()
    luaunit.assertEquals(id, 3)
    luaunit.assertEquals(name, "worktimeSwitch1")


end


HOME_DIR = os.getenv("HOME_DIR")
if not HOME_DIR then
    HOME_DIR = "./"
else
    HOME_DIR = HOME_DIR .. "/"
end
dofile(HOME_DIR .. "test/utils4Test.lua")