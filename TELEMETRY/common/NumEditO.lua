NumEdit = InputView:new()

function NumEdit:setRange(min, max)
    self.min = min
    self.max = max
end

function NumEdit:doKey(event)
    if event == 35 then
        self.num = self.num - self.step
        if self.min and self.min > self.num then
            self.num = self.min
        end
        if self.onChange then
            self.onChange(self)
        end
    elseif event == 67 then
        self.num = self.num - 10 * self.step
        if self.min and self.min > self.num then
            self.num = self.min
        end
        if self.onChange then
            self.onChange(self)
        end
    elseif event == 36 then
        self.num = self.num + self.step
        if self.max and self.max < self.num then
            self.num = self.max
        end
        if self.onChange then
            self.onChange(self)
        end
    elseif event == 68 then
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
    self.num = 0
    self.step = 1
    return o
end