gSDCardDir = "/"
gConfigFileName = "3k.cfg"
local fun, err = loadScript(gSDCardDir .. "LAOZHU/uilib/LoadModule.lua", "bt")
fun()
gF3kCore = nil

f3kCfg = nil

local Nav = LZ_runModule(gSDCardDir .. "LAOZHU/3k/f3kTelNav.lua")
local state = {
	pages = Nav.FLIGHT_PAGE_PATHS,
	displayIndex = 1,
	curPage = nil,
	lastEvent = 0,
}


LZ_runModule(gSDCardDir .. "LAOZHU/uilib/keyMap.lua")
local keyMap = KMgetKeyMap();
KMunload();


local function init()
	Nav.telInit(state)
end


local function background()
	if gF3kCore == nil then
		return
	end
	gF3kCore.run()
end

local function run(event)

	e = keyMap[event];
	if false then
		if event ~= 0 then
			lcd.clear()
			lcd.drawText(10, 10, "event:", LZ_ui.font)
			lcd.drawNumber(10, 20, event, LZ_ui.font)
			lcd.drawText(10, 30, "e:", LZ_ui.font)
			if e ~= nil then
				lcd.drawNumber(10, 40, e, LZ_ui.font)
			end
		end
		return
	else
		lcd.clear()
	end

	if e ~= nil then
		event = e;
	end

	local curTime = getTime()
	if state.curPage == nil then
		Nav.loadPage(state)
	end
	
	
	local eventProcessed = state.curPage.run(event, curTime)
	if eventProcessed then
		return
	end
	Nav.handleNavAfterPage(state, event)
	return true;


end

return { run=run, init=init, background=background }
