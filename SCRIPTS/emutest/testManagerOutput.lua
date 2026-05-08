if not gSDCardDir then
    gSDCardDir = "/"
end

local function testBackupOutputsToFile()
    dofile(gSDCardDir .. "SCRIPTS/TELEMETRY/adjust/ManagerOutput.lua")
    backupOutputsToFile(1)
end

local function testGetOutputsFromFile()
    dofile(gSDCardDir .. "SCRIPTS/TELEMETRY/adjust/ManagerOutput.lua")
    backupOutputsToFile(1)
    local backupInfo, outputs = getOutputsFromFile(1)
    assert(backupInfo.name == model.getInfo().name)
    assert(outputs[2].name == model.getOutput(1).name)
end


local function testRestoreOutputsFromFile()
    dofile(gSDCardDir .. "SCRIPTS/TELEMETRY/adjust/ManagerOutput.lua")
    backupOutputsToFile(1)
    local ret = restoreOutputsFromFile(1)
    assert(ret)
end


return {testBackupOutputsToFile,
        testGetOutputsFromFile,
        testRestoreOutputsFromFile
}
