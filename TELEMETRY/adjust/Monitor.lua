
local this = nil
local rxbtID = getTelemetryId("RxBt")

local function loadModule()
end

local function unloadModule()
end

local function run(event, time)
    lcd.drawText(0, 10, "RSSI:", MIDSIZE + LEFT)
    local rssi, alarm_low, alarm_crit = getRSSI()
    lcd.drawNumber(128, 10, rssi, MIDSIZE + RIGHT)
    lcd.drawText(0, 24, "10s Min RSSI:", MIDSIZE + LEFT)
    lcd.drawNumber(128, 24, gRssiSensor.value, MIDSIZE + RIGHT)

	local recvVolt = getValue(rxbtID)
    lcd.drawText(0, 38, "RXBT:", MIDSIZE + LEFT)
    lcd.drawNumber(128, 38, recvVolt * 100, MIDSIZE + RIGHT + PREC2)
    lcd.drawText(0, 52, "10s Min RXBT:", MIDSIZE + LEFT)
    lcd.drawNumber(128, 52, gRecvVoltSensor.value * 100, MIDSIZE + RIGHT + PREC2)


end

local function bg()
end

local function init()
    loadModule()
end
init()

this = {run = run, bg = bg, pageState=0}
return this