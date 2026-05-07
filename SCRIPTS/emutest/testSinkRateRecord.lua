
local function isRecordEquals(r1, r2)
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

    dofile(gScriptDir .. "/LAOZHU/DataFileDecode.lua")
    dofile(gScriptDir .. "/LAOZHU/SinkRateRecord.lua")
 
    local sinkRateRecord = SRRnewSinkRateRecord()
    local dateTime = getDateTime()
    SRRclearOneDayRecordsFromFile(dateTime)
    local destRecords = {}
    for i=1, 10, 1 do
        local record = {}
        record.startTime = 100
        record.startAlt = 200
        record.stopTime = 400
        record.stopAlt = 10
        record.ele = -10
        record.flap1 = i
        record.flap2 = "-"
        SRRwriteOneRecordToFile(dateTime, record)
        destRecords[#destRecords+1] = record
    end
    SRRreadOneDayRecordsFromFile(sinkRateRecord, dateTime)
    for i=1, 10, 1 do
        assert(isRecordEquals(sinkRateRecord.records[i], destRecords[i]))
    end
    SRRunload()
    DFDunload()
end


return {testSinkRateRecord}
