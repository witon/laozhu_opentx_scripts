function IVsetFocusState(iv, state)
    iv.focusState = state
    if iv.setFocusState then
        iv.setFocusState(iv, state)
    end
end

function IVdraw(iv, x, y, invers)
    local drawOption = 0
    if iv.focusState == 2 and invers then
        drawOption = drawOption + INVERS
    elseif iv.focusState == 1 then
        drawOption = drawOption + INVERS
    end
    iv.draw(iv, x, y, drawOption)
end