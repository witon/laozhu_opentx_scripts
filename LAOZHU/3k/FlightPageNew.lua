local viewMatrix = nil
local destFlightTimeEdit = nil
local midX

LZ_runModule(gSDCardDir .. "LAOZHU/uilib/ViewMatrixO.lua")
LZ_runModule(gSDCardDir .. "LAOZHU/uilib/InputViewO.lua")
LZ_runModule(gSDCardDir .. "LAOZHU/uilib/NumEditO.lua")
LZ_runModule(gSDCardDir .. "LAOZHU/uilib/TimeEditO.lua")

local function drawFlightList()
	lcd.drawLine(midX, 0, midX, LCD_H, SOLID, 0)
	local records = F3KFRgetFlightArray(gF3kCore.getRound().getTask().getFlightRecord())
	if records ~= nil then
		local rw = LCD_W - midX
		local rs = LZ_ui.rowStep
		local maxRows = math.max(1, math.floor(LCD_H / rs))
		local nShow = math.min(#records, maxRows)
		local strAnchor = midX + math.floor(rw * 37 / 63)
		local timeAnchor = LCD_W - 1
		for i = 1, nShow, 1 do
			local record = records[#records - i + 1]
			local y = (i - 1) * rs
			local op = 0
			local str = record.index .. ")" .. LZ_formatTimeStamp(record.flightStartTime, 2)
			lcd.drawText(strAnchor, y, str, LZ_ui.font + RIGHT + op)
			lcd.drawText(timeAnchor, y, LZ_formatTime(record.flightTime), LZ_ui.font + RIGHT + op)
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

	lcd.drawText(math.floor(LCD_W / 128), 0, model.getInfo().name, LZ_ui.font)

	local taskName = f3kCfg:getStrField("task", "-")

	lcd.drawText(midX - 1, 0, taskName, RIGHT + LZ_ui.font)
	lcd.drawLine(0, math.floor(9 * LCD_H / 64), midX, math.floor(9 * LCD_H / 64), SOLID, 0)
	lcd.drawLine(0, math.floor(46 * LCD_H / 64), midX, math.floor(46 * LCD_H / 64), SOLID, 0)
	lcd.drawText(midX - 1, math.floor(48 * LCD_H / 64), flightState.getCurFlightStateName(), RIGHT + LZ_ui.font)
	lcd.drawChannel(0, math.floor(57 * LCD_H / 64), "RxBt", LEFT + LZ_ui.font)
	lcd.drawChannel(math.floor(50 * LCD_W / 128), math.floor(57 * LCD_H / 64), "RSSI", RIGHT + LZ_ui.font)


	local roundState = gF3kCore.getRound().getState()
	if roundState == 1 then
		lcd.drawText(0, math.floor(18 * LCD_H / 64), "WT", smlsize)
		lcd.drawText(midX, math.floor(11 * LCD_H / 64), LZ_formatTime(gF3kCore.getRound().getTask().getWorkTime()), RIGHT + LZ_ui.fontL1)
	elseif roundState == 2 then
		lcd.drawText(0, math.floor(18 * LCD_H / 64), "PREP", smlsize)
	elseif roundState == 3 then
		lcd.drawText(0, math.floor(18 * LCD_H / 64), "TEST", smlsize)
	elseif roundState == 4 then
		lcd.drawText(0, math.floor(18 * LCD_H / 64), gF3kCore.getRound().getTask().getStateDisc(), smlsize)
	elseif roundState == 5 then
		lcd.drawText(0, math.floor(18 * LCD_H / 64), "END", smlsize)
	end
	if roundState ~= 1 then
		lcd.drawText(midX, math.floor(11 * LCD_H / 64), LZ_formatTime(gF3kCore.getRound().getTimer():getRemainTime()), RIGHT + LZ_ui.fontL1)
	end

	invers = math.floor(getTime() / 100) % 2 == 0

	lcd.drawText(0, math.floor(30 * LCD_H / 64), "FT", LZ_ui.font)
	lcd.drawText(midX, math.floor(29 * LCD_H / 64), LZ_formatTime(flightState.getFlightTime()), RIGHT + LZ_ui.fontL1)
	destFlightTimeEdit:draw(0, math.floor(38 * LCD_H / 64), invers, LEFT + LZ_ui.font)

end

local function init()
	midX = math.floor(LCD_W / 2)
	viewMatrix = ViewMatrix:new()
	destFlightTimeEdit = TimeEdit:new()
	destFlightTimeEdit.num = gF3kCore.getFlightState().destFlightTime
	destFlightTimeEdit:setRange(0, 900)
	destFlightTimeEdit.step = f3kCfg:getNumberField("DestTimeStep", 15)
	destFlightTimeEdit:setOnChange(onDestFlightTimeChange)
	local row = viewMatrix:addRow()
	row[1] = destFlightTimeEdit
	viewMatrix:updateCurIVFocus()
end


local function run(event, time)
	drawFlightInfo()
	drawFlightList()
	return viewMatrix:doKey(event)
end

local function destroy()
	ViewMatrix = nil
	InputView = nil
	NumEdit = nil
	TimeEdit = nil
end

init()

return {run = run, destroy=destroy}
