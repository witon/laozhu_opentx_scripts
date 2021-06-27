gScriptDir = "/SCRIPTS/"
local bgFlag = false

local fun, err = loadScript(gScriptDir .. "TELEMETRY/common/LoadModule.lua", "bt")
fun()



local focusIndex = 1
local pages = {"adjust/GlobalVar.lua", "adjust/Output.lua", "adjust/SinkRate/SinkRate.lua"}
local curPage = nil

local function loadPage(index)
	local pagePath = "TELEMETRY/" .. pages[index]
	curPage = LZ_runModule(pagePath)
	curPage.init()
end


local function init()
	LZ_runModule("LAOZHU/utils.lua")

	if LZ_isNeedCompile() then
		local pagePath = "TELEMETRY/common/comp.lua"
		curPage = LZ_runModule(pagePath)
		curPage.init()
		return
	end


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


