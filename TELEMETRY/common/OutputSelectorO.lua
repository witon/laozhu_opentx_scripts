OutputSelector = setmetatable({}, Selector)
OutputSelector.super = Selector

function OutputSelector:inc()
    self.selectedIndex = self.selectedIndex + 1
    local outputName = LZ_getOutputName(self.selectedIndex)
    if not outputName then
        self.selectedIndex = self.selectedIndex - 1
        return false
    end
    return true
end

function OutputSelector:dec()
    if self.selectedIndex < 0 then
        return false
    end
    self.selectedIndex = self.selectedIndex - 1
    return true

--    self.selectedIndex = self.selectedIndex - 1
--    local outputName = LZ_getOutputName(self.selectedIndex)
--    if not outputName then
--        self.selectedIndex = self.selectedIndex + 1
--        return false
--    end
--    return true
end

function OutputSelector:getText(index)
    local outputName = LZ_getOutputName(self.selectedIndex)
    if outputName == nil then
        return "-"
    end
    return outputName
end

--function OutputSelector:draw(x, y, invers, option)
--    lcd.drawText(x, y, self.selectedName, option)
--end

function OutputSelector:new()
    self.__index = self
    local o = self.super:new()
    setmetatable(o, self)
    return o 
end