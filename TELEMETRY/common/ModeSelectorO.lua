ModeSelector = setmetatable({}, Selector)
ModeSelector.super = Selector

function ModeSelector:getText(index)
    if index < 0 then
        return "-"
    end
    local modeIndex, modeName= getFlightMode(index)
    if modeName == nil or modeName == "" then
        return "FM" .. index
    end
    return modeName 
end

function ModeSelector:inc()
    if self.selectedIndex >= 8 then
        return false
    end
    self.selectedIndex = self.selectedIndex + 1
    return true
end

function ModeSelector:dec()
    if self.selectedIndex < 0 then
        return false
    end
    self.selectedIndex = self.selectedIndex - 1
    return true
end

function ModeSelector:new()
    self.__index = self
    local o = self.super:new()
    setmetatable(o, self)
    return o 
end