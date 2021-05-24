
function LZ_runModule(file)
    return dofile(file)
end

function testParse()
    local groupFileParser = dofile(HOME_DIR .. "CompetitionBroadcast/GroupFileParser.lua")
    local groups = groupFileParser.parse("test/groups.txt")
    luaunit.assertTrue(groups ~= nil)
end

HOME_DIR = os.getenv("HOME_DIR")
if not HOME_DIR then
    HOME_DIR = "./"
else
    HOME_DIR = HOME_DIR .. "/"
end
dofile(HOME_DIR .. "test/utils4Test.lua")