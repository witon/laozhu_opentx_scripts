CheckBox = setmetatable({}, InputView)
CheckBox.super = InputView

function CheckBox:doKey(event)
    if event == 35 or event == 67 or event == 36 or event == 68 then
        self.checked = not self.checked
        if self.onChange then
            self.onChange(self)
        end
    end
end

function CheckBox:draw(x, y, invers, option)
    option = self:getTextOption(invers, option)
    if self.checked then
        lcd.drawText(x, y, 'y', option)
    else
        lcd.drawText(x, y, 'n', option)
    end
end

function CheckBox:setOnChange(onChange)
    self.onChange = onChange
end

function CheckBox:new()
    self.__index = self
    local o = self.super:new()
    self.modiIndex = 1
    self.checked = true
    setmetatable(o, self)
    return o
end