local transVoltSensor = nil
local recvVoltSensor = nil
local rssiSensor = nil

local function recvVoltwarningCallback(sensor, rule, time, value)
    --print("recv volt warning", "average volt", rule.averageValue, "value", value)
end

local function init()
    transVoltSensor = SENSnewSensor("transmittor voltage", 30, false)
    recvVoltSensor = SENSnewSensor("receiver voltage", 30, false)
    rssiSensor = SENSnewSensor("rssi", 30, false)
    SENSaddFluctuateRule(recvVoltSensor, 3.7, 10, 0.2, recvVoltwarningCallback)
end

local function run(time, transVolt, recvVolt, rssi)
    SENSrun(recvVoltSensor, time, recvVolt)
end

return {run=run, init=init}
