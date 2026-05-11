gSDCardDir = "/"
gConfigFileName = "5j.cfg"
local fun, err = loadScript(gSDCardDir .. "LAOZHU/uilib/LoadModule.lua", "bt")
fun()
gFlightState = nil
f5jCfg = nil
gF5jCore = nil

local f5jFramework = LZ_runModule(gSDCardDir .. "LAOZHU/5j/f5jFramework.lua")

local function init()
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
