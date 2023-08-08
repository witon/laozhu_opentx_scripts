ViewMatrix = setmetatable({}, InputView)
ViewMatrix.super = InputView

function ViewMatrix:addRow()
    self.matrix[(#self.matrix) + 1] = {}
    return self.matrix[#self.matrix]
end

function ViewMatrix:delRow(rowIndex)
    if rowIndex > #self.matrix then
        return
    end
    if rowIndex == self.selectedRow then
        self:clearCurIVFocus()
    end
    for i=rowIndex, #self.matrix - 1, 1 do
        self.matrix[i] = self.matrix[i+1]
    end
    self.matrix[#self.matrix] = nil
end

function ViewMatrix:clearRow(rowIndex)
    if rowIndex > #self.matrix then
        return
    end
    local row = self.matrix[rowIndex]
    while #row > 0 do
        row[#row] = nil
    end
end


function ViewMatrix:getCurIV()
    return self.matrix[self.selectedRow][self.selectedCol]
end

function ViewMatrix:clear()
    self.matrix = {}
    self.selectedCol = 1
    self.selectedRow = 1
end

function ViewMatrix:isEmpty()
    if #self.matrix == 0 then
        return true
    end
    if #self.matrix[1] == 0 then
        return true
    end
    return false
end

function ViewMatrix:updateCurIVFocus()
    if self:isEmpty() then
        return
    end
    local iv = self:getCurIV()
    iv:setFocusState(1)
end

function ViewMatrix:clearCurIVFocus()
    if self:isEmpty() then
        return
    end
    local iv = self:getCurIV()
    iv:setFocusState(0)
end


function ViewMatrix:doKey(event)
    if self:isEmpty() then
        return false
    end

    if self.editingIv then
        local processed = self.editingIv:doKey(event)
        if processed then
            return true
        end
        if(event == EVT_EXIT_BREAK or event == EVT_ENTER_BREAK) then
            self.editingIv:setFocusState(1)
            self.editingIv = nil
            return true
        end
        return true
    end

    if(event == EVT_ENTER_BREAK) then
        local iv = self.matrix[self.selectedRow][self.selectedCol]
        if iv.noEdit then
            return iv:doKey(event)
        end
        self.editingIv = iv
        self.editingIv:setFocusState(2)
        return true
    end
 
    if event == 38 or event==70 or event==98 then
        self.matrix[self.selectedRow][self.selectedCol]:setFocusState(0)
        self.selectedCol = self.selectedCol - 1
        local overflow = false
        if self.selectedCol < 1 then
            self.selectedCol = 1
            overflow = true
        end
        self.matrix[self.selectedRow][self.selectedCol]:setFocusState(1)
        if overflow then
            return false
        end
        return true
    elseif event==37 or event==69 or event==99 then
        self.matrix[self.selectedRow][self.selectedCol]:setFocusState(0)
        self.selectedCol = self.selectedCol + 1
        local overflow = false
        if self.selectedCol > #self.matrix[self.selectedRow] then
            self.selectedCol = #self.matrix[self.selectedRow]
            overflow = true
        end
        self.matrix[self.selectedRow][self.selectedCol]:setFocusState(1)
        if overflow then
            return false
        end
        return true
    elseif event==36 or event==68 or event==4099 then
        self.matrix[self.selectedRow][self.selectedCol]:setFocusState(0)
        self.selectedRow = self.selectedRow - 1
        if self.selectedRow < 1 then
            self.selectedRow = 1
        end
        if self.selectedCol > #self.matrix[self.selectedRow] then
            self.selectedCol = #self.matrix[self.selectedRow]
        end
        if self.selectedRow - self.scrollLine < 1 then
            self.scrollLine = self.scrollLine - 1
        end
        self.matrix[self.selectedRow][self.selectedCol]:setFocusState(1)
        return true
    elseif event==35 or event==67 or event==4100 then
        self.matrix[self.selectedRow][self.selectedCol]:setFocusState(0)
        self.selectedRow = self.selectedRow + 1
        if self.selectedRow > #self.matrix then
            self.selectedRow = #self.matrix
        end
        if self.selectedCol > #self.matrix[self.selectedRow] then
            self.selectedCol = #self.matrix[self.selectedRow]
        end
        if self.selectedRow - self.scrollLine > self.visibleRows then
            self.scrollLine = self.scrollLine + 1
        end
        self.matrix[self.selectedRow][self.selectedCol]:setFocusState(1)
        return true
    end
end

function ViewMatrix:new()
    local o = {}
    setmetatable(o, self)
    self.__index = self
    o.editingIv = nil
    o.selectedRow = 1
    o.selectedCol = 1
    o.matrix = {}
    o.visibleRows = 5
    o.scrollLine = 0
    return o
end

