function SRRnewSinkRateRecord()
    local dataFileDecode = DFDnewDataFileDecode()
    return {dataFileDecode=dataFileDecode, records={}}
end

function SRRgetRecordSinkRate(record)
    return (record.startAlt - record.stopAlt) * 100 / (record.stopTime - record.startTime)
end

function SRRwriteOneRecordToFile(dateTime, record)
	local relativePath = string.format("data/%04d%02d%02d.records", dateTime["year"], dateTime["mon"], dateTime["day"])
    local recordFilePath = gScriptDir .. relativePath
    local recordFile = io.open(recordFilePath, 'a')
    if recordFile == nil then
        return false
    end
    io.write(recordFile,
            record.startTime, " ",
            record.startAlt, " ", 
            record.stopTime, " ", 
            record.stopAlt, " ", 
            record.ele, " ", 
            record.flap1, " ",
            record.flap2, " ", "\n")
    io.close(recordFile)
    return true
end

function SRRgetOneRecord(srr)
    local record = {}
    record.startTime = DFDgetOneNumField(srr.dataFileDecode, " ")
    if record.startTime == nil then
        return nil
    end
    record.startAlt = DFDgetOneNumField(srr.dataFileDecode, " ")
    if record.startAlt == nil then
        return nil
    end
    record.stopTime = DFDgetOneNumField(srr.dataFileDecode, " ")
    if record.stopTime == nil then
        return nil
    end
    record.stopAlt = DFDgetOneNumField(srr.dataFileDecode, " ")
    if record.stopAlt == nil then
        return nil
    end
    record.ele = DFDgetOneField(srr.dataFileDecode, " ")
    if record.ele == nil then
        return nil
    end
    if record.ele ~= "-" then
        record.ele = tonumber(record.ele)
    end
    record.flap1 = DFDgetOneField(srr.dataFileDecode, " ")
    if record.flap1 == nil then
        return nil
    end
    if record.flap1 ~= "-" then
        record.flap1 = tonumber(record.flap1)
    end
    record.flap2 = DFDgetOneField(srr.dataFileDecode, " ")
    if record.flap2 == nil then
        return nil
    end
    if record.flap2 ~= "-" then
        record.flap2 = tonumber(record.flap2)
    end
    local flag = DFDgetOneField(srr.dataFileDecode, "\n")
    return record
end

function SRRclearOneDayRecordsFromFile(dateTime)
	local relativePath = string.format("data/%04d%02d%02d.records", dateTime["year"], dateTime["mon"], dateTime["day"])
    local recordFilePath = gScriptDir .. relativePath
    local recordFile = io.open(recordFilePath, 'w')
    io.close(recordFile)
end

function SRRreadOneDayRecordsFromFile(srr, dateTime)
    srr.records = {}
	local relativePath = string.format("data/%04d%02d%02d.records", dateTime["year"], dateTime["mon"], dateTime["day"])
    local recordFilePath = gScriptDir .. relativePath
    local recordFile = io.open(recordFilePath, 'r')
    if recordFile == nil then
        return false
    end
    DFDsetFile(srr.dataFileDecode, recordFile)
    local record = SRRgetOneRecord(srr)
    local i = 1
    while record ~= nil do
        srr.records[#(srr.records) + 1] = record
        record = SRRgetOneRecord(srr)
        i = i + 1
    end
    io.close(recordFile)
    return true
end

function SRRaddOneRecord(sinkRateRecord, startTime, startAlt, stopTime, stopAlt, ele, flap1, flap2)
    local record = {}
    record.startTime = startTime
    record.startAlt = startAlt
    record.stopTime = stopTime
    record.stopAlt = stopAlt
    record.ele = ele
    record.flap1 = flap1
    record.flap2 = flap2
    sinkRateRecord.records[#sinkRateRecord.records + 1] = record
    return record
end

function SRRunload()
    SRRnewSinkRateRecord = nil
    SRRgetRecordSinkRate = nil
    SRRgetOneRecord = nil
    SRRwriteOneRecordToFile = nil
    SRRreadOneDayRecordsFromFile = nil
    SRRaddOneRecord = nil
    SRRclearOneDayRecordsFromFile = nil
    SRRunload = nil
end