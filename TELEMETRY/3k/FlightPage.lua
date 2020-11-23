
local function drawFlightInfo()
	lcd.drawText(1, 1, model.getInfo().name, SMLSIZE)

	local flightMode, flightModeName = getFlightMode()
	lcd.drawText(40, 1, flightModeName, LEFT + SMLSIZE)

	lcd.drawChannel(90, 1, "RxBt", RIGHT + SMLSIZE)



	lcd.drawText(1, 18, "WT", SMLSIZE)
	lcd.drawText(22, 11, LZ_formatTime(Timer_getRemainTime(gWorktimeTimer)), LEFT + DBLSIZE)

	lcd.drawText(65, 18, "ST", SMLSIZE)
	lcd.drawText(87, 11, gFlightState.getCurFlightStateName(), LEFT + DBLSIZE)


	lcd.drawText(1, 36, "RSSI", SMLSIZE)
	lcd.drawChannel(50, 29,  "RSSI", RIGHT + DBLSIZE)



	lcd.drawText(65, 38, LZ_formatTime(gFlightState.getDestFlightTime()), LEFT + SMLSIZE)
	 --if gFlightState.getFlightState()==2 or gFlightState.getFlightState()==1 then
		lcd.drawText(65, 30, "FT", SMLSIZE)
		lcd.drawText(87, 29, LZ_formatTime(gFlightState.getFlightTime()), LEFT + DBLSIZE)
	--end

	lcd.drawText(1, 53, "ALT", SMLSIZE)
	lcd.drawNumber(62, 47, gCurAlt, RIGHT + DBLSIZE)

	lcd.drawText(65, 53, "LALT", SMLSIZE)
	lcd.drawNumber(128, 47, gFlightState.getLaunchAlt(), RIGHT + DBLSIZE)

end

local function init()

end


local function run(event, time)
	drawFlightInfo()

	if(event==36 or event==68) then
		local destFlightTime = gFlightState.getDestFlightTime()
		destFlightTime = destFlightTime + 10
		gFlightState.setDestFlightTime(destFlightTime)
	elseif(event==35 or event==67) then
		local destFlightTime = gFlightState.getDestFlightTime()
		destFlightTime = destFlightTime - 10
		if destFlightTime < 0 then
			destFlightTime = 0
		end
		gFlightState.setDestFlightTime(destFlightTime)

	end

end

return {run = run, init=init}