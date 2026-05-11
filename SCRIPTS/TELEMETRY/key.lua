gSDCardDir = "/"

local fun, err = loadScript(gSDCardDir .. "LAOZHU/uilib/LoadModule.lua", "bt")
fun()

-- 调试：见 LAOZHU/DBGTools/dbg.lua
local DBG_OPTS = {
	printTag = "[key]",
	ERROR_LOG = true,
	DEBUG_LOG = true,
	SHOW_LOG_SCREEN = false,
	LOG_MAX = 20,
}

local keyFramework = LZ_runModule(gSDCardDir .. "LAOZHU/key/keyFramework.lua")

local function init()
	LZ_runModule(gSDCardDir .. "LAOZHU/DBGTools/dbg.lua")
	DBG_init(DBG_OPTS)
end

local function background()
end

local function run(event)
	return keyFramework.runTelemetry(event)
end

return { run = run, background = background, init = init }
