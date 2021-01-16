gScriptDir = "/SCRIPTS/"
gConfigFileName = "adjust.cfg"

local focusIndex = 1
local pages = {"adjust/GlobalVar.lua", "adjust/output.lua", "adjust/Setup.lua"}
local curPage = nil
adjustCfg = nil

local function loadPage(index)
	local pagePath = gScriptDir .. "TELEMETRY/" .. pages[index]
	curPage = dofile(pagePath)
	curPage.init()
end

local function init()
	dofile(gScriptDir .. "LAOZHU/utils.lua")
	dofile(gScriptDir .. "TELEMETRY/common/InputView.lua")
	dofile(gScriptDir .. "TELEMETRY/common/NumEdit.lua")
	dofile(gScriptDir .. "TELEMETRY/common/CheckBox.lua")
	
	dofile(gScriptDir .. "TELEMETRY/common/InputSelector.lua")
	dofile(gScriptDir .. "TELEMETRY/common/OutputSelector.lua")
	dofile(gScriptDir .. "TELEMETRY/common/Fields.lua")

	initFieldsInfo()

	adjustCfg = dofile(gScriptDir .. "/LAOZHU/Cfg.lua")
	adjustCfg.readFromFile(gConfigFileName)


end

local function run(event)
	lcd.clear()
	if curPage then
		local eventProcessed = curPage.run(event, getTime())
		if eventProcessed then
			return
		end
		if event == EVT_EXIT_BREAK then
			curPage = nil
		end
		return
	end
	for i=1, #pages, 1 do
		if focusIndex == i then
			lcd.drawText(2, i * 12, pages[i], INVERS)
		else
			lcd.drawText(2, i * 12, pages[i])
		end
	end
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
	-- return
	-- if curPage == nil then
	-- 	loadPage()
	-- end
	-- local eventProcessed = curPage.run(event, curTime)
	-- if eventProcessed then
	-- 	return
	-- end
	-- if event==38 then 
	-- 	displayIndex = displayIndex - 1
	-- 	if displayIndex < 1 then
	-- 		displayIndex = #pages
	-- 	end
	-- 	curPage = nil
	-- 	collectgarbage()
	-- 	gcTime = curTime
	-- elseif event == 37 then
	-- 	displayIndex = displayIndex + 1
	-- 	if displayIndex > #pages then
	-- 		displayIndex = 1
	-- 	end
	-- 	curPage = nil
	-- 	collectgarbage()
	-- 	gcTime = curTime
	-- end
end

return { run=run, init=init }


