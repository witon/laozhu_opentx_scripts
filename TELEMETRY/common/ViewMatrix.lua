
function VMdoKey(vm, event)
    if vm.editingIv then
        if(event == EVT_EXIT_BREAK or event == EVT_ENTER_BREAK) then
            IVsetFocusState(vm.editingIv, 1)
            vm.editingIv = nil
            return true
        end
        vm.editingIv.doKey(vm.editingIv, event)
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
 
    if event == 38 then
        IVsetFocusState(vm.matrix[vm.selectedRow][vm.selectedCol], 0)
        vm.selectedCol = vm.selectedCol - 1
        if vm.selectedCol < 1 then
            vm.selectedCol = 1
        end
       IVsetFocusState(vm.matrix[vm.selectedRow][vm.selectedCol], 1)
       return true
    elseif event==37 then
        IVsetFocusState(vm.matrix[vm.selectedRow][vm.selectedCol], 0)
        vm.selectedCol = vm.selectedCol + 1
        if vm.selectedCol > #vm.matrix[vm.selectedRow] then
            vm.selectedCol = #vm.matrix[vm.selectedRow]
        end
        IVsetFocusState(vm.matrix[vm.selectedRow][vm.selectedCol], 1)
        return true
    elseif event==36 then
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
    elseif event==35 then
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

