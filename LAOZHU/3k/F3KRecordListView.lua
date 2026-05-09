function F3KRLVdoKey(recordListView, event)
	local maxVis = recordListView.maxVisRows
	if event == EVT_ENTER_BREAK then
		local record = recordListView.records[#recordListView.records - recordListView.selectedRow + 1]
		if record == nil then
			return true
		end
		if record.invalid ~= nil then
			record.invalid = not record.invalid
		else
			record.invalid = true
		end
		return true
	elseif event == 35 or event == 67 then
		if recordListView.selectedRow < #recordListView.records then
			recordListView.selectedRow = recordListView.selectedRow + 1
		end
		if recordListView.selectedRow - recordListView.scrollRow > maxVis then
			recordListView.scrollRow = recordListView.scrollRow + 1
		end
		return true
	elseif event == 36 or event == 68 then
		if recordListView.selectedRow > 1 then
			recordListView.selectedRow = recordListView.selectedRow - 1
		end
		if recordListView.selectedRow - recordListView.scrollRow < 1 then
			recordListView.scrollRow = recordListView.scrollRow - 1
		end
		return true
	end
	return false
end

function F3KRLVdraw(recordListView, x, y, invers, option)
	local rs = LZ_ui.rowStep
	local maxVis = recordListView.maxVisRows
	local lauAltRight = x + math.floor(84 * LCD_W / 128)
	local lauNumX = x + math.floor(85 * LCD_W / 128)
	local rightX = x + LCD_W - 1
	local rowFillW = math.max(1, LCD_W - 1)

	lcd.drawFilledRectangle(x, y, LCD_W, rs, FORCE)
	lcd.drawText(x, y, "LauTime", LZ_ui.font + LEFT + INVERS)
	lcd.drawText(lauAltRight, y, "LauAlt", LZ_ui.font + RIGHT + INVERS)
	lcd.drawText(rightX, y, "FTime", LZ_ui.font + RIGHT + INVERS)

	local records = recordListView.records
	if records ~= nil then
		local scrollRow = recordListView.scrollRow
		local shown = 0
		for i = scrollRow + 1, #records, 1 do
			if shown >= maxVis then
				break
			end
			local record = records[#records - i + 1]
			local ly = y + rs + 1 + (i - scrollRow - 1) * rs
			local op = 0
			if i == recordListView.selectedRow and recordListView.focusState == 2 then
				op = INVERS
				lcd.drawFilledRectangle(x, ly - 1, rowFillW, rs, FORCE)
			end
			local prefix = "(" .. record.index .. ") "
			local rowFlags = LZ_ui.font + LEFT + op
			local tsX
			if lcd.sizeText ~= nil then
				tsX = x + 1 + select(1, lcd.sizeText(prefix, rowFlags))
				lcd.drawText(x + 1, ly, prefix, rowFlags)
			else
				lcd.drawText(x + 1, ly, prefix, rowFlags)
				tsX = lcd.getLastRightPos()
			end
			lcd.drawText(tsX, ly, LZ_formatTimeStamp(record.flightStartTime), rowFlags)
			lcd.drawNumber(lauNumX, ly, record.launchAlt, LZ_ui.font + RIGHT + op)
			lcd.drawText(rightX, ly, LZ_formatTime(record.flightTime), LZ_ui.font + RIGHT + op)

			if record.invalid then
				local mid = ly + math.floor(rs / 2)
				if op == INVERS then
					lcd.drawLine(x, mid, x + rowFillW, mid, SOLID, ERASE)
				else
					lcd.drawLine(x, mid, x + rowFillW, mid, SOLID, FORCE)
				end
			end
			shown = shown + 1
		end
	end
end

function F3KRLVScrollTo(recordListView, line)
	recordListView.selectedRow = line
	local m = recordListView.maxVisRows
	if line > m then
		recordListView.scrollRow = line - m
	else
		recordListView.scrollRow = 0
	end
end


function F3KRLVnewRecordListView()
	local rs = LZ_ui.rowStep
	local maxVisRows = math.max(1, math.floor((LCD_H - rs - 1) / rs))
	return {
		scrollRow = 0,
		selectedRow = 1,
		records = nil,
		focusState = 0,
		maxVisRows = maxVisRows,
		doKey = F3KRLVdoKey,
		draw = F3KRLVdraw,
	}
end

function F3KRLVunload()
	F3KRLVdoKey = nil
	F3KRLVdraw = nil
	F3KRLVnewRecordListView = nil
	F3KRLVScrollTo = nil
	F3KRLVunload = nil
end
