local this = {}

local function readSinkRate()
    playNumber(SRSgetCurSinkRate(this.sinkRateState)*100, 0)
end

local function readStaticTime()
    playDuration(SRSgetCurDuration(this.sinkRateState))
end

local function readSinkAlt()
    playNumber(SRSgetCurSinkAlt(this.sinkRateState), 9)
end

this[1] = readSinkRate
this[2] = readSinkRate
this[3] = readStaticTime
this[4] = readSinkAlt
this.sinkRateState = nil

return this

