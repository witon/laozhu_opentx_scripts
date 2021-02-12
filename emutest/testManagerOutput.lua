
local function testBackupOutputsToFile()
    dofile(gScriptDir .. "TELEMETRY/adjust/ManagerOutput.lua")
    backupOutputsToFile(1)
end

local function testGetOutputsFromFile()
    dofile(gScriptDir .. "TELEMETRY/adjust/ManagerOutput.lua")
    backupOutputsToFile(1)
    local backupInfo, outputs = getOutputsFromFile(1)
    assert(backupInfo.name == model.getInfo().name)
    assert(outputs[2].name == "rud")
end


local function testRestoreOutputsFromFile()
    dofile(gScriptDir .. "TELEMETRY/adjust/ManagerOutput.lua")
    backupOutputsToFile(1)
    local ret = restoreOutputsFromFile(1)
    assert(ret)
end


return {testBackupOutputsToFile,
        testGetOutputsFromFile,
        testRestoreOutputsFromFile
}
