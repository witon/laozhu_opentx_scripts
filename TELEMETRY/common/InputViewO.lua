InputView = {focusState = 0}
function InputView:setFocusState(state)
    self.focusState = state
--    if self.setFocusState then
--        self.setFocusState(state)
--    end
end

function InputView:getTextOption(invers, option)
    if self.focusState == 2 and invers then
        option = option + INVERS
    elseif self.focusState == 1 then
        option = option + INVERS
    end
    return option 
end

function InputView:new()
    local o = {}
    setmetatable(o, self)
    self.__index = self
    return o
end