dofile(gScriptDir .. "LAOZHU/utils.lua")

function SRRnewSinkRateRecord(baseTime)
    return {}
end

function SRRgetRecordSinkRate(record)
    return (record.startAlt - record.stopAlt) * 100 / (record.stopTime - record.startTime)
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
    sinkRateRecord[#sinkRateRecord + 1] = record
end