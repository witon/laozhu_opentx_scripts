

function CBdoKey(checkBox, event)
    if event == 35 or event == 67 or event == 36 or event == 68 then
        checkBox.checked = not checkBox.checked
        if checkBox.onChange then
            checkBox.onChange(checkBox)
        end
    end
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
    return {checked = false, isFocuse = false, focusState = 0, doKey = CBdoKey, draw = CBdraw}
end

