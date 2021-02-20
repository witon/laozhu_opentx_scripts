function VMaddRow(vm)
    vm.matrix[(#vm.matrix) + 1] = {}
    return vm.matrix[#vm.matrix]
end

function VMdelRow(vm, rowIndex)
    if rowIndex > #vm.matrix then
        return
    end
    if rowIndex == vm.selectedRow then
        VMclearCurIVFocus(vm)
    end
    for i=rowIndex, #vm.matrix - 1, 1 do
        vm.matrix[i] = vm.matrix[i+1]
    end
    vm.matrix[#vm.matrix] = nil
end

function VMclearRow(vm, rowIndex)
    if rowIndex > #vm.matrix then
        return
    end
    local row = vm.matrix[rowIndex]
    while #row > 0 do
        row[#row] = nil
    end
end


function VMgetCurIV(vm)
    return vm.matrix[vm.selectedRow][vm.selectedCol]
end

function VMclear(vm)
    vm.matrix = {}
    vm.selectedCol = 1
    vm.selectedRow = 1
end

function VMisEmpty(vm)
    if #vm.matrix == 0 then
        return true
    end
    if #vm.matrix[1] == 0 then
        return true
    end
    return false
end

function VMupdateCurIVFocus(vm)
    if VMisEmpty(vm) then
        return
    end
    local iv = VMgetCurIV(vm)
    IVsetFocusState(iv, 1)
end

function VMclearCurIVFocus(vm)
    if VMisEmpty(vm) then
        return
    end
    local iv = VMgetCurIV(vm)
    IVsetFocusState(iv, 0)
end


function VMdoKey(vm, event)
    if VMisEmpty(vm) then
        return false
    end

    if vm.editingIv then
        local processed = vm.editingIv.doKey(vm.editingIv, event)
        if processed then
            return true
        end
        if(event == EVT_EXIT_BREAK or event == EVT_ENTER_BREAK) then
            IVsetFocusState(vm.editingIv, 1)
            vm.editingIv = nil
            return true
        end
        return true
    end

    if(event == EVT_ENTER_BREAK) then
        local iv = vm.matrix[vm.selectedRow][vm.selectedCol]
        if iv.noEdit then
            return iv.doKey(iv, event)
        end
        vm.editingIv = iv
        IVsetFocusState(vm.editingIv, 2)
        return true
    end
 
    if event == 38 or event==70 then
        IVsetFocusState(vm.matrix[vm.selectedRow][vm.selectedCol], 0)
        vm.selectedCol = vm.selectedCol - 1
        if vm.selectedCol < 1 then
            vm.selectedCol = 1
        end
       IVsetFocusState(vm.matrix[vm.selectedRow][vm.selectedCol], 1)
       return true
    elseif event==37 or event==69 then
        IVsetFocusState(vm.matrix[vm.selectedRow][vm.selectedCol], 0)
        vm.selectedCol = vm.selectedCol + 1
        if vm.selectedCol > #vm.matrix[vm.selectedRow] then
            vm.selectedCol = #vm.matrix[vm.selectedRow]
        end
        IVsetFocusState(vm.matrix[vm.selectedRow][vm.selectedCol], 1)
        return true
    elseif event==36 or event==68 then
        IVsetFocusState(vm.matrix[vm.selectedRow][vm.selectedCol], 0)
        vm.selectedRow = vm.selectedRow - 1
        if vm.selectedRow < 1 then
            vm.selectedRow = 1
        end
        if vm.selectedCol > #vm.matrix[vm.selectedRow] then
            vm.selectedCol = #vm.matrix[vm.selectedRow]
        end
        IVsetFocusState(vm.matrix[vm.selectedRow][vm.selectedCol], 1)
        return true
    elseif event==35 or event==67 then
        IVsetFocusState(vm.matrix[vm.selectedRow][vm.selectedCol], 0)
        vm.selectedRow = vm.selectedRow + 1
        if vm.selectedRow > #vm.matrix then
            vm.selectedRow = #vm.matrix
        end
        if vm.selectedCol > #vm.matrix[vm.selectedRow] then
            vm.selectedCol = #vm.matrix[vm.selectedRow]
        end
        IVsetFocusState(vm.matrix[vm.selectedRow][vm.selectedCol], 1)
        return true
    end
end

function VMnewViewMatrix()
    return {editingIV = nil, selectedRow = 1, selectedCol = 1, matrix={}, doKey = VMdoKey}
end

