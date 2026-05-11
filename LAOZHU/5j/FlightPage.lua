local function sx(x)
	return math.floor(x * LCD_W / 128)
end

local function sy(y)
	return math.floor(y * LCD_H / 64)
end

-- 左半区数值右对齐锚点（约原 128 屏 x≈66）；右半区锚在屏右缘。
local function leftValRight()
	return sx(66)
end

local function drawFlightInfo()
	lcd.drawText(sx(1), sy(1), model.getInfo().name, LZ_ui.font)

	local flightMode, flightModeName = getFlightMode()
	lcd.drawText(sx(40), sy(1), flightModeName, LEFT + LZ_ui.font)

	lcd.drawChannel(sx(128), sy(1), "RSSI", RIGHT + LZ_ui.font)
	lcd.drawChannel(sx(90), sy(1), "RxBt", RIGHT + LZ_ui.font)

	local lx = leftValRight()

	lcd.drawText(sx(1), sy(18), "WT", LZ_ui.font)
	local workTimeRemain = gFlightState.getWorktimeTimer():getRemainTime()

	lcd.drawText(lx, sy(11), LZ_formatTime(workTimeRemain), RIGHT + LZ_ui.fontL1)

	lcd.drawText(sx(67), sy(18), "ST", LZ_ui.font)
	lcd.drawText(sx(87), sy(11), gFlightState.getCurFlightStateName(), LEFT + LZ_ui.fontL1)

	if gFlightState.getFlightState() == 1 or gFlightState.getFlightState() == 2 then
		lcd.drawText(sx(1), sy(36), "PT", LZ_ui.font)

		local powerOnTimeRemain = gFlightState.getStateTimer():getRemainTime()

		lcd.drawText(lx, sy(29), LZ_formatTime(powerOnTimeRemain), RIGHT + LZ_ui.fontL1)
	else
		lcd.drawText(sx(1), sy(36), "RSSI", LZ_ui.font)
		lcd.drawChannel(lx, sy(29), "RSSI", RIGHT + LZ_ui.fontL1)
	end

	lcd.drawText(sx(67), sy(36), "FT", LZ_ui.font)
	lcd.drawText(sx(128), sy(29), LZ_formatTime(gFlightState.getFlightTime()), RIGHT + LZ_ui.fontL1)

	lcd.drawText(sx(1), sy(53), "ALT", LZ_ui.font)
	lcd.drawChannel(lx, sy(47), "Alt", RIGHT + LZ_ui.fontL1)

	if gFlightState.isPowerOnAgain() then
		lcd.drawText(sx(67), sy(53), "LALT*", LZ_ui.font)
	else
		lcd.drawText(sx(67), sy(53), "LALT", LZ_ui.font)
	end
	lcd.drawNumber(sx(128), sy(47), gFlightState.getLaunchAlt(), RIGHT + LZ_ui.fontL1)
end

local function init()
end

local function run(event, time)
	drawFlightInfo()
end

return { run = run, init = init }
