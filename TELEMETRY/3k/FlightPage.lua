local flightState = nil



local function destFlightTimeViewFocusDraw()
	lcd.drawText(65, 38, LZ_formatTime(flightState.getDestFlightTime()), LEFT + SMLSIZE + INVERS)
end

local function destFlightTimeViewUnfocusDraw()
	lcd.drawText(65, 38, LZ_formatTime(flightState.getDestFlightTime()), LEFT + SMLSIZE)
end

local function destFlightTimeViewSelectingDraw(b)
	if b then
		lcd.drawText(65, 38, LZ_formatTime(flightState.getDestFlightTime()), LEFT + SMLSIZE)
	else
		lcd.drawText(65, 38, LZ_formatTime(flightState.getDestFlightTime()), LEFT + SMLSIZE + INVERS)
	end
end

local function destFlightTimeViewDoEvent(event)
	if(event==36 or event==68 or event==EVT_ROT_RIGHT) then
		local destFlightTime = flightState.getDestFlightTime()
		destFlightTime = destFlightTime + f3kCfg:getNumberField("DestTimeStep", 15)
		LZ_playTime(destFlightTime, true)
		flightState.setDestFlightTime(destFlightTime)
	elseif(event==35 or event==67 or event==EVT_ROT_LEFT) then
		local destFlightTime = flightState.getDestFlightTime()
		destFlightTime = destFlightTime - f3kCfg:getNumberField("DestTimeStep", 15)
		if destFlightTime < 0 then
			destFlightTime = 0
		else
			LZ_playTime(destFlightTime, true)
		end
		flightState.setDestFlightTime(destFlightTime)
	end
end

local function drawView(view, isFocus, isSelecting, invers)
	if not isFocus then
		view.unfocusDraw()
		return
	end
	if isSelecting then
		view.selectingDraw(invers)
	else
		view.focusDraw()
	end
end

local destFlightTimeView = {
	focusDraw = destFlightTimeViewFocusDraw,
	unfocusDraw = destFlightTimeViewUnfocusDraw,
	selectingDraw = destFlightTimeViewSelectingDraw,
	doEvent = destFlightTimeViewDoEvent
}

local focusView = destFlightTimeView 
local isFocusViewEditing = false

local function drawFlightInfo()
	lcd.drawText(1, 1, model.getInfo().name, SMLSIZE)
	lcd.drawText(40, 1, gF3kCore.getRound().getTask().getTaskName(), LEFT + SMLSIZE)
	lcd.drawChannel(90, 1, "RxBt", RIGHT + SMLSIZE)

	local roundState = gF3kCore.getRound().getState()
	if roundState == 1 then
		lcd.drawText(1, 18, "Beg", smlsize)
	elseif roundState == 2 then
		lcd.drawText(1, 18, "Opr", smlsize)
	elseif roundState == 3 then
		lcd.drawText(1, 18, "Tst", smlsize)
	elseif roundState == 4 then
		lcd.drawText(1, 18, gF3kCore.getRound().getTask().getStateDisc(), smlsize)
	elseif roundState == 5 then
		lcd.drawText(1, 18, "End", smlsize)
	end

	lcd.drawText(22, 11, LZ_formatTime(gF3kCore.getRound().getTimer():getRemainTime()), LEFT + DBLSIZE)

	local invers = math.floor(getTime() / 100) % 2 == 0

	lcd.drawText(65, 18, "ST", SMLSIZE)
	lcd.drawText(87, 11, flightState.getCurFlightStateName(), LEFT + DBLSIZE)


	lcd.drawText(1, 36, "RSSI", SMLSIZE)
	lcd.drawChannel(50, 29,  "RSSI", RIGHT + DBLSIZE)



	lcd.drawText(65, 30, "FT", SMLSIZE)
	drawView(destFlightTimeView, focusView == destFlightTimeView, isFocusViewEditing, invers)
	lcd.drawText(87, 29, LZ_formatTime(flightState.getFlightTime()), LEFT + DBLSIZE)

	lcd.drawText(1, 53, "ALT", SMLSIZE)
	lcd.drawNumber(62, 47, flightState.getCurAlt(), RIGHT + DBLSIZE)

	lcd.drawText(65, 53, "LALT", SMLSIZE)
	lcd.drawNumber(128, 47, flightState.getLaunchAlt(), RIGHT + DBLSIZE)

end

local function init()
	flightState = gF3kCore.getFlightState()
end


local function run(event, time)
	drawFlightInfo()
	
	if(event == EVT_EXIT_BREAK or event == EVT_ENTER_BREAK) then
		isFocusViewEditing = not isFocusViewEditing
	end
	if isFocusViewEditing then
		focusView.doEvent(event)
		return true
	end
end

return {run = run, init=init}