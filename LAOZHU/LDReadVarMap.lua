local this = {}

local function readLD()
    playNumber(LDSgetCurLD(this.ldState), 0)
end

local function readSpeed()
    playNumber(LDSgetCurSpeed(this.ldState), 5)
end

local function readSinkRate()
    playNumber(LDSgetCurSinkRate(this.ldState), 5)
end

local function readDistance()
    playNumber(LDSgetCurDistance(this.ldState), 9)
end


this[1] = readLD
this[2] = readSpeed
this[3] = readSinkRate
this[4] = readDistance
this.ldState = nil

return this

