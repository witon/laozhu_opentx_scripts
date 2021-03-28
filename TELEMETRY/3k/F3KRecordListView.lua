
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
    lcd.drawFilledRectangle(0, 0, 128, 8, FORCE)
    lcd.drawText(0, 0, "LauTime", SMLSIZE + LEFT + INVERS)
    lcd.drawText(84, 0, "LauAlt", SMLSIZE + RIGHT + INVERS)
    lcd.drawText(128, 0, "FTime", SMLSIZE + RIGHT + INVERS)

    local records = recordListView.records
    if records ~= nil then
        local scrollRow = recordListView.scrollRow
        for i=scrollRow+1, #records, 1 do
            local record = records[#records - i + 1]
            local y = 10 + (i-scrollRow-1) * 8
            local op = 0
            if i==recordListView.selectedRow and recordListView.focusState == 2 then
                op = INVERS
                lcd.drawFilledRectangle(0, y-1, 127, 8, FORCE)
            end
			lcd.drawText(1, y, "(" .. record.index .. ") ", SMLSIZE + LEFT + op)
			lcd.drawText(lcd.getLastRightPos(), y, LZ_formatTimeStamp(record.flightStartTime), SMLSIZE + LEFT + op)
            lcd.drawNumber(85, y, record.launchAlt, SMLSIZE + RIGHT + op)
            lcd.drawText(128, y, LZ_formatTime(record.flightTime), SMLSIZE + RIGHT + op)
 
            if record.invalid then
                if op == INVERS then
                    lcd.drawLine(0, y+3, 127, y+3, SOLID, ERASE)
                else
                    lcd.drawLine(0, y+3, 127, y+3, SOLID, FORCE)
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