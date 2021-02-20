gScriptDir = "/SCRIPTS/"
gConfigFileName = "adjust.cfg"
local bgFlag = false

local fun, err = loadScript(gScriptDir .. "TELEMETRY/common/LoadModule.lua", "bt")
fun()



local focusIndex = 1
local pages = {"adjust/GlobalVar.lua", "adjust/Output.lua", "adjust/SinkRate/SinkRate.lua"}
local curPage = nil
adjustCfg = nil

local function loadPage(index)
	local pagePath = gScriptDir .. "TELEMETRY/" .. pages[index]
	curPage = LZ_runModule(pagePath)
	curPage.init()
end


local function init()
	LZ_runModule(gScriptDir .. "LAOZHU/utils.lua")

	if LZ_isNeedCompile() then
		local pagePath = gScriptDir .. "TELEMETRY/common/comp.lua"
		curPage = LZ_runModule(pagePath)
		curPage.init()
		return
	end


	adjustCfg = LZ_runModule(gScriptDir .. "/LAOZHU/Cfg.lua")
	adjustCfg.readFromFile(gConfigFileName)

	LZ_runModule(gScriptDir .. "TELEMETRY/common/InputView.lua")
	LZ_runModule(gScriptDir .. "TELEMETRY/common/NumEdit.lua")
	LZ_runModule(gScriptDir .. "TELEMETRY/common/CheckBox.lua")
	
	LZ_runModule(gScriptDir .. "TELEMETRY/common/InputSelector.lua")
	LZ_runModule(gScriptDir .. "TELEMETRY/common/Selector.lua")
	LZ_runModule(gScriptDir .. "TELEMETRY/common/ModeSelector.lua")
	LZ_runModule(gScriptDir .. "TELEMETRY/common/OutputSelector.lua")
	LZ_runModule(gScriptDir .. "TELEMETRY/common/Fields.lua")
	LZ_runModule(gScriptDir .. "TELEMETRY/common/Button.lua")
	LZ_runModule(gScriptDir .. "TELEMETRY/common/TextEdit.lua")
	LZ_runModule(gScriptDir .. "TELEMETRY/common/CurveSelector.lua")
	LZ_runModule(gScriptDir .. "TELEMETRY/common/ViewMatrix.lua")

	initFieldsInfo()

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
	if curPage then
		local eventProcessed = curPage.run(event, getTime())
		if eventProcessed then
			return
		end
		if event == EVT_EXIT_BREAK then
			LZ_clearTable(curPage)
			collectgarbage()
			curPage = nil
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

return { run=run, init=init, background = background }


