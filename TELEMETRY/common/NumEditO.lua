NumEdit = InputView:new()

function NumEdit:setRange(min, max)
    self.min = min
    self.max = max
end

function NumEdit:doKey(event)
    if event == 35 or event == 38 then
        self.num = self.num - self.step
        if self.min and self.min > self.num then
            self.num = self.min
        end
        if self.onChange then
            self.onChange(self)
        end
    elseif event == 67 or event == 70 then
        self.num = self.num - 10 * self.step
        if self.min and self.min > self.num then
            self.num = self.min
        end
        if self.onChange then
            self.onChange(self)
        end
    elseif event == 36 or event == 37 then
        self.num = self.num + self.step
        if self.max and self.max < self.num then
            self.num = self.max
        end
        if self.onChange then
            self.onChange(self)
        end
    elseif event == 68 or event == 69 then
        self.num = self.num + 10 * self.step
        if self.max and self.max < self.num then
            self.num = self.max
        end
        if self.onChange then
            self.onChange(self)
        end
    end
end

function NumEdit:draw(x, y, invers, option)
    option = self:getTextOption(invers, option)
    lcd.drawText(x, y, self.num, option)
end

function NumEdit:setOnChange(onChange)
    self.onChange = onChange
end

function NumEdit:new()
    local o = {}
    setmetatable(o, self)
    self.__index = self
    self.__super = InputView
    o.num = 0
    o.step = 1
    return o
end