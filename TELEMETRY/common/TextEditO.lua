TextEdit = setmetatable({}, InputView)
TextEdit.super = InputView

function TextEdit:preProcess()
    if self.str == "" then
        self.str = " "
    end
    self.headStr = string.sub(self.str, 0, self.modiIndex-1)
    self.modiChar = string.byte(self.str, self.modiIndex) 
    self.tailStr = string.sub(self.str, self.modiIndex+1, -1)
end

function TextEdit:postProcess(textEdit)
    self.str = string.gsub(self.headStr .. string.char(self.modiChar) .. self.tailStr, "[ \t\n\r]+$", "")
    self.headStr = nil
    self.modiChar = nil
    self.tailStr = nil
end


function TextEdit:setFocusState(state)

    self.super.setFocusState(self, state)
    if state == 2 then
        self:preProcess()
    else
        if self.modiChar then
            self:postProcess()
            if self.onChange then
                self.onChange(self)
            end
        end
    end
end

function TextEdit:doKey(event)
    if event == 35 or event == 67 then
        self.modiChar = self.modiChar + 1
        if self.modiChar == 33 then
            self.modiChar = 48
        elseif self.modiChar == 58 then
            self.modiChar = 65
        elseif self.modiChar == 91 then
            self.modiChar = 95
        elseif self.modiChar > 122 then
            self.modiChar = 122
        end
    elseif event == 36 or event == 68 then
        self.modiChar = self.modiChar - 1
        if self.modiChar < 32 then
            self.modiChar = 32 
        elseif self.modiChar == 47 then
            self.modiChar = 32
        elseif self.modiChar == 64 then
            self.modiChar = 57
        elseif self.modiChar == 94 then
            self.modiChar = 90
        end
    elseif event == 37 then
        self:postProcess()
        self.modiIndex = self.modiIndex + 1
        if self.modiIndex >= 6 then
            self.modiIndex = 6
        end
        if string.len(self.str) < self.modiIndex then
            self.str = self.str .. " "
        end
        self:preProcess()
    elseif event == 38 then
        self:postProcess()
        self.modiIndex = self.modiIndex - 1
        if self.modiIndex < 1 then
            self.modiIndex = 1 
        end
        self:preProcess()
    end
end


function TextEdit:setText(str)
    self.str = str
end

function TextEdit:draw(x, y, invers, option1)
    local option = self:getTextOption(invers, option1)
    if self.focusState == 2 then
        if invers then
            lcd.drawText(x, y, self.tailStr, option - INVERS)
            lcd.drawText(lcd.getLastLeftPos(), y, string.char(self.modiChar), option)
            lcd.drawText(lcd.getLastLeftPos(), y, self.headStr, option - INVERS)
        else
            lcd.drawText(x, y, self.tailStr, option)
            lcd.drawText(lcd.getLastLeftPos(), y, string.char(self.modiChar), option)
            lcd.drawText(lcd.getLastLeftPos(), y, self.headStr, option)
        end
    elseif self.focusState == 1 or self.focusState == 0 then
        lcd.drawText(x, y, self.str, option)
    end
end

function TextEdit:setOnChange(onChange)
    self.onChange = onChange
end

function TextEdit:new()
    self.__index = self
    local o = self.super:new()
    self.modiIndex = 1
    self.str = ""
    setmetatable(o, self)
    return o 
end