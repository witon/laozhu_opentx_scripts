local selectedIndex = 1
local flightArray = nil
local function drawFlightList()
	local x = 127 
	local y = 10 

	lcd.drawText(2, 1, "LauTime", SMLSIZE + LEFT)
	lcd.drawText(85, 1, "LauALT", SMLSIZE + RIGHT)
	lcd.drawText(126, 1, "FTime", SMLSIZE + RIGHT)
	local i = 0
	local v = 0
	for i, flight in ipairs(flightArray) do
		if i>selectedIndex-4 and i<selectedIndex+4 then
			local drawOption = 0
			if i==selectedIndex then
				lcd.drawFilledRectangle(0, y-1, 129, 14, 0)
				drawOption = INVERS
			end
			lcd.drawText(2, y, LZ_formatDateTime(flight.flightStartTime), MIDSIZE + LEFT + drawOption)
			lcd.drawNumber(85, y, flight.launchAlt, MIDSIZE + RIGHT + drawOption)
			lcd.drawText(126, y, LZ_formatTime(flight.flightTime), MIDSIZE + RIGHT + drawOption)
			y = y + 14 
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