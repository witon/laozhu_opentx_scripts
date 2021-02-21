
local function testDataFileDecode()
    dofile(gScriptDir .. "/LAOZHU/DataFileDecode.lua")
    local dfd = DFDnewDataFileDecode()
    local file = io.open(gScriptDir .. "emutest/test_data_file.data", "r")
    DFDsetFile(dfd, file)
    local destStrs = {"12345678901234567890123456789", "abc", "def", "ghijk", "lmnopq", "rstuv", "wxyz", "0123", "45678", "90"}
    for i = 1, 10, 1 do
        local field = DFDgetOneField(dfd, " ")
        assert(destStrs[i] == field)
    end
    io.close(file)
end


return {testDataFileDecode}
