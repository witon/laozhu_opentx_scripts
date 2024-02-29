function CBdoKey(checkBox, event)
    if event ==  EVT_ENTER_BREAK then
        checkBox.checked = not checkBox.checked
        if checkBox.onChange then
            checkBox.onChange(checkBox)
        end
        return true;
    end
    return false
end

function CBdraw(checkBox, x, y, invers, option)
    if checkBox.checked then
        lcd.drawText(x, y, 'y', option)
    else
        lcd.drawText(x, y, 'n', option)
    end
end

function CBsetOnChange(checkBox, onChange)
    checkBox.onChange = onChange
end

function CBnewCheckBox()
    return {checked = false, noEdit= true, focusState = 0, doKey = CBdoKey, draw = CBdraw}
end

function CBunload()
    CBdoKey = nil
    CBdraw = nil
    CBsetOnChange = nil
    CBnewCheckBox = nil
    CBunload = nil
end

