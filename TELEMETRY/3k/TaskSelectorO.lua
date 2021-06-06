TaskSelector = setmetatable({}, Selector)
TaskSelector.super = Selector

TASK_ARRAY = {"Train", "LastFl", "AULD", "OtherTask", "TEST"}

function TaskSelector:getText(index)
    if index >= 1 and index <= #TASK_ARRAY then
        return TASK_ARRAY[index]
    end
    return "-"
end

function TaskSelector:setTask(taskName)
    for i=1, #TASK_ARRAY, 1 do
        if taskName == TASK_ARRAY[i] then
            self.selectedIndex = i
            return
        end
    end
    self.selectedIndex = 0
    return
end


function TaskSelector:inc(selector)
    if self.selectedIndex >= #TASK_ARRAY then
        return false
    end
    self.selectedIndex = self.selectedIndex + 1
    return true
end

function TaskSelector:dec(selector)
    if self.selectedIndex <= 0 then
        return false
    end
    self.selectedIndex = self.selectedIndex - 1
    return true
end



function TaskSelector:new()
    self.__index = self
    local o = self.super:new()
    setmetatable(o, self)
    self.selectedIndex = 0
    return o 
end