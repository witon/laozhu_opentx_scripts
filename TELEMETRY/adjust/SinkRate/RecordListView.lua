
function RLVdoKey(recordListView, event)
    if event ==  EVT_ENTER_BREAK then
        local record = recordListView.records[#recordListView.records - recordListView.selectedRow + 1]
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
        if recordListView.selectedRow - recordListView.scrollRow > 3 then
            recordListView.scrollRow = recordListView.scrollRow + 1
        end
        return true
    elseif event == 36 or event == 67 then
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
    lcd.drawFilledRectangle(0, 19, 128, 9, FORCE)
    lcd.drawText(0, 20, "time", SMLSIZE + LEFT + INVERS)
    lcd.drawText(57, 20, "ele", SMLSIZE + RIGHT + INVERS)
    lcd.drawText(80, 20, "f1", SMLSIZE + RIGHT + INVERS)
    lcd.drawText(103, 20, "f2", SMLSIZE + RIGHT + INVERS)
    lcd.drawText(128, 20, "sr", SMLSIZE + RIGHT + INVERS)

    local records = recordListView.records
    if records ~= nil then
        local scrollRow = recordListView.scrollRow
        for i=scrollRow+1, #records, 1 do
            local record = records[#records - i + 1]
            local y = 30 + (i-scrollRow-1) * 10
            local op = 0
            if i==recordListView.selectedRow and recordListView.focusState == 2 then
                op = INVERS
                lcd.drawFilledRectangle(0, y-1, 127, 8, FORCE)
            end
            lcd.drawText(0, y, LZ_formatTimeStamp(record.startTime), SMLSIZE + LEFT + op)
            lcd.drawText(57, y, record.ele, SMLSIZE + RIGHT + op)
            lcd.drawText(80, y, record.flap1, SMLSIZE + RIGHT + op)
            lcd.drawText(103, y, record.flap2, SMLSIZE + RIGHT + op)
            lcd.drawNumber(128, y, SRRgetRecordSinkRate(record), SMLSIZE + RIGHT + op)
            if record.invalid then
                if op == INVERS then
                    lcd.drawLine(0, y+3, 127, y+3, SOLID, ERASE)
                else
                    lcd.drawLine(0, y+3, 127, y+3, SOLID, FORCE)
                end
            end
        end
    end

    if recordListView.focusState == 1 or recordListView.focusState == 2 then
        lcd.drawLine(0, 18, 127, 18, SOLID, FORCE) -- -
        lcd.drawLine(0, 63, 127, 63, SOLID, FORCE) -- -
        lcd.drawLine(0, 18, 0, 63, SOLID, FORCE)  -- |
        lcd.drawLine(127, 18, 127, 63, SOLID, FORCE) -- |
    end


end

function RLVnewRecordListView()
    return {scrollRow = 0, selectedRow = 1, records = nil, focusState = 0, doKey = RLVdoKey, draw = RLVdraw}
end

