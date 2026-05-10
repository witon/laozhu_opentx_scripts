gSDCardDir = "/"

local fun, err = loadScript(gSDCardDir .. "LAOZHU/uilib/LoadModule.lua", "bt")
fun()

local adjustFramework = LZ_runModule(gSDCardDir .. "LAOZHU/adjust/adjustFramework.lua")
adjustFramework.initFramework()

local function background()
	adjustFramework.background()
end

local function run(event)
	adjustFramework.run(event)
end

return { run = run, background = background }
