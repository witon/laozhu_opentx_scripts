gScriptDir = "/SCRIPTS/"


local displayIndex = 1
local pages = {"adjust/output.lua"}
local curPage = nil

local function loadPage()
	local pagePath = gScriptDir .. "TELEMETRY/" .. pages[displayIndex]
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
	

	loadPage()
end

local function run(event)
	lcd.clear()

	if curPage == nil then
		loadPage()
	end
	local eventProcessed = curPage.run(event, curTime)
	if eventProcessed then
		return
	end
end

return { run=run, init=init }


