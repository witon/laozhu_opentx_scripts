local roundStartTime = getTime() 
local function drawFlightInfo()
	lcd.drawText(1, 1, model.getInfo().name, LZ_ui.font)

	local flightMode, flightModeName = getFlightMode()
	lcd.drawText(40, 1, flightModeName, LEFT + LZ_ui.font)

	lcd.drawChannel(128, 1,  "RSSI", RIGHT + LZ_ui.font)
	lcd.drawChannel(90, 1, "RxBt", RIGHT + LZ_ui.font)

	lcd.drawText(1, 18, "WT", LZ_ui.font)
	local workTimeRemain = gFlightState.getWorktimeTimer():getRemainTime()

	lcd.drawText(22, 11, LZ_formatTime(workTimeRemain), LEFT + DBLSIZE)

	lcd.drawText(67, 18, "ST", LZ_ui.font)
	lcd.drawText(87, 11, gFlightState.getCurFlightStateName(), LEFT + DBLSIZE)

	if gFlightState.getFlightState() == 1 or gFlightState.getFlightState() == 2 then
		lcd.drawText(1, 36, "PT", LZ_ui.font)

		local powerOnTimeRemain = gFlightState.getStateTimer():getRemainTime()

		lcd.drawText(22, 29, LZ_formatTime(powerOnTimeRemain), LEFT + DBLSIZE)
	else
		lcd.drawText(1, 36, "RSSI", LZ_ui.font)
		lcd.drawChannel(50, 29,  "RSSI", RIGHT + DBLSIZE)
	
	end

	lcd.drawText(67, 36, "FT", LZ_ui.font)
	lcd.drawText(87, 29, LZ_formatTime(gFlightState.getFlightTime()), LEFT + DBLSIZE)

	lcd.drawText(1, 53, "ALT", LZ_ui.font)
	lcd.drawChannel(56, 47, "Alt", RIGHT + DBLSIZE)

	if gFlightState.isPowerOnAgain() then
		lcd.drawText(67, 53, "LALT*", LZ_ui.font)
	else
		lcd.drawText(67, 53, "LALT", LZ_ui.font)
	end
	lcd.drawNumber(128, 47, gFlightState.getLaunchAlt(), RIGHT + DBLSIZE)
end

local function init()

end


local function run(event, time)
    drawFlightInfo()
end

return {run = run, init=init}