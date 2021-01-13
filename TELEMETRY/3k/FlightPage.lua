local function worktimeViewFocusDraw()
	lcd.drawText(22, 11, LZ_formatTime(Timer_getRemainTime(gWorktimeTimer)), LEFT + DBLSIZE + INVERS)
end

local function worktimeViewUnfocusDraw()
	lcd.drawText(22, 11, LZ_formatTime(Timer_getRemainTime(gWorktimeTimer)), LEFT + DBLSIZE)
end

local function worktimeViewSelectingDraw(b)
	if b then
		lcd.drawText(22, 11, LZ_formatTime(Timer_getRemainTime(gWorktimeTimer)), LEFT + DBLSIZE)
	else
		lcd.drawText(22, 11, LZ_formatTime(Timer_getRemainTime(gWorktimeTimer)), LEFT + DBLSIZE + INVERS)
	end
end

local function worktimeViewDoEvent(event)
	if(event==36 or event==68 or event==EVT_ROT_RIGHT) then
		gSelectWorktimeIndex = gSelectWorktimeIndex + 1
		if gSelectWorktimeIndex > #gWorktimeArray then
			gSelectWorktimeIndex = 1
		end
		Timer_setDuration(gWorktimeTimer, gWorktimeArray[gSelectWorktimeIndex])
	elseif(event==35 or event==67 or event==EVT_ROT_LEFT) then
		gSelectWorktimeIndex = gSelectWorktimeIndex - 1
		if gSelectWorktimeIndex <= 0 then
			gSelectWorktimeIndex = #gWorktimeArray
		end
		Timer_setDuration(gWorktimeTimer, gWorktimeArray[gSelectWorktimeIndex])
	end
end

local function destFlightTimeViewFocusDraw()
	lcd.drawText(65, 38, LZ_formatTime(gFlightState.getDestFlightTime()), LEFT + SMLSIZE + INVERS)
end

local function destFlightTimeViewUnfocusDraw()
	lcd.drawText(65, 38, LZ_formatTime(gFlightState.getDestFlightTime()), LEFT + SMLSIZE)
end

local function destFlightTimeViewSelectingDraw(b)
	if b then
		lcd.drawText(65, 38, LZ_formatTime(gFlightState.getDestFlightTime()), LEFT + SMLSIZE)
	else
		lcd.drawText(65, 38, LZ_formatTime(gFlightState.getDestFlightTime()), LEFT + SMLSIZE + INVERS)
	end
end

local function destFlightTimeViewDoEvent(event)
	if(event==36 or event==68 or event==EVT_ROT_RIGHT) then
		local destFlightTime = gFlightState.getDestFlightTime()
		destFlightTime = destFlightTime + f3kCfg.getNumberField("DestTimeStep", 15)
		LZ_playTime(destFlightTime, true)
		gFlightState.setDestFlightTime(destFlightTime)
	elseif(event==35 or event==67 or event==EVT_ROT_LEFT) then
		local destFlightTime = gFlightState.getDestFlightTime()
		destFlightTime = destFlightTime - f3kCfg.getNumberField("DestTimeStep", 15)
		if destFlightTime < 0 then
			destFlightTime = 0
		else
			LZ_playTime(destFlightTime, true)
		end
		gFlightState.setDestFlightTime(destFlightTime)
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

local worktimeView = {
	focusDraw = worktimeViewSelectingDraw,
	unfocusDraw = worktimeViewUnfocusDraw,
	selectingDraw = worktimeViewSelectingDraw,
	doEvent = worktimeViewDoEvent
}

local destFlightTimeView = {
	focusDraw = destFlightTimeViewFocusDraw,
	unfocusDraw = destFlightTimeViewUnfocusDraw,
	selectingDraw = destFlightTimeViewSelectingDraw,
	doEvent = destFlightTimeViewDoEvent
}

local focusView = worktimeView
local isFocusViewEditing = false

local function drawFlightInfo()
	lcd.drawText(1, 1, model.getInfo().name, SMLSIZE)

	local flightMode, flightModeName = getFlightMode()
	lcd.drawText(40, 1, flightModeName, LEFT + SMLSIZE)

	lcd.drawChannel(90, 1, "RxBt", RIGHT + SMLSIZE)



	lcd.drawText(1, 18, "WT", SMLSIZE)

	local invers = math.floor(getTime() / 100) % 2 == 0
	drawView(worktimeView, focusView == worktimeView, isFocusViewEditing, invers)

	lcd.drawText(65, 18, "ST", SMLSIZE)
	lcd.drawText(87, 11, gFlightState.getCurFlightStateName(), LEFT + DBLSIZE)


	lcd.drawText(1, 36, "RSSI", SMLSIZE)
	lcd.drawChannel(50, 29,  "RSSI", RIGHT + DBLSIZE)



	lcd.drawText(65, 30, "FT", SMLSIZE)
	drawView(destFlightTimeView, focusView == destFlightTimeView, isFocusViewEditing, invers)
	lcd.drawText(87, 29, LZ_formatTime(gFlightState.getFlightTime()), LEFT + DBLSIZE)

	lcd.drawText(1, 53, "ALT", SMLSIZE)
	lcd.drawNumber(62, 47, gCurAlt, RIGHT + DBLSIZE)

	lcd.drawText(65, 53, "LALT", SMLSIZE)
	lcd.drawNumber(128, 47, gFlightState.getLaunchAlt(), RIGHT + DBLSIZE)

end

local function init()

end


local function run(event, time)
	drawFlightInfo()
	
	if(event == EVT_EXIT_BREAK or event == EVT_ENTER_BREAK) then
		isFocusViewEditing = not isFocusViewEditing
	end
	if isFocusViewEditing then
		focusView.doEvent(event)
		return true
	else
		if(event==36 or event==68) or (event==35 or event==67) then
			if focusView == worktimeView then
				focusView = destFlightTimeView
			else
				focusView = worktimeView
			end
		end
	end
end

return {run = run, init=init}