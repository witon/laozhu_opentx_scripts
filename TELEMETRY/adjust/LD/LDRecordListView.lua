LDRecordListView = setmetatable({}, InputView)
LDRecordListView.super = InputView

function LDRecordListView:doKey(event)
    if event ==  EVT_ENTER_BREAK then
        local record = self.records[#self.records - self.selectedRow + 1]
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
        if self.selectedRow < #self.records then
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

function LDRecordListView:draw(x, y, invers, option)
    lcd.drawFilledRectangle(0+x, 0+y, 128, 9, FORCE)
    lcd.drawText(0+x, 1+y, "i", SMLSIZE + LEFT + INVERS)
    lcd.drawText(27+x, 1+y, "ele", SMLSIZE + RIGHT + INVERS)
    lcd.drawText(50+x, 1+y, "f1", SMLSIZE + RIGHT + INVERS)
    lcd.drawText(73+x, 1+y, "f2", SMLSIZE + RIGHT + INVERS)
    lcd.drawText(103+x, 1+y, "spd", SMLSIZE + RIGHT + INVERS)
    lcd.drawText(128+x, 1+y, "ld", SMLSIZE + RIGHT + INVERS)

    local records = self.records
    if records ~= nil then
        local scrollRow = self.scrollRow
        for i=scrollRow+1, #records, 1 do
            local record = records[#records - i + 1]
            local y1 = y + 10 + (i-scrollRow-1) * 10
            local op = 0
            if i==self.selectedRow and self.focusState == 2 then
                op = INVERS
                lcd.drawFilledRectangle(0, y1-1, 127, 8, FORCE)
            end
            lcd.drawText(0, y1, #records - i + 1, SMLSIZE + LEFT + op)
            lcd.drawText(27, y1, record.ele, SMLSIZE + RIGHT + op)
            lcd.drawText(50, y1, record.flap1, SMLSIZE + RIGHT + op)
            lcd.drawText(73, y1, record.flap2, SMLSIZE + RIGHT + op)
            lcd.drawText(103, y1, math.floor(LDRgetRecordSpeed(record)*10)/10, SMLSIZE + RIGHT + op)
            lcd.drawText(128, y1, math.floor(LDRgetRecordLD(record)*10)/10, SMLSIZE + RIGHT + op)
            if record.invalid then
                if op == INVERS then
                    lcd.drawLine(0, y1+3, 127, y1+3, SOLID, ERASE)
                else
                    lcd.drawLine(0, y1+3, 127, y1+3, SOLID, FORCE)
                end
            end
        end
    end
end

function LDRecordListView:new()
    self.__index = self
    local o = self.super:new()
    setmetatable(o, self)
    o.scrollRow = 0
    o.selectedRow = 1
    o.records = nil
    return o 
end