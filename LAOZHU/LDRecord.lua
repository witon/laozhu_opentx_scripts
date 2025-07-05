function LDRnewLDRecord()
    local dataFileDecode = DFDnewDataFileDecode()
    return {dataFileDecode=dataFileDecode, records={}}
end

function LDRgetRecordLD(record)
    local distance = LDSdistance(record.startLon, record.startLat, record.stopLon, record.stopLat)
    if distance == 0 then
        return 0
    end
    local sinkAlt = record.startAlt - record.stopAlt
    if sinkAlt == 0 then
        return 0
    end
    return distance / sinkAlt
end

function LDRgetRecordSpeed(record)
    local distance = LDSdistance(record.startLon, record.startLat, record.stopLon, record.stopLat)
    if distance == 0 then
        return 0
    end
    local time = record.stopTime - record.startTime
    if time == 0 then
        return 0
    end
    return distance / time
end

function LDRwriteOneRecordToFile(dateTime, record)
	local relativePath = string.format("data/ld-%04d%02d%02d.records", dateTime["year"], dateTime["mon"], dateTime["day"])
    local recordFilePath = gScriptDir .. relativePath
    local recordFile = io.open(recordFilePath, 'a')
    if recordFile == nil then
        return false
    end
    io.write(recordFile,
            record.startTime, " ",
            record.startAlt, " ", 
            record.startLon, " ",
            record.startLat, " ",
            record.stopTime, " ", 
            record.stopAlt, " ", 
            record.stopLon, " ",
            record.stopLat, " ",
            record.ele, " ", 
            record.flap1, " ",
            record.flap2, " ", "\n")
    io.close(recordFile)
    return true
end

function LDRgetOneRecord(ldr)
    local record = {}
    record.startTime = DFDgetOneNumField(ldr.dataFileDecode, " ")
    if record.startTime == nil then
        return nil
    end
    record.startAlt = DFDgetOneNumField(ldr.dataFileDecode, " ")
    if record.startAlt == nil then
        return nil
    end
    record.startLon = DFDgetOneNumField(ldr.dataFileDecode, " ")
    if record.startLon == nil then
        return nil
    end
    record.startLat = DFDgetOneNumField(ldr.dataFileDecode, " ")
    if record.startLat == nil then
        return nil
    end

    record.stopTime = DFDgetOneNumField(ldr.dataFileDecode, " ")
    if record.stopTime == nil then
        return nil
    end
    record.stopAlt = DFDgetOneNumField(ldr.dataFileDecode, " ")
    if record.stopAlt == nil then
        return nil
    end
    record.stopLon = DFDgetOneNumField(ldr.dataFileDecode, " ")
    if record.stopLon == nil then
        return nil
    end
    record.stopLat = DFDgetOneNumField(ldr.dataFileDecode, " ")
    if record.stopLat == nil then
        return nil
    end


    record.ele = DFDgetOneField(ldr.dataFileDecode, " ")
    if record.ele == nil then
        return nil
    end
    if record.ele ~= "-" then
        record.ele = tonumber(record.ele)
    end
    record.flap1 = DFDgetOneField(ldr.dataFileDecode, " ")
    if record.flap1 == nil then
        return nil
    end
    if record.flap1 ~= "-" then
        record.flap1 = tonumber(record.flap1)
    end
    record.flap2 = DFDgetOneField(ldr.dataFileDecode, " ")
    if record.flap2 == nil then
        return nil
    end
    if record.flap2 ~= "-" then
        record.flap2 = tonumber(record.flap2)
    end
    local flag = DFDgetOneField(ldr.dataFileDecode, "\n")
    return record
end

function LDRclearOneDayRecordsFromFile(dateTime)
	local relativePath = string.format("data/ld-%04d%02d%02d.records", dateTime["year"], dateTime["mon"], dateTime["day"])
    local recordFilePath = gScriptDir .. relativePath
    local recordFile = io.open(recordFilePath, 'w')
    io.close(recordFile)
end

function LDRreadOneDayRecordsFromFile(ldr, dateTime)
    ldr.records = {}
	local relativePath = string.format("data/ld-%04d%02d%02d.records", dateTime["year"], dateTime["mon"], dateTime["day"])
    local recordFilePath = gScriptDir .. relativePath
    local recordFile = io.open(recordFilePath, 'r')
    if recordFile == nil then
        return false
    end
    DFDsetFile(ldr.dataFileDecode, recordFile)
    local record = LDRgetOneRecord(ldr)
    local i = 1
    while record ~= nil do
        ldr.records[#(ldr.records) + 1] = record
        record = LDRgetOneRecord(ldr)
        i = i + 1
    end
    io.close(recordFile)
    return true
end

function LDRaddOneRecord(ldr, startTime, startAlt, startLon, startLat, stopTime, stopAlt, stopLon, stopLat, ele, flap1, flap2)
    local record = {}
    record.startTime = startTime
    record.startAlt = startAlt
    record.startLon = startLon
    record.startLat = startLat
    record.stopTime = stopTime
    record.stopAlt = stopAlt
    record.stopLon = stopLon
    record.stopLat = stopLat
    record.ele = ele
    record.flap1 = flap1
    record.flap2 = flap2
    ldr.records[#ldr.records + 1] = record
    return record
end

function LDRunload()
    LDRnewLDRecord = nil
    LDRgetRecordLD = nil
    LDRgetOneRecord = nil
    LDRgetRecordSpeed = nil
    LDRwriteOneRecordToFile = nil
    LDRreadOneDayRecordsFromFile = nil
    LDRaddOneRecord = nil
    LDRclearOneDayRecordsFromFile = nil
    LDRunload = nil
end