TimeEdit = setmetatable({}, NumEdit)
TimeEdit.super = NumEdit

function TimeEdit:draw(x, y, invers, option)
    option = self:getTextOption(invers, option)
	lcd.drawText(x, y, LZ_formatTime(self.num), option)
end

function TimeEdit:new()
    self.__index = self
    local o = self.super:new()
    setmetatable(o, self)
    o.num = 0
    o.step = 1
    return o 
end