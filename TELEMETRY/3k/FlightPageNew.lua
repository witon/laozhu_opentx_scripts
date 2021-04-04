local viewMatrix = nil
local destFlightTimeEdit = nil

LZ_runModule(gScriptDir .. "TELEMETRY/common/ViewMatrix.lua")
LZ_runModule(gScriptDir .. "TELEMETRY/common/InputView.lua")
LZ_runModule(gScriptDir .. "TELEMETRY/common/NumEdit.lua")
LZ_runModule(gScriptDir .. "TELEMETRY/common/TimeEdit.lua")


local function drawFlightList()
	lcd.drawLine(65, 0, 65, 64, SOLID, 0)
    local records = F3KFRgetFlightArray(gF3kCore.getRound().getTask().getFlightRecord())
    if records ~= nil then
        for i=1, #records, 1 do
            local record = records[#records - i + 1]
            local y = (i-1) * 8
            local op = 0
			local str = record.index .. ")" .. LZ_formatTimeStamp(record.flightStartTime, 2)
			lcd.drawText(102, y, str, SMLSIZE + RIGHT + op)
            lcd.drawText(128, y, LZ_formatTime(record.flightTime), SMLSIZE + RIGHT + op)
        end
    end
end

local function onDestFlightTimeChange(timeEdit)
	LZ_playTime(timeEdit.num, true)
	gF3kCore.getFlightState().setDestFlightTime(timeEdit.num)
end


local function drawFlightInfo()
    local invers = false
    if getRtcTime() % 2 == 1 then
        invers = true
    end

	local flightState = gF3kCore.getFlightState()

	lcd.drawText(1, 0, model.getInfo().name, 0)
	lcd.drawText(64, 0, f3kCfg["task"], RIGHT)
	lcd.drawLine(0, 9, 64, 9, SOLID, 0)
	lcd.drawLine(0, 46, 64, 46, SOLID, 0)
	lcd.drawText(64, 48, flightState.getCurFlightStateName(), RIGHT)
	lcd.drawChannel(0, 57, "RxBt", LEFT)
	lcd.drawChannel(50, 57,  "RSSI", RIGHT)


	local roundState = gF3kCore.getRound().getState()
	if roundState == 1 then
		lcd.drawText(0, 18, "WT", smlsize)
		lcd.drawText(24, 11, LZ_formatTime(gF3kCore.getRound().getTask().getWorkTime()), LEFT + DBLSIZE)
	elseif roundState == 2 then
		lcd.drawText(0, 18, "PREP", smlsize)
	elseif roundState == 3 then
		lcd.drawText(0, 18, "TEST", smlsize)
	elseif roundState == 4 then
		lcd.drawText(0, 18, gF3kCore.getRound().getTask().getStateDisc(), smlsize)
	elseif roundState == 5 then
		lcd.drawText(0, 18, "END", smlsize)
	end
	if roundState ~= 1 then
		lcd.drawText(24, 11, LZ_formatTime(Timer_getRemainTime(gF3kCore.getRound().getTimer())), LEFT + DBLSIZE)
	end

	local invers = math.floor(getTime() / 100) % 2 == 0

	lcd.drawText(0, 30, "FT", SMLSIZE)
	lcd.drawText(24, 29, LZ_formatTime(flightState.getFlightTime()), LEFT + DBLSIZE)
	IVdraw(destFlightTimeEdit, 0, 38, invers, LEFT + SMLSIZE)

end

local function init()
	viewMatrix = VMnewViewMatrix()
	destFlightTimeEdit = TIMEEnewTimeEdit()
	destFlightTimeEdit.num = gF3kCore.getFlightState().getDestFlightTime()
	NEsetRange(destFlightTimeEdit, 0, 900)
	destFlightTimeEdit.step = CFGgetNumberField(f3kCfg, "DestTimeStep", 15)
	NEsetOnChange(destFlightTimeEdit, onDestFlightTimeChange)
	local row = VMaddRow(viewMatrix)
	row[1] = destFlightTimeEdit
    VMupdateCurIVFocus(viewMatrix)
end


local function run(event, time)
	drawFlightInfo()
	drawFlightList()
	VMdoKey(viewMatrix, event)
	
end

local function destroy()
	VMunload()
	IVunload()
	NEunload()
	TIMEEunload()
end

return {run = run, init=init, destroy=destroy}