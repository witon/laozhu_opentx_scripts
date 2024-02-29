CheckBox = setmetatable({}, InputView)
CheckBox.super = InputView

function CheckBox:doKey(event)
    if event ==  EVT_ENTER_BREAK then
        self.checked = not self.checked
        if self.onChange then
            self.onChange(self)
        end
        return true;
    end
    return false
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
    setmetatable(o, self)
    o.checked = true
    o.noEdit = true
    return o
end