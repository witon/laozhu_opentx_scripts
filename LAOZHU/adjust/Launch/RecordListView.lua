
function RLVdoKey(recordListView, event)
    local mv = recordListView.maxVisRows or 3
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
        if recordListView.selectedRow - recordListView.scrollRow > mv then
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

function RLVdraw(recordListView, x, y, invers, option)
    local rs = LZ_ui.rowStep
    local hh = LZ_ui.headerRowHeight
    recordListView.maxVisRows = math.max(1, math.floor((LCD_H - y - hh - 1) / rs))
    local rowFillW = math.max(1, LCD_W - x - 1)
    local rightX = x + LCD_W - 1

    lcd.drawFilledRectangle(x, y, LCD_W, hh, FORCE)
    lcd.drawText(x, y, "time", LZ_ui.font + LEFT + INVERS)
    lcd.drawText(57 + x, y, "ele", LZ_ui.font + RIGHT + INVERS)
    lcd.drawText(80 + x, y, "f1", LZ_ui.font + RIGHT + INVERS)
    lcd.drawText(103 + x, y, "f2", LZ_ui.font + RIGHT + INVERS)
    lcd.drawText(rightX, y, "sr", LZ_ui.font + RIGHT + INVERS)

    local records = recordListView.records
    if records ~= nil then
        local scrollRow = recordListView.scrollRow
        local ly0 = y + hh + 1
        local shown = 0
        for i = scrollRow + 1, #records, 1 do
            if shown >= recordListView.maxVisRows then
                break
            end
            local record = records[#records - i + 1]
            local rowY = ly0 + (i - scrollRow - 1) * rs
            local op = 0
            if i == recordListView.selectedRow and recordListView.focusState == 2 then
                op = INVERS
                lcd.drawFilledRectangle(x, rowY - LZ_ui.rowFillTopPad, rowFillW, rs + LZ_ui.rowFillTopPad + LZ_ui.rowFillBottomPad, FORCE)
            end
            lcd.drawText(x, rowY, LZ_formatTimeStamp(record.startTime), LZ_ui.font + LEFT + op)
            lcd.drawText(57 + x, rowY, record.ele, LZ_ui.font + RIGHT + op)
            lcd.drawText(80 + x, rowY, record.flap1, LZ_ui.font + RIGHT + op)
            lcd.drawText(103 + x, rowY, record.flap2, LZ_ui.font + RIGHT + op)
            lcd.drawNumber(rightX, rowY, SRRgetRecordSinkRate(record), LZ_ui.font + RIGHT + op)
            if record.invalid then
                local ym = rowY + math.floor(rs / 2)
                if op == INVERS then
                    lcd.drawLine(x, ym, x + rowFillW, ym, SOLID, ERASE)
                else
                    lcd.drawLine(x, ym, x + rowFillW, ym, SOLID, FORCE)
                end
            end
            shown = shown + 1
        end
    end

    if recordListView.focusState == 1 or recordListView.focusState == 2 then
        local mv = recordListView.maxVisRows or 3
        local boxBot = math.min(LCD_H - 1, y + hh + 1 + mv * rs)
        lcd.drawLine(x, y, rightX, y, SOLID, FORCE)
        lcd.drawLine(x, boxBot, rightX, boxBot, SOLID, FORCE)
        lcd.drawLine(x, y, x, boxBot, SOLID, FORCE)
        lcd.drawLine(rightX, y, rightX, boxBot, SOLID, FORCE)
    end
end

function RLVnewRecordListView()
    return { scrollRow = 0, selectedRow = 1, records = nil, focusState = 0, maxVisRows = 3, doKey = RLVdoKey, draw = RLVdraw }
end

function RLVunload()
    RLVdoKey = nil
    RLVdraw = nil
    RLVnewRecordListView = nil
    RLVunload = nil
end
