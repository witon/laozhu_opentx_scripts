Button = setmetatable({}, InputView)
Button.super = InputView

function Button:doKey(event)
    if event ==  EVT_ENTER_BREAK then
        if self.onClick then
            self.onClick(self)
            return true
        end
        return false
    end
    return false
end

function Button:draw(x, y, invers, option)
    option = self:getTextOption(invers, option)
    lcd.drawText(x, y, self.text, option)
end

function Button:setOnClick(onClick)
    self.onClick = onClick
end

function Button:new()
    self.__index = self
    local o = self.super:new()
    setmetatable(o, self)
    o.noEdit = true
    o.text = ""
    return o 
end