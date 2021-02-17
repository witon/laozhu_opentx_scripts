
function backupOneParamToFile(file, param)
    io.write(file, param)
    io.write(file, "\n")
end

function getOneStrParamFromBuf(buf, start)
    local pos = string.find(buf, "\n", start)
    if not pos then
        return nil
    end
    return string.sub(buf, start, pos-1), pos
end

function getOneNumParamFromBuf(buf, start)
    local str, pos = getOneStrParamFromBuf(buf, start)
    if not str then
        return nil
    end
    return tonumber(str), pos
end


function backupOneOutputToFile(file, output)
    backupOneParamToFile(file, output.name)
    backupOneParamToFile(file, output.min)
    backupOneParamToFile(file, output.max)
    backupOneParamToFile(file, output.offset)
    backupOneParamToFile(file, output.ppmCenter)
    backupOneParamToFile(file, output.symetrical)
    backupOneParamToFile(file, output.revert)
    if output.curve then
        backupOneParamToFile(file, output.curve)
    else
        backupOneParamToFile(file, "-1")
    end
    backupOneParamToFile(file, "")
end

function getOneOutputFromBuf(buf, start)
    local output = {}
    local pos = start
    output.name, pos = getOneStrParamFromBuf(buf, pos)
    if not output.name then
        return nil
    end
    pos = pos + 1
    output.min, pos = getOneNumParamFromBuf(buf, pos)
    if not output.min then
        return nil
    end
    pos = pos + 1
 
    output.max, pos = getOneNumParamFromBuf(buf, pos)
    if not output.max then
        return nil
    end
    pos = pos + 1
 
    output.offset, pos = getOneNumParamFromBuf(buf, pos)
    if not output.offset then
        return nil
    end
    pos = pos + 1
 
    output.ppmCenter , pos = getOneNumParamFromBuf(buf, pos)
    if not output.ppmCenter then
        return nil
    end
    pos = pos + 1
 
    output.symetrical, pos = getOneNumParamFromBuf(buf, pos)
    if not output.symetrical then
        return nil
    end
    pos = pos + 1
 
    output.revert, pos = getOneNumParamFromBuf(buf, pos)
    if not output.revert then
        return nil
    end
    pos = pos + 1
 
    output.curve, pos = getOneNumParamFromBuf(buf, pos)
    if not output.curve then
        return nil
    elseif output.curve == "-1" then
        output.curve = nil
    end
    pos = pos + 1
    return output, pos
end

function getBackupInfofromBuf(buf, start)
    local backupInfo = {}
    local pos = start
    backupInfo.name, pos = getOneStrParamFromBuf(buf, pos)
    if not backupInfo.name then
        return nil
    end
    pos = pos + 1
    backupInfo.time, pos = getOneNumParamFromBuf(buf, pos)
    if not backupInfo.time then
        return nil
    end
    return backupInfo, pos
end

function getAllOutputsFromBuf(buf, start)
    local pos = start
    local output = nil
    local outputs = {}
    for i = 0, 15, 1 do
        output, pos = getOneOutputFromBuf(buf, pos)
        if not output then
            return nil
        end
        pos = pos + 1
        outputs[i + 1] = output
    end
    return outputs
end

function getOutputsFromFile(index)
    local cfgFilePath = gScriptDir .. index .. ".output"
    local outputFile = io.open(cfgFilePath, "r")
    local buf = io.read(outputFile, 1000)
    local backupInfo, pos = getBackupInfofromBuf(buf, 1)
    if not backupInfo then
        return nil
    end
    pos = pos + 1
    local outputs = getAllOutputsFromBuf(buf, pos)
    if not outputs then
        return nil
    end
    return backupInfo, outputs
end


function restoreOutputsFromFile(index)
    local cfgFilePath = gScriptDir .. index .. ".output"
    local outputFile = io.open(cfgFilePath, "r")
    local buf = io.read(outputFile, 1000)
    local backupInfo, pos = getBackupInfofromBuf(buf, 1)
    pos = pos + 1
    local outputs = getAllOutputsFromBuf(buf, pos)
    if not outputs then
        return false
    end
    for i=1, #outputs, 1 do
        local output = outputs[i]
        model.setOutput(i-1, output)
    end
    return true
end

function writeBackupInfoToFile(file)
    local info = model.getInfo()
    io.write(file, info.name)
    io.write(file, "\n")
    local time = getRtcTime()
    io.write(file, time)
    io.write(file, "\n")
end

function backupOutputsToFile(index)
    local cfgFilePath = gScriptDir .. index .. ".output"
    local outputFile = io.open(cfgFilePath, "w")
    writeBackupInfoToFile(outputFile)
    for i=0, 15, 1 do
        local output = model.getOutput(i)
        backupOneOutputToFile(outputFile, output)
   end
   io.close(outputFile)
end