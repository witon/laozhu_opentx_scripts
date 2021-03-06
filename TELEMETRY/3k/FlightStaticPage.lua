local maxAltID = 0
local minRxbtID = 0
local minRssiID= 0
local function init()
	maxAltID = getTelemetryId("Alt+")
	minRxbtID = getTelemetryId("RxBt-")
	minRssiID = getTelemetryId("RSSI-")
end


local function run(event, time)

	lcd.drawText(64, 22, "MaxAlt:", SMLSIZE)
	lcd.drawNumber(128, 18, getValue(maxAltID), MIDSIZE + RIGHT)
	lcd.drawText(64, 39, "MinRVol:", SMLSIZE)
	lcd.drawNumber(128, 34, getValue(minRxbtID) * 100, MIDSIZE + RIGHT + PREC2)
	lcd.drawText(64, 56, "MinRSSI:", SMLSIZE)
	lcd.drawNumber(128, 50, getValue(minRssiID), MIDSIZE + RIGHT)
end

return {run = run, init=init}