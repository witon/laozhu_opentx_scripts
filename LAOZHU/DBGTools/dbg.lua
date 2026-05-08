-- 开发用调试日志：控制台 print + 可选环形缓冲，供 Widget / 遥测脚本绘制。
-- Widget 请先 LZ_runModule 本文件再 DBG_init，再加载 DBGWidgetLog.lua。
-- DEBUG_LOG 为总开关：DBG_dbg 内若为关则立刻返回（不 print、不入缓冲）；调用处不必再判断。
-- 开关与缓冲状态见全局表 DBG，判断时直接读 DBG.xxx，勿再封装 getter。

DBG = DBG
	or {
		DEBUG_LOG = false,
		SHOW_LOG_SCREEN = false,
		LOG_MAX = 20,
		printTag = "[DBG]",
		logHistory = {},
		logScrollTop = 0,
	}

function DBG_init(opts)
	if opts == nil then
		return
	end
	if opts.DEBUG_LOG ~= nil then
		DBG.DEBUG_LOG = opts.DEBUG_LOG
	end
	if opts.SHOW_LOG_SCREEN ~= nil then
		DBG.SHOW_LOG_SCREEN = opts.SHOW_LOG_SCREEN
	end
	if opts.LOG_MAX ~= nil then
		DBG.LOG_MAX = opts.LOG_MAX
	end
	if opts.printTag ~= nil then
		DBG.printTag = opts.printTag
	end
end

function DBG_dbg(...)
	if not DBG.DEBUG_LOG then
		return
	end
	local n = select("#", ...)
	local parts = {}
	for i = 1, n do
		parts[i] = tostring(select(i, ...))
	end
	local line = table.concat(parts, " ")
	print(DBG.printTag, line)
	if DBG.SHOW_LOG_SCREEN then
		DBG.logHistory[#DBG.logHistory + 1] = line
		if #DBG.logHistory > DBG.LOG_MAX then
			table.remove(DBG.logHistory, 1)
		end
	end
end

function DBG_logOnMappedKey(mappedEvent)
	if not DBG.SHOW_LOG_SCREEN then
		return
	end
	if mappedEvent == 36 then
		DBG.logScrollTop = DBG.logScrollTop + 1
	elseif mappedEvent == 35 then
		DBG.logScrollTop = math.max(0, DBG.logScrollTop - 1)
	end
end

function DBG_logClampScroll(maxVisLog)
	if not DBG.SHOW_LOG_SCREEN then
		return
	end
	DBG.logScrollTop = math.min(DBG.logScrollTop, math.max(0, #DBG.logHistory - maxVisLog))
end
