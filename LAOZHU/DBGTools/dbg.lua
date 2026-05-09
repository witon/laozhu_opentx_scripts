-- 开发用分级日志：控制台 print + 可选环形缓冲，供 Widget / 遥测脚本绘制。
-- Widget 请先 LZ_runModule 本文件再 DBG_init，再加载 DBGWidgetLog.lua。
-- DBG_err：受 ERROR_LOG 控制（默认开）；DBG_dbg：受 DEBUG_LOG 控制（库默认关，入口 DBG_init 可打开）。
-- SHOW_LOG_SCREEN 为真且对应级别开关为真时，该行写入环形缓冲（见 DBGWidgetLog 覆盖层）。
-- 控制台与缓冲中均带前缀 [ERR] / [DBG]，调用处无需再拼接。
-- 开关与缓冲状态见全局表 DBG，判断时直接读 DBG.xxx，勿再封装 getter。

DBG = DBG
	or {
		ERROR_LOG = true,
		DEBUG_LOG = false,
		SHOW_LOG_SCREEN = false,
		LOG_MAX = 20,
		printTag = "[DBG]",
		logHistory = {},
		logScrollTop = 0,
	}

local function DBG_formatArgs(...)
	local n = select("#", ...)
	if n == 0 then
		return ""
	end
	local line = tostring(select(1, ...))
	for i = 2, n do
		line = line .. " " .. tostring(select(i, ...))
	end
	return line
end

local function DBG_appendHistory(prefixedLine)
	local h = DBG.logHistory
	h[#h + 1] = prefixedLine
	while #h > DBG.LOG_MAX do
		local len = #h
		for i = 1, len - 1 do
			h[i] = h[i + 1]
		end
		h[len] = nil
	end
end

function DBG_init(opts)
	if opts == nil then
		return
	end
	if opts.ERROR_LOG ~= nil then
		DBG.ERROR_LOG = opts.ERROR_LOG
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

function DBG_err(...)
	if not DBG.ERROR_LOG then
		return
	end
	local line = DBG_formatArgs(...)
	local prefixed = "[ERR] " .. line
	print(DBG.printTag, prefixed)
	if DBG.SHOW_LOG_SCREEN then
		DBG_appendHistory(prefixed)
	end
end

function DBG_dbg(...)
	if not DBG.DEBUG_LOG then
		return
	end
	local line = DBG_formatArgs(...)
	local prefixed = "[DBG] " .. line
	print(DBG.printTag, prefixed)
	if DBG.SHOW_LOG_SCREEN then
		DBG_appendHistory(prefixed)
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
