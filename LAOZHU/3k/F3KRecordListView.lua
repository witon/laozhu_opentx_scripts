
function F3KRLVdoKey(recordListView, event)
    if event ==  EVT_ENTER_BREAK then
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
        if recordListView.selectedRow - recordListView.scrollRow > 5 then
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
    lcd.drawFilledRectangle(0, 0, 128, rs, FORCE)
    lcd.drawText(0, 0, "LauTime", LZ_ui.font + LEFT + INVERS)
    lcd.drawText(84, 0, "LauAlt", LZ_ui.font + RIGHT + INVERS)
    lcd.drawText(128, 0, "FTime", LZ_ui.font + RIGHT + INVERS)

    local records = recordListView.records
    if records ~= nil then
        local scrollRow = recordListView.scrollRow
        for i=scrollRow+1, #records, 1 do
            local record = records[#records - i + 1]
            local ly = rs + 1 + (i-scrollRow-1) * rs
            local op = 0
            if i==recordListView.selectedRow and recordListView.focusState == 2 then
                op = INVERS
                lcd.drawFilledRectangle(0, ly-1, 127, rs, FORCE)
            end
			lcd.drawText(1, ly, "(" .. record.index .. ") ", LZ_ui.font + LEFT + op)
			lcd.drawText(lcd.getLastRightPos(), ly, LZ_formatTimeStamp(record.flightStartTime), LZ_ui.font + LEFT + op)
            lcd.drawNumber(85, ly, record.launchAlt, LZ_ui.font + RIGHT + op)
            lcd.drawText(128, ly, LZ_formatTime(record.flightTime), LZ_ui.font + RIGHT + op)

            if record.invalid then
                local mid = ly + math.floor(rs / 2)
                if op == INVERS then
                    lcd.drawLine(0, mid, 127, mid, SOLID, ERASE)
                else
                    lcd.drawLine(0, mid, 127, mid, SOLID, FORCE)
                end
            end
        end
    end
end

function F3KRLVScrollTo(recordListView, line)
    recordListView.selectedRow = line
    if line > 5 then
        recordListView.scrollRow = line - 5
    else
        recordListView.scrollRow = 0
    end
end


function F3KRLVnewRecordListView()
    return {scrollRow = 0, selectedRow = 1, records = nil, focusState = 0, doKey = F3KRLVdoKey, draw = F3KRLVdraw}
end

function F3KRLVunload()
    F3KRLVdoKey = nil
    F3KRLVdraw = nil
    F3KRLVnewRecordListView = nil
    F3KRLVScrollTo = nil
    F3KRLVunload = nil
end