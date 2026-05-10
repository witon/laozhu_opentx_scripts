gSDCardDir = "/"
local fun, err = loadScript(gSDCardDir .. "LAOZHU/uilib/LoadModule.lua", "bt")
fun()
gAssertFlag = "ASSERT FLAG!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"

-- 调试：见 LAOZHU/DBGTools/dbg.lua；SHOW_LOG_SCREEN 开时写入 DBG.logHistory；utOFramework 在遥测模式下用 DBGLogListView 于屏底绘制（见 LAOZHU/DBGTools/DBGLogListView.lua）。
local DBG_OPTS = {
	printTag = "[utO]",
	ERROR_LOG = true,
	DEBUG_LOG = true,
	SHOW_LOG_SCREEN = false,
	LOG_MAX = 20,
}

local framework = LZ_runModule(gSDCardDir .. "LAOZHU/utO/utOFramework.lua")

local function init()
	LZ_runModule(gSDCardDir .. "LAOZHU/DBGTools/dbg.lua")
	DBG_init(DBG_OPTS)
	framework.initFramework()
end

local function run(event)
	framework.run(event)
end

return { run = run, init = init }
