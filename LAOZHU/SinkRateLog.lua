dofile(gScriptDir .. "LAOZHU/utils.lua")

function SRLnewSinkRateLog()
    return {startTime = -1,
            logFile = nil}
end

function SRLsetLogFile(srl, logFile)
    srl.logFile = logFile
end

function SRLnewFlight(srl, startTime)
    srl.startTime = startTime
end

function SRLencode(srl, time, alt)

end