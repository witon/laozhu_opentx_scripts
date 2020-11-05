gScriptDir = "/SCRIPTS/"

gFlightState = nil
f3kCfg = nil

local roundStartTime = getTime()
local displayIndex = 0
local selectedIndex = 1
local setupPage = nil
local altID = 0
local readVar = nil
local function init()
	dofile("/SCRIPTS/LAOZHU/utils.lua")
	gFlightState = dofile(gScriptDir .. "LAOZHU/F3kState.lua")

	f3kCfg = dofile("/SCRIPTS/LAOZHU/F3kCfg.lua")
	f3kCfg.readFromFile()

	setupPage = dofile("/SCRIPTS/TELEMETRY/3k/SetupPage.lua")
	setupPage.init()

	altID = getTelemetryId("Alt")

	readVar = dofile(gScriptDir .. "LAOZHU/readVar.lua")
	local f3kReadVarMap = dofile(gScriptDir .. "LAOZHU/f3kReadVarMap.lua")
	readVar.setVarMap(f3kReadVarMap)
end

local function drawSetupPage(event, time)
	setupPage.run(event, time)
end

local function DrawLargeFontFlightList(event)
	local x = 127 
	local y = 10 

	lcd.drawText(2, 1, "LauTime", SMLSIZE + LEFT)
	lcd.drawText(85, 1, "LauALT", SMLSIZE + RIGHT)
	lcd.drawText(126, 1, "FTime", SMLSIZE + RIGHT)
	local i = 0
	local v = 0
	local flightArray = gFlightState.getFlightRecord().getFlightArray()
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


local function DrawSmallFontFlightList(event)
	local x = 127 
	local y = 10 

	lcd.drawText(2, 1, "LauTime", SMLSIZE + LEFT)
	lcd.drawText(85, 1, "LauALT", SMLSIZE + RIGHT)
	lcd.drawText(126, 1, "FTime", SMLSIZE + RIGHT)
	local i = 0
	local v = 0

	local flightArray = gFlightState.getFlightRecord().getFlightArray()
	for i, flight in ipairs(flightArray) do
		if i > selectedIndex - 5 and i<selectedIndex + 6 then
			local drawOption = 0
			if i==selectedIndex then
				lcd.drawFilledRectangle(0, y-1, 129, 9, 0)
				drawOption = INVERS
			end
			lcd.drawText(2, y, LZ_formatDateTime(flight.flightStartTime), SMLSIZE + LEFT + drawOption)
			lcd.drawNumber(85, y, flight.launchAlt, SMLSIZE + RIGHT + drawOption)
			lcd.drawText(126, y, LZ_formatTime(flight.flightTime), SMLSIZE + RIGHT + drawOption)
			y = y + 10 
		end
	end

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

local function run(event)
	local curTime = getTime()
	local flightMode, flightModeName = getFlightMode()
	gCurAlt = getValue(altID)

	gFlightState.setAlt(gCurAlt)
	gFlightState.doFlightState(curTime, flightModeName)
	readVar.doReadVar(getValue(f3kCfg.getVarSelectorSlider()), getValue(f3kCfg.getVarReadSwitch()))


	if getValue(f3kCfg.getWorkTimeSwitch()) > 0 then
			roundStartTime = curTime
	end


	lcd.clear()
	local time = getRtcTime()
	if not gFlightState then
		lcd.drawText(2, 32, "wait for 3kmix.lua", MIDSIZE)
		return
	end

	if displayIndex == 0 then
		lcd.drawText(1, 1, model.getInfo().name, SMLSIZE)

		local flightMode, flightModeName = getFlightMode()
		lcd.drawText(40, 1, flightModeName, LEFT + SMLSIZE)

		lcd.drawChannel(90, 1, "RxBt", RIGHT + SMLSIZE)

		lcd.drawText(1, 18, "WT", SMLSIZE)
		local workTimeRemain = 60000 - (getTime() - roundStartTime)
		lcd.drawText(22, 11, LZ_formatTime(workTimeRemain), LEFT + DBLSIZE)

		lcd.drawText(67, 18, "ST", SMLSIZE)
		lcd.drawText(87, 11, gFlightState.getCurFlightStateName(), LEFT + DBLSIZE)


		lcd.drawText(1, 36, "RSSI", SMLSIZE)
        lcd.drawChannel(50, 29,  "RSSI", RIGHT + DBLSIZE)



		if gFlightState.getFlightState()==2 or gFlightState.getFlightState()==1 then
			lcd.drawText(67, 36, "FT", SMLSIZE)
			lcd.drawText(87, 29, LZ_formatTime(gFlightState.getFlightTime()), LEFT + DBLSIZE)
		end

		lcd.drawText(1, 53, "ALT", SMLSIZE)
		lcd.drawChannel(62, 47, "Alt", RIGHT + DBLSIZE)

		lcd.drawText(67, 53, "LALT", SMLSIZE)
		lcd.drawNumber(128, 47, gFlightState.getLaunchAlt(), RIGHT + DBLSIZE)
	elseif displayIndex==1 then
        DrawLargeFontFlightList(event)
    elseif displayIndex==2 then
		DrawSmallFontFlightList(event)
    elseif displayIndex==3 then
		drawSetupPage(event, time)
	end
	if event==38 then 
		displayIndex = displayIndex - 1
		if displayIndex < 0 then
			displayIndex = 2 
		end
	elseif event == 37 then
		displayIndex = displayIndex + 1
		if displayIndex > 3 then
			displayIndex = 0
		end

	end
	
end

return { run=run, init=init }
