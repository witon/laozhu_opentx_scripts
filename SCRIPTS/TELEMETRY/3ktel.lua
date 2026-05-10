gSDCardDir = "/"
gConfigFileName = "3k.cfg"
local fun, err = loadScript(gSDCardDir .. "LAOZHU/uilib/LoadModule.lua", "bt")
fun()
gF3kCore = nil

f3kCfg = nil

local f3kFramework = LZ_runModule(gSDCardDir .. "LAOZHU/3k/f3kFramework.lua")

local function init()
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
