function LRnewLaunchRecord()
    local dataFileDecode = DFDnewDataFileDecode()
    return {dataFileDecode=dataFileDecode, records={}, recordPoint = 0, maxRecordCount = 3}
end

function LRgetRecordLaunchAlt(record)
    return record.launchAlt
end

function LRwriteOneRecordToFile(dateTime, record)
	local relativePath = string.format("data/%04d%02d%02d.lrecords", dateTime["year"], dateTime["mon"], dateTime["day"])
    local recordFilePath = gScriptDir .. relativePath
    local recordFile = io.open(recordFilePath, 'a')
    if recordFile == nil then
        return false
    end
    io.write(recordFile,
            record.startTime, " ",
            record.launchAlt, " ", 
            record.ele, " ", 
            record.flap1, " ",
            record.rudder, " ", "\n")
    io.close(recordFile)
    return true
end

function LRgetOneRecord(lr)
    local record = {}
    record.startTime = DFDgetOneNumField(lr.dataFileDecode, " ")
    if record.startTime == nil then
        return nil
    end
    record.launchAlt = DFDgetOneNumField(lr.dataFileDecode, " ")
    if record.launchAlt == nil then
        return nil
    end
    record.ele = DFDgetOneField(lr.dataFileDecode, " ")
    if record.ele == nil then
        return nil
    end
    if record.ele ~= "-" then
        record.ele = tonumber(record.ele)
    end
    record.flap1 = DFDgetOneField(lr.dataFileDecode, " ")
    if record.flap1 == nil then
        return nil
    end
    if record.flap1 ~= "-" then
        record.flap1 = tonumber(record.flap1)
    end
    record.rudder = DFDgetOneField(lr.dataFileDecode, " ")
    if record.rudder == nil then
        return nil
    end
    if record.rudder ~= "-" then
        record.rudder = tonumber(record.rudder)
    end
    local flag = DFDgetOneField(lr.dataFileDecode, "\n")
    return record
end

function LRclearOneDayRecordsFromFile(dateTime)
    local relativePath = string.format("data/%04d%02d%02d.lrecords", dateTime["year"], dateTime["mon"], dateTime["day"])
    local recordFilePath = gScriptDir .. relativePath
    local recordFile = io.open(recordFilePath, 'w')
    io.close(recordFile)
end

function LRreadOneDayRecordsFromFile(lr, dateTime)
    lr.records = {}
    local relativePath = string.format("data/%04d%02d%02d.lrecords", dateTime["year"], dateTime["mon"], dateTime["day"])
    local recordFilePath = gScriptDir .. relativePath
    local recordFile = io.open(recordFilePath, 'r')
    if recordFile == nil then
        return false
    end
    DFDsetFile(lr.dataFileDecode, recordFile)
    local record = LRgetOneRecord(lr)
    local i = 1
    while record ~= nil do
        lr.recordPoint = lr.recordPoint + 1
        if lr.recordPoint > lr.maxRecordCount then
            lr.recordPoint = 1
        end
        lr.records[lr.recordPoint] = record
        record = LRgetOneRecord(lr)
        i = i + 1
    end
    io.close(recordFile)
    return true
end

function LRaddOneRecord(launchRecord, startTime, launchAlt, ele, flap1, rudder)
    local record = {}
    record.startTime = startTime
    record.launchAlt = launchAlt
    record.ele = ele
    record.flap1 = flap1
    record.rudder = rudder

    launchRecord.recordPoint = launchRecord.recordPoint + 1
    if launchRecord.recordPoint > launchRecord.maxRecordCount then
        launchRecord.recordPoint = 1
    end
    launchRecord.records[launchRecord.recordPoint] = record
    return record
end

function LRunload()
    LRnewSinkRateRecord = nil
    LRgetRecordSinkRate = nil
    LRgetOneRecord = nil
    LRwriteOneRecordToFile = nil
    LRreadOneDayRecordsFromFile = nil
    LRaddOneRecord = nil
    LRclearOneDayRecordsFromFile = nil
    LRunload = nil
end