
local function drawFlightInfo()
	lcd.drawText(1, 1, model.getInfo().name, SMLSIZE)

	local flightMode, flightModeName = getFlightMode()
	lcd.drawText(40, 1, flightModeName, LEFT + SMLSIZE)

	lcd.drawChannel(90, 1, "RxBt", RIGHT + SMLSIZE)

	lcd.drawText(1, 18, "WT", SMLSIZE)
	lcd.drawText(22, 11, LZ_formatTime(Timer_getRemainTime(gWorktimeTimer)), LEFT + DBLSIZE)

	lcd.drawText(67, 18, "ST", SMLSIZE)
	lcd.drawText(87, 11, gFlightState.getCurFlightStateName(), LEFT + DBLSIZE)


	lcd.drawText(1, 36, "RSSI", SMLSIZE)
	lcd.drawChannel(50, 29,  "RSSI", RIGHT + DBLSIZE)



	--if gFlightState.getFlightState()==2 or gFlightState.getFlightState()==1 then
		lcd.drawText(67, 36, "FT", SMLSIZE)
		lcd.drawText(87, 29, LZ_formatTime(gFlightState.getFlightTime()), LEFT + DBLSIZE)
	--end

	lcd.drawText(1, 53, "ALT", SMLSIZE)
	lcd.drawChannel(62, 47, "Alt", RIGHT + DBLSIZE)

	lcd.drawText(67, 53, "LALT", SMLSIZE)
	lcd.drawNumber(128, 47, gFlightState.getLaunchAlt(), RIGHT + DBLSIZE)

end

local function init()

end


local function run(event, time)

    drawFlightInfo()
end

return {run = run, init=init}