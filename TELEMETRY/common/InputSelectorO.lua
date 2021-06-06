InputSelector = setmetatable({}, Selector)
InputSelector.super = Selector

function InputSelector:startDetectField()
    for i=1, #self.fieldTable.valueArray, 1 do
        self.fieldTable.valueArray[i] = getValue(self.fieldTable.idArray[i])
    end
end

function InputSelector:setFocusState(state)
    self.super.setFocusState(self, state)
    if self.state == 2 then
        self:startDetectField()
    end
end

function InputSelector:getSelectedItemId()
    return self.fieldTable.idArray[self.selectedIndex]
end


function InputSelector:detectField()
    for i=1, #self.fieldTable.valueArray, 1 do
        local v = getValue(self.fieldTable.idArray[i])
        if math.abs(self.fieldTable.valueArray[i] - v) > 256 then
            self.selectedIndex = i
            self.fieldTable.valueArray[i] = v
            if self.onChange then
                self.onChange(self)
            end
            return
        else
            self.fieldTable.valueArray[i] = v
        end
    end
end

function InputSelector:setSelectedItemById(id)
    for i=1, #self.fieldTable.idArray, 1 do
        if self.fieldTable.idArray[i] == id then
            self.selectedIndex = i
            return
        end
    end
    self.selectedIndex = 0
end

function InputSelector:setFieldType(type)
    self.fieldTable = type
end

function InputSelector:inc()
    if self.selectedIndex < #(self.fieldTable.nameArray) then
        self.selectedIndex = self.selectedIndex + 1
        return true
    end
    return false
end

function InputSelector:dec()
    if self.selectedIndex > 1 then
        self.selectedIndex = self.selectedIndex - 1
        return true
    end
    return false
end

function InputSelector:getText(index)
    if index > 0 and index <= #(self.fieldTable.nameArray) then
        return self.fieldTable.nameArray[self.selectedIndex]
    end
    return "-"
end

function InputSelector:draw(x, y, invers, option)
    self.super.draw(self, x, y, invers, option)
    if self.focusState == 2 then
        self:detectField()
    end
end

function InputSelector:new()
    self.__index = self
    local o = self.super:new()
    self.fieldTable = FIELDS_CHANNEL
    setmetatable(o, self)
    self.selectedIndex = 0
    return o 
end