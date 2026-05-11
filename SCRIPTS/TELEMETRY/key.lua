gSDCardDir = "/"

local fun, err = loadScript(gSDCardDir .. "LAOZHU/uilib/LoadModule.lua", "bt")
fun()

local keyFramework = LZ_runModule(gSDCardDir .. "LAOZHU/key/keyFramework.lua")

local function background()
end

local function run(event)
	return keyFramework.runTelemetry(event)
end

return { run = run, background = background }
