gLaunchALT = 0
gFlightTime = 0
gRoundStartTime = getTime()
local displayIndex = 0

local selectedIndex = 1

local function init()
	dofile("/SCRIPTS/LAOZHU/utils.lua")
end
local function DrawLargeFlightList(event)
	local x = 127 
	local y = 10 

	lcd.drawText(2, 1, "LauTime", SMLSIZE + LEFT)
	lcd.drawText(85, 1, "LauALT", SMLSIZE + RIGHT)
	lcd.drawText(126, 1, "FTime", SMLSIZE + RIGHT)
	local i = 0
	local v = 0
	for i, v in ipairs(gLaunchDateTimeArray) do
		if i>selectedIndex-4 and i<selectedIndex+4 then
			local drawOption = 0
			if i==selectedIndex then
				lcd.drawFilledRectangle(0, y-1, 129, 14, 0)
				drawOption = INVERS
			end
			lcd.drawText(2, y, LZ_formatDateTime(gLaunchDateTimeArray[i]), MIDSIZE + LEFT + drawOption)
			lcd.drawNumber(85, y, gLaunchALTArray[i], MIDSIZE + RIGHT + drawOption)
			lcd.drawText(126, y, LZ_formatTime(gFlightTimeArray[i]), MIDSIZE + RIGHT + drawOption)
			y = y + 14 
		end
	end

	if(event==36 or event==68) then
		selectedIndex = selectedIndex - 1
		if selectedIndex < 1 then
			selectedIndex = #gLaunchDateTimeArray
		end
	elseif(event==35 or event==67) then
		selectedIndex = selectedIndex + 1
		if selectedIndex > #gLaunchDateTimeArray then
			selectedIndex = 1
		end
	end

end


local function DrawFlightList(event)
	local x = 127 
	local y = 10 

	lcd.drawText(2, 1, "LauTime", SMLSIZE + LEFT)
	lcd.drawText(85, 1, "LauALT", SMLSIZE + RIGHT)
	lcd.drawText(126, 1, "FTime", SMLSIZE + RIGHT)
	local i = 0
	local v = 0
	for i, v in ipairs(gLaunchDateTimeArray) do
		if i > selectedIndex - 5 and i<selectedIndex + 6 then
			local drawOption = 0
			if i==selectedIndex then
				lcd.drawFilledRectangle(0, y-1, 129, 9, 0)
				drawOption = INVERS
			end
			lcd.drawText(2, y, LZ_formatDateTime(gLaunchDateTimeArray[i]), SMLSIZE + LEFT + drawOption)
			lcd.drawNumber(85, y, gLaunchALTArray[i], SMLSIZE + RIGHT + drawOption)
			lcd.drawText(126, y, LZ_formatTime(gFlightTimeArray[i]), SMLSIZE + RIGHT + drawOption)
			y = y + 10 
		end
	end

	if(event==36 or event==68) then
		selectedIndex = selectedIndex - 1
		if selectedIndex < 1 then
			selectedIndex = #gLaunchDateTimeArray
		end
	elseif(event==35 or event==67) then
		selectedIndex = selectedIndex + 1
		if selectedIndex > #gLaunchDateTimeArray then
			selectedIndex = 1
		end
	end

end

local function run(event)
	lcd.clear()

	if displayIndex == 0 then
		lcd.drawText(1, 1, model.getInfo().name, SMLSIZE)

		local flightMode, flightModeName = getFlightMode()
		lcd.drawText(40, 1, flightModeName, LEFT + SMLSIZE)

		--lcd.drawChannel(128, 1,  "RSSI", RIGHT + SMLSIZE)
        --lcd.drawNumber(128, 1,  rssiValue, RIGHT + SMLSIZE)

		lcd.drawChannel(90, 1, "RxBt", RIGHT + SMLSIZE)

		lcd.drawText(1, 18, "WT", SMLSIZE)
		local workTimeRemain = 60000 - (getTime() - gRoundStartTime)
		lcd.drawText(22, 11, LZ_formatTime(workTimeRemain), LEFT + DBLSIZE)

		lcd.drawText(67, 18, "ST", SMLSIZE)
		if gFlightState == 0 then
			lcd.drawText(87, 11, "PreSet", LEFT + DBLSIZE)
		elseif gFlightState == 1 then
			lcd.drawText(87, 11, "Zoom", LEFT + DBLSIZE)
		elseif gFlightState == 2 then
			lcd.drawText(87, 11, "Fligh", LEFT + DBLSIZE)
		elseif gFlightState == 3 then
			lcd.drawText(87, 11, "Landed", LEFT + DBLSIZE)

		end


		lcd.drawText(1, 36, "RSSI", SMLSIZE)
        lcd.drawChannel(50, 29,  "RSSI", RIGHT + DBLSIZE)



		if gFlightState==2 or gFlightState==1 then
			lcd.drawText(67, 36, "FT", SMLSIZE)
			lcd.drawText(87, 29, LZ_formatTime(gFlightTime), LEFT + DBLSIZE)
		end

		lcd.drawText(1, 53, "ALT", SMLSIZE)
		lcd.drawChannel(62, 47, "Alt", RIGHT + DBLSIZE)

		lcd.drawText(67, 53, "LALT", SMLSIZE)
		lcd.drawNumber(128, 47, gLaunchALT, RIGHT + DBLSIZE)
	elseif displayIndex==1 then
        DrawLargeFlightList(event)
    elseif displayIndex==2 then
		DrawFlightList(event)
	end
	if event==38 then 
		displayIndex = displayIndex - 1
		if displayIndex < 0 then
			displayIndex = 2 
		end
	elseif event == 37 then
		displayIndex = displayIndex + 1
		if displayIndex > 2 then
			displayIndex = 0
		end

	end
	
end

return { run=run, init=init }
