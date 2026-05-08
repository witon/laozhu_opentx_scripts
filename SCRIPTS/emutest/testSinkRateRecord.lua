if not gSDCardDir then
    gSDCardDir = "/"
end

local function isRecordEquals(r1, r2)
    if r1 == nil or r2 == nil then
        return false
    end
    if r1.startTime ~= r2.startTime then
        return false
    end
    if r1.startAlt ~= r2.startAlt then
        return false
    end
    if r1.stopTime ~= r2.stopTime then
        return false
    end
    if r1.stopAlt ~= r2.stopAlt then
        return false
    end
    if r1.ele ~= r2.ele then
       return false
    end
    if r1.flap1 ~= r2.flap1 then
      return false
    end
    if r1.flap2 ~= r2.flap2 then
        return false
    end
    return true
end

local function testSinkRateRecord()

    dofile(gSDCardDir .. "LAOZHU/DataFileDecode.lua")
    dofile(gSDCardDir .. "LAOZHU/SinkRateRecord.lua")
 
    local sinkRateRecord = SRRnewSinkRateRecord()
    local dateTime = getDateTime()
    assert(
        SRRclearOneDayRecordsFromFile(dateTime),
        "SRRclear: need SCRIPTS/data/ (run install script or mkdir SD:/SCRIPTS/data)"
    )
    local destRecords = {}
    for i = 1, 10, 1 do
        local record = {}
        record.startTime = 100
        record.startAlt = 200
        record.stopTime = 400
        record.stopAlt = 10
        record.ele = -10
        record.flap1 = i
        record.flap2 = "-"
        assert(
            SRRwriteOneRecordToFile(dateTime, record),
            "SRRwrite: need SCRIPTS/data/ (run install script or mkdir SD:/SCRIPTS/data)"
        )
        destRecords[#destRecords + 1] = record
    end
    assert(
        SRRreadOneDayRecordsFromFile(sinkRateRecord, dateTime),
        "SRRread: missing .records file under SCRIPTS/data/"
    )
    assert(#sinkRateRecord.records == 10, "SRRread: expected 10 records")
    for i = 1, 10, 1 do
        assert(isRecordEquals(sinkRateRecord.records[i], destRecords[i]), "record mismatch at " .. tostring(i))
    end
    SRRunload()
    DFDunload()
end


return {testSinkRateRecord}
