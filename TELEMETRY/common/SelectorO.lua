Selector = setmetatable({}, InputView)
Selector.super = InputView

function Selector:getText(index)
    return string.tostring(index)
end

function Selector:inc()
    self.selectedIndex = self.selectedIndex + 1
    return true
end

function Selector:dec()
    self.selectedIndex = self.selectedIndex - 1
    return true
end

function Selector:doKey(event)
    if event == 35 or event == 67 then
        local changed = self:inc(self)
        if changed and self.onChange then
            self.onChange(self)
        end
    elseif event == 36 or event == 68 then
        local changed = self:dec(self)
        if changed and self.onChange then
            self.onChange(self)
        end
    end
end

function Selector:setOnChange(onChange)
    self.onChange = onChange
end

function Selector:draw(x, y, invers, option)
    option = self:getTextOption(invers, option)
    lcd.drawText(x, y, self:getText(self.selectedIndex), option)
end

function Selector:new()
    self.__index = self
    local o = self.super:new()
    self.selectedIndex = -1
    setmetatable(o, self)
    return o 
end