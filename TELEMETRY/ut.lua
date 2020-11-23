gScriptDir = "/SCRIPTS/"
gAssertFlag = "ASSERT FLAG!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"


local testFiles = {
    "/SCRIPTS/emutest/testCfg.lua",
}


local curCaseIndex = 1
local curFileIndex = 1
local curCases = nil

local function init()
    curCases = dofile(testFiles[curFileIndex])
    curCaseIndex = 1
    dofile(gScriptDir .. "LAOZHU/EmuTestUtils.lua")
end

local function doOneCase()
    if curCaseIndex > #curCases then
        curFileIndex = curFileIndex + 1
        if curFileIndex > #testFiles then
            return
        end
        curCaseIndex = 1
        local testFile = testFiles[curFileIndex]
        curCases = dofile(testFile)
    end
    curCases[curCaseIndex]()
    curCaseIndex = curCaseIndex + 1

end

local function run(event)
    lcd.clear()
    if curFileIndex > #testFiles then
        return
    end
    doOneCase()
end

return {run=run, init=init }