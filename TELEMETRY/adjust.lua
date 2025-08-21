gScriptDir = "/SCRIPTS/"
local bgFlag = false
--local k1 = 0
--local k2 = 0

local fun, err = loadScript(gScriptDir .. "TELEMETRY/common/LoadModule.lua", "bt")
fun()


local focusIndex = 1
local pages = {"adjust/GlobalVar.lua", "adjust/Output.lua", "adjust/SinkRate/SinkRate.lua", "adjust/LD/LD.lua", "adjust/Launch/Launch.lua"}
local curPage = nil

LZ_runModule("TELEMETRY/common/keyMap.lua")
local keyMap = KMgetKeyMap();
KMunload();


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

	bgFlag = false
	lcd.clear()
	e = keyMap[event];
--	if event ~= 0 then
--		print("event: " .. event)
--		k2 = k1
--		k1 = event
--	end

	if e ~= nil then
		event = e;
	end
--	if event ~= 0 then
--		print("event1: " .. event)
--	end
--	lcd.drawText(1, 1, "k1: " .. k1 .. " k2: " .. k2)
	-- if 1 == 1 then
	-- 	return
	-- end

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
	elseif event == 37 or event == 35 then --EVT_VIRTUAL_NEXT then
		focusIndex = focusIndex + 1
		if focusIndex > #pages then
			focusIndex = 1
		end
	elseif event == 38 or event == 36 then --EVT_VIRTUAL_PREV then
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
collectgarbage();
--end

--init()

return { run=run, background=background }


