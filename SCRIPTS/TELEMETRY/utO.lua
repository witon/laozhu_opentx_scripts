gSDCardDir = "/"
local fun, err = loadScript(gSDCardDir .. "LAOZHU/uilib/LoadModule.lua", "bt")
fun()
gAssertFlag = "ASSERT FLAG!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"

-- 调试：见 LAOZHU/DBGTools/dbg.lua；ERROR_LOG 控制 DBG_err，DEBUG_LOG 控制 DBG_dbg；SHOW_LOG_SCREEN 开时对应级别写入日志缓冲（遥测侧 DBGTelemetryLog 尚未绘制覆盖层，宜保持 false）。
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
