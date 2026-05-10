LRecordListView = setmetatable({}, InputView)
LRecordListView.super = InputView

function LRecordListView:doKey(event)
    local records = self.lr.records
    local mv = self.maxVisRows or 3
    if event == EVT_ENTER_BREAK then
        local record = records[#records - self.selectedRow + 1]
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
        if self.selectedRow < #records then
            self.selectedRow = self.selectedRow + 1
        end
        if self.selectedRow - self.scrollRow > mv then
            self.scrollRow = self.scrollRow + 1
        end
        return true
    elseif event == 36 or event == 68 then
        if self.selectedRow > 1 then
            self.selectedRow = self.selectedRow - 1
        end
        if self.selectedRow - self.scrollRow < 1 then
            self.scrollRow = self.scrollRow - 1
        end
        return true
    end
    return false
end

function LRecordListView:draw(x, y, invers, option)
    local rs = LZ_ui.rowStep
    local hh = LZ_ui.headerRowHeight
    self.listAnchorY = y
    self.maxVisRows = math.max(1, math.floor((LCD_H - y - hh - 1) / rs))
    local rowFillW = math.max(1, LCD_W - x - 1)
    local rightX = x + LCD_W - 1

    lcd.drawFilledRectangle(x, y, LCD_W, hh, FORCE)
    lcd.drawText(x, y, "time", LZ_ui.font + LEFT + INVERS)
    lcd.drawText(57 + x, y, "ele", LZ_ui.font + RIGHT + INVERS)
    lcd.drawText(80 + x, y, "f1", LZ_ui.font + RIGHT + INVERS)
    lcd.drawText(103 + x, y, "rud", LZ_ui.font + RIGHT + INVERS)
    lcd.drawText(rightX, y, "h", LZ_ui.font + RIGHT + INVERS)

    local records = self.lr.records
    if records ~= nil then
        local scrollRow = self.scrollRow
        local ly0 = y + hh + 1
        local shown = 0
        for i = scrollRow + 1, #records, 1 do
            if shown >= self.maxVisRows then
                break
            end
            local index = #records - i + 1
            if #records > self.lr.recordPoint then
                index = self.lr.recordPoint - i + 1
            end
            if index < 1 then
                index = index + self.lr.maxRecordCount
            end
            local record = records[index]
            local ly = ly0 + (i - scrollRow - 1) * rs
            local op = 0
            if i == self.selectedRow and self.focusState == 2 then
                op = INVERS
                lcd.drawFilledRectangle(x, ly - LZ_ui.rowFillTopPad, rowFillW, rs + LZ_ui.rowFillTopPad + LZ_ui.rowFillBottomPad, FORCE)
            end
            lcd.drawText(x, ly, LZ_formatTimeStamp(record.startTime), LZ_ui.font + LEFT + op)
            lcd.drawText(57 + x, ly, record.ele, LZ_ui.font + RIGHT + op)
            lcd.drawText(80 + x, ly, record.flap1, LZ_ui.font + RIGHT + op)
            lcd.drawText(103 + x, ly, record.rudder, LZ_ui.font + RIGHT + op)
            lcd.drawNumber(rightX, ly, LRgetRecordLaunchAlt(record), LZ_ui.font + RIGHT + op)
            if record.invalid then
                local ym = ly + math.floor(rs / 2)
                if op == INVERS then
                    lcd.drawLine(x, ym, x + rowFillW, ym, SOLID, ERASE)
                else
                    lcd.drawLine(x, ym, x + rowFillW, ym, SOLID, FORCE)
                end
            end
            shown = shown + 1
        end
    end
end

function LRecordListView:new()
    self.__index = self
    local o = self.super:new()
    setmetatable(o, self)
    o.scrollRow = 0
    o.selectedRow = 1
    o.records = nil
    o.lr = nil
    o.maxVisRows = 3
    return o
end
