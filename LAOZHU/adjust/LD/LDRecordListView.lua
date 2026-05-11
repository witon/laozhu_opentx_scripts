LDRecordListView = setmetatable({}, InputView)
LDRecordListView.super = InputView

-- 表头/数据列右对齐锚点：原 128px 设计（27/50/73/103）按 LCD_W 比例缩放
local function ldrlvColumnRights(x)
    local s = LCD_W / 128
    return x + math.floor(27 * s), x + math.floor(50 * s), x + math.floor(73 * s), x + math.floor(103 * s)
end

function LDRecordListView:doKey(event)
    local mv = self.maxVisRows or 3
    if event == EVT_ENTER_BREAK then
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

function LDRecordListView:draw(x, y, invers, option)
    local rs = LZ_ui.rowStep
    local hh = LZ_ui.headerRowHeight
    self.listAnchorY = y
    self.maxVisRows = math.max(1, math.floor((LCD_H - y - hh - 1) / rs))
    local rowFillW = math.max(1, LCD_W - x - 1)
    local rightX = x + LCD_W - 1
    local xEle, xF1, xF2, xSpd = ldrlvColumnRights(x)

    lcd.drawFilledRectangle(x, y - LZ_ui.headFillTopPad, LCD_W, hh + LZ_ui.headFillTopPad + LZ_ui.headFillBottomPad, FORCE)
    lcd.drawText(x, y, "i", LZ_ui.font + LEFT + INVERS)
    lcd.drawText(xEle, y, "ele", LZ_ui.font + RIGHT + INVERS)
    lcd.drawText(xF1, y, "f1", LZ_ui.font + RIGHT + INVERS)
    lcd.drawText(xF2, y, "f2", LZ_ui.font + RIGHT + INVERS)
    lcd.drawText(xSpd, y, "spd", LZ_ui.font + RIGHT + INVERS)
    lcd.drawText(rightX, y, "ld", LZ_ui.font + RIGHT + INVERS)

    local records = self.records
    if records ~= nil then
        local scrollRow = self.scrollRow
        local ly0 = y + hh + 1
        local shown = 0
        for i = scrollRow + 1, #records, 1 do
            if shown >= self.maxVisRows then
                break
            end
            local record = records[#records - i + 1]
            local ly = ly0 + (i - scrollRow - 1) * rs
            local op = 0
            if i == self.selectedRow and self.focusState == 2 then
                op = INVERS
                lcd.drawFilledRectangle(x, ly - LZ_ui.rowFillTopPad, rowFillW, rs + LZ_ui.rowFillTopPad + LZ_ui.rowFillBottomPad, FORCE)
            end
            lcd.drawText(x, ly, #records - i + 1, LZ_ui.font + LEFT + op)
            lcd.drawText(xEle, ly, record.ele, LZ_ui.font + RIGHT + op)
            lcd.drawText(xF1, ly, record.flap1, LZ_ui.font + RIGHT + op)
            lcd.drawText(xF2, ly, record.flap2, LZ_ui.font + RIGHT + op)
            lcd.drawText(xSpd, ly, math.floor(LDRgetRecordSpeed(record) * 10) / 10, LZ_ui.font + RIGHT + op)
            lcd.drawText(rightX, ly, math.floor(LDRgetRecordLD(record) * 10) / 10, LZ_ui.font + RIGHT + op)
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

function LDRecordListView:new()
    self.__index = self
    local o = self.super:new()
    setmetatable(o, self)
    o.scrollRow = 0
    o.selectedRow = 1
    o.records = nil
    o.maxVisRows = 3
    return o
end
