local selectedIndex = 1
local flightArray = nil

local function drawFlightList()
	local rs = LZ_ui.rowStep
	local y = rs + 1

	lcd.drawText(2, 1, "LauTime", LZ_ui.font + LEFT)
	lcd.drawText(85, 1, "LauALT", LZ_ui.font + RIGHT)
	lcd.drawText(126, 1, "FTime", LZ_ui.font + RIGHT)
	local i = 0
	local v = 0
	for i, v in ipairs(gLaunchDateTimeArray) do
		if i > selectedIndex - 5 and i<selectedIndex + 6 then
			local drawOption = 0
			if i==selectedIndex then
				lcd.drawFilledRectangle(0, y-1, 129, rs, 0)
				drawOption = INVERS
			end
			lcd.drawText(2, y, LZ_formatDateTime(gLaunchDateTimeArray[i]), LZ_ui.font + LEFT + drawOption)
			lcd.drawNumber(85, y, gLaunchALTArray[i], LZ_ui.font + RIGHT + drawOption)
			if gPowerOnAgainArray[i] then
				lcd.drawText(86, y, "*", LZ_ui.font + LEFT + drawOption)
			end
			lcd.drawText(126, y, LZ_formatTime(gFlightTimeArray[i]), LZ_ui.font + RIGHT + drawOption)
			y = y + rs
		end
	end
end



local function init()

end

local function doKey(event)
	if(event==36 or event==68) then
		selectedIndex = selectedIndex - 1
		if selectedIndex < 1 then
			selectedIndex = #flightArray
		end
	elseif(event==35 or event==67) then
		selectedIndex = selectedIndex + 1
		if selectedIndex > #flightArray then
			selectedIndex = 1
		end
	end
end

local function run(event, time)
	flightArray = gFlightState.getFlightRecord().getFlightArray()
    drawFlightList()
    doKey(event)
end

return {run = run, init=init}