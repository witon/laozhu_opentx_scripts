-- 彩屏 Widget：在 zone 内绘制调试日志覆盖层（依赖已加载的 dbg.lua）。
-- logHistory 中可能混排 DBG_err（[ERR]）与 DBG_dbg（[DBG]）行；ERROR_LOG/DEBUG_LOG 与 SHOW_LOG_SCREEN 决定哪些行会写入。
-- 调用前请先 DBG_logClampScroll(maxVisLog)，maxVisLog 须与本函数内部布局算法一致（或由调用方传入 rowH/hint 时再扩展）。

function DBGW_drawLogOverlay(zone, zoneBg, txtFlags, hintLine)
	if not DBG.SHOW_LOG_SCREEN then
		return
	end
	local z = zone
	local rowH = 14
	local ox = z.x + 2
	local oy = z.y + 2
	local logLinesTop = oy + rowH
	local logHintY = z.y + z.h - rowH - 2
	if logHintY < logLinesTop + rowH then
		logHintY = logLinesTop + rowH
	end
	local logAvailH = logHintY - logLinesTop - 2
	local maxVisLog = math.max(1, math.floor(logAvailH / rowH))

	local history = DBG.logHistory
	local maxLines = DBG.LOG_MAX
	local top = DBG.logScrollTop

	lcd.drawFilledRectangle(z.x, z.y, z.w, z.h, zoneBg)
	lcd.drawText(ox, oy, string.format("LOG %d/%d top=%d", #history, maxLines, top), txtFlags)
	local start = math.max(1, #history - maxVisLog - top + 1)
	local maxChars = math.max(8, math.floor((z.w - 4) / 6))
	for i = 1, maxVisLog do
		local idx = start + i - 1
		if idx <= #history then
			local line = history[idx]
			if #line > maxChars then
				line = string.sub(line, 1, maxChars)
			end
			lcd.drawText(ox, logLinesTop + (i - 1) * rowH, line, txtFlags)
		end
	end
	if #history == 0 then
		lcd.drawText(ox, logLinesTop, "(无日志)", txtFlags)
	end
	local hint = hintLine or "↑/↓滚动 长按ENT交权"
	lcd.drawText(ox, logHintY, hint, txtFlags)
end
