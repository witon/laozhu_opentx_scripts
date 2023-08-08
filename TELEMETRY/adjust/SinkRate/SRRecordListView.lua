SRRecordListView = setmetatable({}, InputView)
SRRecordListView.super = InputView

function SRRecordListView:doKey(event)
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
    elseif event == 35 or event == 67 or event == 4100 then
        if self.selectedRow < #self.records then
            self.selectedRow = self.selectedRow + 1
        end
        if self.selectedRow - self.scrollRow > 3 then
            self.scrollRow = self.scrollRow + 1
        end
        return true
    elseif event == 36 or event == 68 or event == 4099 then
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

function SRRecordListView:draw(x, y, invers, option)
    lcd.drawFilledRectangle(0, 19, 128, 9, FORCE)
    lcd.drawText(0, 20, "time", SMLSIZE + LEFT + INVERS)
    lcd.drawText(57, 20, "ele", SMLSIZE + RIGHT + INVERS)
    lcd.drawText(80, 20, "f1", SMLSIZE + RIGHT + INVERS)
    lcd.drawText(103, 20, "f2", SMLSIZE + RIGHT + INVERS)
    lcd.drawText(128, 20, "sr", SMLSIZE + RIGHT + INVERS)

    local records = self.records
    if records ~= nil then
        local scrollRow = self.scrollRow
        for i=scrollRow+1, #records, 1 do
            local record = records[#records - i + 1]
            local y = 30 + (i-scrollRow-1) * 10
            local op = 0
            if i==self.selectedRow and self.focusState == 2 then
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
end

function SRRecordListView:new()
    self.__index = self
    local o = self.super:new()
    setmetatable(o, self)
    o.scrollRow = 0
    o.selectedRow = 1
    o.records = nil
    return o 
end