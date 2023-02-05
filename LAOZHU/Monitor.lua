local recvVoltSensor = nil
local rssiSensor = nil

local function recvVoltwarningCallback(sensor, rule, time, value)
    print("recv volt warning", "min value", sensor.value)
end

local function RSSIWarningCallback(sensor, rule, time, value)
    print("rssi warning", "min value", sensor.value)
end


local function init()
    recvVoltSensor = SENSnewSensor("receiver voltage", 30, false)
    rssiSensor = SENSnewSensor("rssi", 30, false)
    SENSsetRule(recvVoltSensor, 4.2, 10, 3.7, false, recvVoltWarningCallback)
    SENSsetRule(rssiSensor, 100, 10, 30, false, RSSIWarningCallback)
end

local function run(time, recvVolt, rssi)
    SENSrun(recvVoltSensor, time, recvVolt)
    SENSrun(rssiSensor, time, rssi)
end

return {run=run, init=init}
