gSDCardDir = "/"
gConfigFileName = "5j.cfg"
local fun, err = loadScript(gSDCardDir .. "LAOZHU/uilib/LoadModule.lua", "bt")
fun()
gFlightState = nil
f5jCfg = nil
gF5jCore = nil

local DBG_OPTS = {
	printTag = "[5jtel]",
	ERROR_LOG = true,
	DEBUG_LOG = false,
	SHOW_LOG_SCREEN = false,
}

local f5jFramework = LZ_runModule(gSDCardDir .. "LAOZHU/5j/f5jFramework.lua")

local function init()
	LZ_runModule(gSDCardDir .. "LAOZHU/DBGTools/dbg.lua")
	local _, radio = getVersion()
	if string.find(tostring(radio), "simu", 1, true) then
		DBG_OPTS.DEBUG_LOG = true
	end
	DBG_init(DBG_OPTS)
	f5jFramework.initFramework()
end

local function background()
	if gF5jCore == nil then
		return
	end
	gF5jCore.run()
end

local function run(event)
	return f5jFramework.run(event)
end

return { run = run, init = init, background = background }
