LRecordListView = setmetatable({}, InputView)
LRecordListView.super = InputView

function LRecordListView:doKey(event)
    local records = self.lr.records
    if event ==  EVT_ENTER_BREAK then
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
        if self.selectedRow - self.scrollRow > 3 then
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
    lcd.drawFilledRectangle(0, 19, 128, rs, FORCE)
    lcd.drawText(0, 20, "time", LZ_ui.font + LEFT + INVERS)
    lcd.drawText(57, 20, "ele", LZ_ui.font + RIGHT + INVERS)
    lcd.drawText(80, 20, "f1", LZ_ui.font + RIGHT + INVERS)
    lcd.drawText(103, 20, "rud", LZ_ui.font + RIGHT + INVERS)
    lcd.drawText(128, 20, "h", LZ_ui.font + RIGHT + INVERS)

    local records = self.lr.records
    if records ~= nil then
        local scrollRow = self.scrollRow
        for i=scrollRow+1, #records, 1 do
            local index = #records - i + 1
            if #records > self.lr.recordPoint then
                index =  self.lr.recordPoint - i + 1
            end
            if index < 1 then
                index = index + self.lr.maxRecordCount
            end
            local record = records[index]
            local ry = 30 + (i-scrollRow-1) * rs
            local op = 0
            if i==self.selectedRow and self.focusState == 2 then
                op = INVERS
                lcd.drawFilledRectangle(0, ry-1, 127, rs, FORCE)
            end
            lcd.drawText(0, ry, LZ_formatTimeStamp(record.startTime), LZ_ui.font + LEFT + op)
            lcd.drawText(57, ry, record.ele, LZ_ui.font + RIGHT + op)
            lcd.drawText(80, ry, record.flap1, LZ_ui.font + RIGHT + op)
            lcd.drawText(103, ry, record.rudder, LZ_ui.font + RIGHT + op)
            lcd.drawNumber(128, ry, LRgetRecordLaunchAlt(record), LZ_ui.font + RIGHT + op)
            if record.invalid then
                local ym = ry + math.floor(rs / 2)
                if op == INVERS then
                    lcd.drawLine(0, ym, 127, ym, SOLID, ERASE)
                else
                    lcd.drawLine(0, ym, 127, ym, SOLID, FORCE)
                end
            end
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
    return o 
end