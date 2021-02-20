gScriptDir = HOME_DIR



function testLZ_formatTimeHMS()
    dofile(gScriptDir .. "/LAOZHU/utils.lua")
    local time = 1613744918
    luaunit.assertEquals(LZ_formatTimeStamp(time), "14:28:38")
end


HOME_DIR = os.getenv("HOME_DIR")
if not HOME_DIR then
    HOME_DIR = "./"
else
    HOME_DIR = HOME_DIR .. "/"
end
dofile(HOME_DIR .. "test/utils4Test.lua")