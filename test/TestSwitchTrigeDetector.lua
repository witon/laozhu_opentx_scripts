function testSwitchTrigeDetector()
    dofile(HOME_DIR .. "LAOZHU/SwitchTrigeDetector.lua")
    local switchTrigeDetector = STD_new(1000)
    luaunit.assertTrue(STD_run(switchTrigeDetector, 700))
    luaunit.assertFalse(STD_run(switchTrigeDetector, 750))
    luaunit.assertFalse(STD_run(switchTrigeDetector, 800))
    luaunit.assertTrue(STD_run(switchTrigeDetector, 0))
    luaunit.assertTrue(STD_run(switchTrigeDetector, -200))
    luaunit.assertTrue(STD_run(switchTrigeDetector, -50))
end


HOME_DIR = os.getenv("HOME_DIR")
if not HOME_DIR then
    HOME_DIR = "./"
else
    HOME_DIR = HOME_DIR .. "/"
end
dofile(HOME_DIR .. "test/utils4Test.lua")