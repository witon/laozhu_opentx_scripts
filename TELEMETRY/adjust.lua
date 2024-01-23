gScriptDir = "/SCRIPTS/"
local bgFlag = false


local fun, err = loadScript(gScriptDir .. "TELEMETRY/common/LoadModule.lua", "bt")
fun()
LZ_runModule("LAOZHU/OTUtils.lua")
local focusIndex = 1
local pages = {"Monitor.lua", "GlobalVar.lua", "Output.lua", "SinkRate/SinkRate.lua", "Launch/Launch.lua"}
local curPage = nil
local rxbtID = getTelemetryId("RxBt")
gRecvVoltSensor = nil
gRssiSensor = nil
local lowRXBTAlarm = false
local lowRSSIAlarm = false

local function lowRecvVoltCallback(sensor, time)
	lowRXBTAlarm = true
end

local function lowRssiCallback(sensor, time)
	lowRSSIAlarm = true
end


local function initMonitor()
	LZ_runModule("LAOZHU/Sensor.lua")
	gRecvVoltSensor = SENSnewSensor("receiver voltage")
	SENSsetRule(gRecvVoltSensor, 8.4, 1000, 3.6, false, lowRecvVoltCallback)
	gRssiSensor = SENSnewSensor("rssi")
	SENSsetRule(gRssiSensor, 100, 1000, 30, false, lowRssiCallback)
end

local function loadPage(index)
	local pagePath = "TELEMETRY/adjust/" ..  pages[index]
	curPage = LZ_runModule(pagePath)
	--curPage.init()
end

local function background()
    if curPage and curPage.pageState == 1 then
		LZ_clearTable(curPage)
		curPage = nil
    end

    if not bgFlag then
        bgFlag = true
        return
    else
        if curPage then
            curPage.bg()
        end
    end
end

local function showAlarm()
	if lowRSSIAlarm then
		lcd.drawText(128, 0, "Low RSSI alarm!", RIGHT)
		lowRSSIAlarm = false
	end
	if lowRXBTAlarm then
		lcd.drawText(128, 0, "Low RXBT alarm!", RIGHT)
		lowRXBTAlarm = false
	end
end

local function run(event)
	--collectgarbage("collect")
	--print("----------", collectgarbage("count")*1000)
	local curTime = getTime()

    local rssi, alarm_low, alarm_crit = getRSSI()
	local recvVolt = getValue(rxbtID)
	if gRssiSensor ~= nil then
		SENSrun(gRssiSensor, curTime, rssi)
	else
		initMonitor()
	end
	if gRecvVoltSensor ~= nil then
		SENSrun(gRecvVoltSensor, curTime, recvVolt)
	end

	bgFlag = false
	lcd.clear()
	if curPage then
		local eventProcessed = curPage.run(event, getTime())
		showAlarm()
		if eventProcessed then
			return
		end
		if event == EVT_EXIT_BREAK then
			LZ_clearTable(curPage)
			curPage = nil
			collectgarbage()
		end
		return
	end
	for i=1, #pages, 1 do
		if focusIndex == i then
			lcd.drawText(2, i * 10 + 2, pages[i], INVERS)
		else
			lcd.drawText(2, i * 10 + 2, pages[i])
		end
	end
	showAlarm()
	if event == EVT_ENTER_BREAK then
		loadPage(focusIndex)
	elseif event == EVT_PLUS_BREAK or event == EVT_VIRTUAL_NEXT then
		focusIndex = focusIndex + 1
		if focusIndex > #pages then
			focusIndex = 1
		end
	elseif event == EVT_MINUS_BREAK or event == EVT_VIRTUAL_PREV then
		focusIndex = focusIndex - 1
		if focusIndex < 1 then
			focusIndex = #pages
		end
	end
end

--local function init()

LZ_runModule("LAOZHU/LuaUtils.lua")

if LZ_isNeedCompile() then
	local pagePath = "TELEMETRY/common/comp.lua"
	curPage = LZ_runModule(pagePath)
	--curPage.init()
else
	LZ_isNeedCompile = nil
	LZ_markCompiled = nil
	initMonitor()
end
--end

--init()

return { run=run, background=background }