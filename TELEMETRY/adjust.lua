gScriptDir = "/SCRIPTS/"
local bgFlag = false

local fun, err = loadScript(gScriptDir .. "TELEMETRY/common/LoadModule.lua", "bt")
fun()


local focusIndex = 1
local pages = {"adjust/GlobalVar.lua", "adjust/Output.lua", "adjust/SinkRate/SinkRate.lua", "adjust/Launch/Launch.lua"}
local curPage = nil
local ver, radio = getVersion();

local upEvent = 0
local downEvent = 0
local leftEvent = 0
local rightEvent = 0
local retEvent = 0
local enterEvent = 0

if string.sub(radio, 1, 5) == "zorro" then
	upEvent = 37
	downEvent = 38
	leftEvent = 4099
	rightEvent = 4100
end


local function loadPage(index)
	local pagePath = "TELEMETRY/" .. pages[index]
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

local function run(event)
	--collectgarbage("collect")
	--print("----------", collectgarbage("count")*1000)
	if event ~= 0 then
		print("before:", event)
	end
	
	bgFlag = false
	lcd.clear()
	if event == leftEvent then
		event = 38
	elseif event == rightEvent then
		event = 37
	elseif event == downEvent then
		event = 35
	elseif event == upEvent then
		event = 36
	end
	if event ~= 0 then
		print("after:", event)
	end
	
	if curPage then
		local eventProcessed = curPage.run(event, getTime())
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
			lcd.drawText(2, i * 11, pages[i], INVERS)
		else
			lcd.drawText(2, i * 11, pages[i])
		end
	end
	if event == EVT_ENTER_BREAK then
		loadPage(focusIndex)
	elseif event == EVT_PLUS_BREAK or event == 35 then --EVT_VIRTUAL_NEXT then
		focusIndex = focusIndex + 1
		if focusIndex > #pages then
			focusIndex = 1
		end
	elseif event == EVT_MINUS_BREAK or event == 36 then --EVT_VIRTUAL_PREV then
		focusIndex = focusIndex - 1
		if focusIndex < 1 then
			focusIndex = #pages
		end
	end
end

--local function init()

LZ_runModule("LAOZHU/LuaUtils.lua")
LZ_runModule("LAOZHU/OTUtils.lua")

if LZ_isNeedCompile() then
	local pagePath = "TELEMETRY/common/comp.lua"
	curPage = LZ_runModule(pagePath)
	--curPage.init()
else
	LZ_isNeedCompile = nil
	LZ_markCompiled = nil
end
--end

--init()

return { run=run, background=background }


