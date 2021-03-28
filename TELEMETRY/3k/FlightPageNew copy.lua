local flightState = nil
local viewMatrix = nil
local taskSelector = nil
local destFlightTimeEdit = nil

local function drawFlightList()
	lcd.drawLine(65, 0, 65, 64, SOLID, 0)
    local records = gF3kCore.getRound().getTask().getFlightRecord().getFlightArray()
    if records ~= nil then
        for i=1, #records, 1 do
            local record = records[#records - i + 1]
            local y = (i-1) * 8
            local op = 0
			lcd.drawText(67, y, "(" .. record.index .. ")", SMLSIZE + LEFT + op)
			lcd.drawText(lcd.getLastRightPos(), y, LZ_formatDateTime(record.flightStartTime), SMLSIZE + LEFT + op)
            lcd.drawText(128, y, LZ_formatTime(record.flightTime), SMLSIZE + RIGHT + op)
        end
    end
end

local function destFlightTimeViewFocusDraw()
	lcd.drawText(0, 38, LZ_formatTime(flightState.getDestFlightTime()), LEFT + SMLSIZE + INVERS)
end

local function destFlightTimeViewUnfocusDraw()
	lcd.drawText(0, 38, LZ_formatTime(flightState.getDestFlightTime()), LEFT + SMLSIZE)
end

local function destFlightTimeViewSelectingDraw(b)
	if b then
		lcd.drawText(0, 38, LZ_formatTime(flightState.getDestFlightTime()), LEFT + SMLSIZE)
	else
		lcd.drawText(0, 38, LZ_formatTime(flightState.getDestFlightTime()), LEFT + SMLSIZE + INVERS)
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

local destFlightTimeView = {
	focusDraw = destFlightTimeViewFocusDraw,
	unfocusDraw = destFlightTimeViewUnfocusDraw,
	selectingDraw = destFlightTimeViewSelectingDraw,
	doEvent = destFlightTimeViewDoEvent
}

local focusView = destFlightTimeView 
local isFocusViewEditing = false

local function drawFlightInfo()
	lcd.drawText(1, 0, model.getInfo().name, 0)
	lcd.drawText(40, 0, gF3kCore.getRound().getTask().getTaskName(), LEFT)
	--lcd.drawText(0, 56, "RSSI", SMLSIZE)
	lcd.drawLine(0, 9, 64, 9, SOLID, 0)
	lcd.drawLine(0, 46, 64, 46, SOLID, 0)
	lcd.drawText(64, 48, flightState.getCurFlightStateName(), RIGHT)
	lcd.drawChannel(0, 57, "RxBt", LEFT)
	lcd.drawChannel(50, 57,  "RSSI", RIGHT)


	local roundState = gF3kCore.getRound().getState()
	if roundState == 1 then
		lcd.drawText(0, 18, "Beg", smlsize)
	elseif roundState == 2 then
		lcd.drawText(0, 18, "Opr", smlsize)
	elseif roundState == 3 then
		lcd.drawText(0, 18, "Tst", smlsize)
	elseif roundState == 4 then
		lcd.drawText(0, 18, gF3kCore.getRound().getTask().getStateDisc(), smlsize)
	elseif roundState == 5 then
		lcd.drawText(0, 18, "End", smlsize)
	end

	lcd.drawText(22, 11, LZ_formatTime(Timer_getRemainTime(gF3kCore.getRound().getTimer())), LEFT + DBLSIZE)

	local invers = math.floor(getTime() / 100) % 2 == 0





	lcd.drawText(0, 30, "FT", SMLSIZE)
	drawView(destFlightTimeView, focusView == destFlightTimeView, isFocusViewEditing, invers)
	lcd.drawText(22, 29, LZ_formatTime(flightState.getFlightTime()), LEFT + DBLSIZE)

end

local function init()
	LZ_runModule(gScriptDir .. "TELEMETRY/common/ViewMatrix.lua")
	LZ_runModule(gScriptDir .. "TELEMETRY/common/NumEdit.lua")
	LZ_runModule(gScriptDir .. "TELEMETRY/common/TimeEdit.lua")
	LZ_runModule(gScriptDir .. "TELEMETRY/3k/TaskSelector.lua")




	viewMatrix = VMnewViewMatrix()
	taskSelector = TSnewTaskSelector()
	destFlightTimeEdit = TIMEEnewTimeEdit()
	flightState = gF3kCore.getFlightState()
end


local function run(event, time)
	drawFlightInfo()
	drawFlightList()
	
	if(event == EVT_EXIT_BREAK or event == EVT_ENTER_BREAK) then
		isFocusViewEditing = not isFocusViewEditing
	end
	if isFocusViewEditing then
		focusView.doEvent(event)
		return true
	end
end

return {run = run, init=init}