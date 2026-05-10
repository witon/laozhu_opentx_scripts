-- 调试日志列表视图：单一 DBGLogLVdraw；行距与标题带使用 LZ_ui（UiParams.lua）。
-- 须已加载 dbg.lua 且已 LZ_uiInit；数据源为 DBG.logHistory / DBG.logScrollTop。

function DBGLogLVmaxVisForRect(w, h)
	local rs = LZ_ui.rowStep
	local hh = LZ_ui.headerRowHeight
	local pad = 2
	local oy = pad
	local logLinesTop = oy + hh
	local logHintY = h - rs - pad
	if logHintY < logLinesTop + rs then
		logHintY = logLinesTop + rs
	end
	local logAvailH = logHintY - logLinesTop - 2
	return math.max(1, math.floor(logAvailH / rs))
end

function DBGLogLVdraw(view, x, y, w, h, zoneBg, txtFlags, hintLine)
	if not DBG or not DBG.SHOW_LOG_SCREEN then
		return
	end
	local rs = LZ_ui.rowStep
	local hh = LZ_ui.headerRowHeight
	local pad = 2
	local ox = x + pad
	local oy = y + pad
	local logLinesTop = oy + hh
	local logHintY = y + h - rs - pad
	if logHintY < logLinesTop + rs then
		logHintY = logLinesTop + rs
	end
	local logAvailH = logHintY - logLinesTop - 2
	local maxVisRows = math.max(1, math.floor(logAvailH / rs))
	if view ~= nil then
		view.maxVisRows = maxVisRows
	end

	local history = DBG.logHistory
	local maxLines = DBG.LOG_MAX
	local top = DBG.logScrollTop

	lcd.drawFilledRectangle(x, y, w, h, zoneBg)
	lcd.drawText(ox, oy, string.format("LOG %d/%d top=%d", #history, maxLines, top), txtFlags)
	local start = math.max(1, #history - maxVisRows - top + 1)
	local maxChars = math.max(8, math.floor((w - 4) / 6))
	for i = 1, maxVisRows do
		local idx = start + i - 1
		if idx <= #history then
			local line = history[idx]
			if #line > maxChars then
				line = string.sub(line, 1, maxChars)
			end
			lcd.drawText(ox, logLinesTop + (i - 1) * rs, line, txtFlags)
		end
	end
	if #history == 0 then
		lcd.drawText(ox, logLinesTop, "(无日志)", txtFlags)
	end
	local hint = hintLine or "↑/↓滚动 长按ENT交权"
	lcd.drawText(ox, logHintY, hint, txtFlags)
end

function DBGLogLVnew()
	return {
		maxVisRows = 1,
	}
end

function DBGLogLVunload()
	DBGLogLVmaxVisForRect = nil
	DBGLogLVdraw = nil
	DBGLogLVnew = nil
	DBGLogLVunload = nil
end
