local maxAltID = 0
local minRxbtID = 0
local minRssiID= 0
local function init()
	maxAltID = getTelemetryId("Alt+")
	minRxbtID = getTelemetryId("RxBt-")
	minRssiID = getTelemetryId("RSSI-")
end


local function run(event, time)

	lcd.drawText(64, 22, "MaxAlt:", LZ_ui.font)
	lcd.drawNumber(128, 18, getValue(maxAltID), LZ_ui.headerFont + RIGHT)
	lcd.drawText(64, 39, "MinRVol:", LZ_ui.font)
	lcd.drawNumber(128, 34, getValue(minRxbtID) * 100, LZ_ui.headerFont + RIGHT + PREC2)
	lcd.drawText(64, 56, "MinRSSI:", LZ_ui.font)
	lcd.drawNumber(128, 50, getValue(minRssiID), LZ_ui.headerFont + RIGHT)
end

init()

return {run = run}