-- 黑白屏遥测脚本上的日志绘制：尚未实现。
-- 使用前请先 LZ_runModule LAOZHU/DBGTools/dbg.lua 并 DBG_init；
-- 分级：DBG_err（ERROR_LOG）、DBG_dbg（DEBUG_LOG）；SHOW_LOG_SCREEN 为真时写入 DBG.logHistory，行前缀 [ERR]/[DBG]。
-- 实现时可读 DBG.logHistory、DBG.logScrollTop，并复用 DBG_logOnMappedKey、DBG_logClampScroll 等。

function DBGT_drawLogOverlay()
	return false
end
