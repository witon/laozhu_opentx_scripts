local flightState = nil
local function worktimeViewFocusDraw()
	lcd.drawText(22, 11, LZ_formatTime(Timer_getRemainTime(gF3kCore.getWorktimeTimer())), LEFT + DBLSIZE + INVERS)
end

local function worktimeViewUnfocusDraw()
	lcd.drawText(22, 11, LZ_formatTime(Timer_getRemainTime(gF3kCore.getWorktimeTimer())), LEFT + DBLSIZE)
end

local function worktimeViewSelectingDraw(b)
	if b then
		lcd.drawText(22, 11, LZ_formatTime(Timer_getRemainTime(gF3kCore.getWorktimeTimer())), LEFT + DBLSIZE)
	else
		lcd.drawText(22, 11, LZ_formatTime(Timer_getRemainTime(gF3kCore.getWorktimeTimer())), LEFT + DBLSIZE + INVERS)
	end
end

local function worktimeViewDoEvent(event)
	if(event==36 or event==68 or event==EVT_ROT_RIGHT) then
		gF3kCore.increaseWorktimeIndex()
	elseif(event==35 or event==67 or event==EVT_ROT_LEFT) then
		gF3kCore.decreaseWorktimeIndex()
	end
end

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
		destFlightTime = destFlightTime + CFGgetNumberField(f3kCfg, "DestTimeStep", 15)
		LZ_playTime(destFlightTime, true)
		flightState.setDestFlightTime(destFlightTime)
	elseif(event==35 or event==67 or event==EVT_ROT_LEFT) then
		local destFlightTime = flightState.getDestFlightTime()
		destFlightTime = destFlightTime - CFGgetNumberField(f3kCfg, "DestTimeStep", 15)
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