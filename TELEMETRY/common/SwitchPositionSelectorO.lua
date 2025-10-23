-- 开关位置选择器组件
-- 用于选择具体的开关位置（例如：SA上、SA中、SA下、SB上、SB下等）
-- 继承自 Selector 基类

SwitchPositionSelector = setmetatable({}, Selector)
SwitchPositionSelector.super = Selector

function SwitchPositionSelector:startDetectField()
    for i=1, #self.fieldTable.valueArray, 1 do
        local v = getSwitchValue(self.fieldTable.indexArray[i])
        if v == nil then
            v = false
        end
        self.fieldTable.valueArray[i] = v
    end
end

function SwitchPositionSelector:setFocusState(state)
    self.super.setFocusState(self, state)
    if self.focusState == 2 then
        self:startDetectField()
    end
end

function SwitchPositionSelector:getSelectedItemId()
    if self.selectedIndex > 0 and self.selectedIndex <= #self.fieldTable.indexArray then
        return self.fieldTable.indexArray[self.selectedIndex]
    end
    return 0
end

function SwitchPositionSelector:detectField()
    for i=1, #self.fieldTable.valueArray, 1 do
        local v = getSwitchValue(self.fieldTable.indexArray[i])
        if v == nil then
            v = false
        end
 
        -- 对于开关位置，检测值是否发生变化
        -- 开关值通常是布尔值或整数，直接比较即可
        if self.fieldTable.valueArray[i] ~= v then
            self.fieldTable.valueArray[i] = v
            if v then
                self.selectedIndex = i
                if self.onChange then
                    self.onChange(self)
                end
            end
        else
            self.fieldTable.valueArray[i] = v
        end
    end
end

function SwitchPositionSelector:setSelectedItemById(id)
    for i=1, #self.fieldTable.indexArray, 1 do
        if self.fieldTable.indexArray[i] == id then
            self.selectedIndex = i
            return
        end
    end
    self.selectedIndex = 0
end

function SwitchPositionSelector:setFieldType(type)
    self.fieldTable = type
end

function SwitchPositionSelector:inc()
    if self.selectedIndex < #(self.fieldTable.nameArray) then
        self.selectedIndex = self.selectedIndex + 1
        return true
    end
    return false
end

function SwitchPositionSelector:dec()
    if self.selectedIndex > 1 then
        self.selectedIndex = self.selectedIndex - 1
        return true
    end
    return false
end

function SwitchPositionSelector:getText(index)
    if index > 0 and index <= #(self.fieldTable.nameArray) then
        return self.fieldTable.nameArray[self.selectedIndex]
    end
    return "-"
end

function SwitchPositionSelector:draw(x, y, invers, option)
    self.super.draw(self, x, y, invers, option)
    if self.focusState == 2 then
        self:detectField()
    end
end

function SwitchPositionSelector:new()
    self.__index = self
    local o = self.super:new()
    o.fieldTable = FIELDS_SWITCH_POSITION
    setmetatable(o, self)
    o.selectedIndex = 0
    return o
end
