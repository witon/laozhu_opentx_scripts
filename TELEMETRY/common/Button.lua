
function BTdoKey(button, event)
    if event ==  EVT_ENTER_BREAK then
        if button.onClick then
            button.onClick(button)
            return true
        end
        return false
    end
    return false
end

function BTdraw(button, x, y, invers, option)
    lcd.drawText(x, y, button.text, option)
end

function BTsetOnClick(button, onClick)
    button.onClick = onClick
end

function BTnewButton()
    return {noEdit = true, text = "", focusState = 0, doKey = BTdoKey, draw = BTdraw}
end

function BTunload()
    BTdoKey = nil
    BTdraw = nil
    BTsetOnClick = nil
    BTnewButton = nil
    BTunload = nil
end