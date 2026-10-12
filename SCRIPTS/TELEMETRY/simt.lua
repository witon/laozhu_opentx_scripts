-- simu-cli 用例的唯一遥测入口。Python 把用例文件名写入 SCRIPTS/simu.case，
-- 本脚本再加载 SCRIPTS/simu/ 下对应文件（由 harness 从 test/simu/cases 拷入临时 SD）。
-- 批量用例 return 一个函数，或 return 非空函数列表，在 init 里跑完。
-- 按键用例 return { init = ..., run = function(event) ... end }，run 收到固件按键事件。
-- 断言失败用 error/assert。
gSDCardDir = "/"
local fun, err = loadScript(gSDCardDir .. "LAOZHU/uilib/LoadModule.lua", "bt")
fun()

local DBG_OPTS = {
	printTag = "[simt]",
	ERROR_LOG = true,
	DEBUG_LOG = true,
	SHOW_LOG_SCREEN = false,
}

local function readCaseName()
	local f = io.open(gSDCardDir .. "SCRIPTS/simu.case", "r")
	if f == nil then
		error("no simu.case")
	end
	local content = io.read(f, 200)
	io.close(f)
	local name = string.match(content or "", "([^\r\n]+)")
	if name == nil or name == "" then
		error("empty simu.case")
	end
	return name
end

local session = nil

local function runResult(result)
	if type(result) == "function" then
		result()
		return
	end
	if type(result) ~= "table" or #result == 0 then
		error("case has no tests")
	end
	for i = 1, #result do
		result[i]()
	end
end

local function startCase()
	local name = readCaseName()
	DBG_dbg("simu", name)
	local result = LZ_runModule(gSDCardDir .. "SCRIPTS/simu/" .. name)
	if result == nil then
		error("load case failed " .. name)
	end
	if type(result) == "table" and type(result.run) == "function" then
		session = result
		if session.init then
			session.init()
		end
		DBG_dbg("simu ready")
		return
	end
	runResult(result)
	DBG_dbg("simu ok")
end

local function init()
	LZ_runModule(gSDCardDir .. "LAOZHU/DBGTools/dbg.lua")
	DBG_init(DBG_OPTS)
	local ok, errMsg = pcall(startCase)
	if not ok then
		DBG_err("simu", errMsg)
		error(errMsg)
	end
end

local function run(event)
	if session == nil or session.run == nil then
		return
	end
	local ok, errMsg = pcall(session.run, event)
	if not ok then
		DBG_err("simu", errMsg)
		session = nil
		error(errMsg)
	end
end

return { run = run, init = init }
