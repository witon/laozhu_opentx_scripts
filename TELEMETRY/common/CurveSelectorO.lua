CurveSelector = setmetatable({}, Selector)
CurveSelector.super = Selector

function CurveSelector:inc()
    self.selectedIndex = self.selectedIndex + 1
    local curveName = LZ_getCurveName(self.selectedIndex)
    if not curveName then
        self.selectedIndex = self.selectedIndex - 1
        return false
    end
    return true
end

function CurveSelector:dec()
    if self.selectedIndex < 0 then
        return false
    end
    self.selectedIndex = self.selectedIndex - 1
    return true
end

function CurveSelector:getText(index)
    local curveName = LZ_getCurveName(index)
    if curveName ~= nil then
        return curveName
    end
    return "-"
end

function CurveSelector:new()
    self.__index = self
    local o = self.super:new()
    setmetatable(o, self)
    self.selectedIndex = -1
    return o 
end