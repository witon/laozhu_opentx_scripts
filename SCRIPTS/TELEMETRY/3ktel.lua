gSDCardDir = "/"
gConfigFileName = "3k.cfg"
local fun, err = loadScript(gSDCardDir .. "LAOZHU/uilib/LoadModule.lua", "bt")
fun()
gF3kCore = nil

f3kCfg = nil

local DBG_OPTS = {
	printTag = "[3ktel]",
	ERROR_LOG = true,
	DEBUG_LOG = false,
	SHOW_LOG_SCREEN = false,
}

local f3kFramework = LZ_runModule(gSDCardDir .. "LAOZHU/3k/f3kFramework.lua")

local function init()
	LZ_runModule(gSDCardDir .. "LAOZHU/DBGTools/dbg.lua")
	local _, radio = getVersion()
	if string.find(tostring(radio), "simu", 1, true) then
		DBG_OPTS.DEBUG_LOG = true
	end
	DBG_init(DBG_OPTS)
	f3kFramework.initFramework()
end

local function background()
	if gF3kCore == nil then
		return
	end
	gF3kCore.run()
end

local function run(event)
	lcd.clear()
	return f3kFramework.run(event)
end

return { run=run, init=init, background=background }
