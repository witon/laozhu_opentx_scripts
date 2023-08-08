local function preProcess(textEdit)
    if textEdit.str == "" then
        textEdit.str = " "
    end
    textEdit.headStr = string.sub(textEdit.str, 0, textEdit.modiIndex-1)
    textEdit.modiChar = string.byte(textEdit.str, textEdit.modiIndex) 
    textEdit.tailStr = string.sub(textEdit.str, textEdit.modiIndex+1, -1)
end

local function postProcess(textEdit)
    textEdit.str = string.gsub(textEdit.headStr .. string.char(textEdit.modiChar) .. textEdit.tailStr, "[ \t\n\r]+$", "")
    textEdit.headStr = nil
    textEdit.modiChar = nil
    textEdit.tailStr = nil
end


function TEsetFocusState(textEdit, state)
    if state == 2 then
        preProcess(textEdit)
    else
        if textEdit.modiChar then
            postProcess(textEdit)
            if textEdit.onChange then
                textEdit.onChange(textEdit)
            end
        end
    end
end

function TEdoKey(textEdit, event)
    if event == 35 or event == 67 or event == 4100 then
        textEdit.modiChar = textEdit.modiChar + 1
        if textEdit.modiChar == 33 then
            textEdit.modiChar = 48
        elseif textEdit.modiChar == 58 then
            textEdit.modiChar = 65
        elseif textEdit.modiChar == 91 then
            textEdit.modiChar = 95
        elseif textEdit.modiChar > 122 then
            textEdit.modiChar = 122
        end
    elseif event == 36 or event == 68 or event == 4099 then
        textEdit.modiChar = textEdit.modiChar - 1
        if textEdit.modiChar < 32 then
            textEdit.modiChar = 32 
        elseif textEdit.modiChar == 47 then
            textEdit.modiChar = 32
        elseif textEdit.modiChar == 64 then
            textEdit.modiChar = 57
        elseif textEdit.modiChar == 94 then
            textEdit.modiChar = 90
        end
    elseif event == 37 then
        postProcess(textEdit)
        textEdit.modiIndex = textEdit.modiIndex + 1
        if textEdit.modiIndex >= 6 then
            textEdit.modiIndex = 6
        end
        if string.len(textEdit.str) < textEdit.modiIndex then
            textEdit.str = textEdit.str .. " "
        end
        preProcess(textEdit)
    elseif event == 38 then
        postProcess(textEdit)
        textEdit.modiIndex = textEdit.modiIndex - 1
        if textEdit.modiIndex < 1 then
            textEdit.modiIndex = 1 
        end
        preProcess(textEdit)
    end
end


function TEsetText(textEdit, str)
    textEdit.str = str
end

function TEdraw(textEdit, x, y, invers, option)
    if textEdit.focusState == 2 then
        if invers then
            lcd.drawText(x, y, textEdit.tailStr, option - INVERS)
            lcd.drawText(lcd.getLastLeftPos(), y, string.char(textEdit.modiChar), option)
            lcd.drawText(lcd.getLastLeftPos(), y, textEdit.headStr, option - INVERS)
        else
            lcd.drawText(x, y, textEdit.tailStr, option)
            lcd.drawText(lcd.getLastLeftPos(), y, string.char(textEdit.modiChar), option)
            lcd.drawText(lcd.getLastLeftPos(), y, textEdit.headStr, option)
        end
    elseif textEdit.focusState == 1 or textEdit.focusState == 0 then
        lcd.drawText(x, y, textEdit.str, option)
    end
end

function TEsetOnChange(textEdit, onChange)
    textEdit.onChange = onChange
end


function TEnewTextEdit()
    return {modiIndex = 1, str = {}, focusState = 0, setFocusState = TEsetFocusState, doKey = TEdoKey, draw = TEdraw}
end


function TEunload()
    preProcess = nil
    postProcess = nil
    TEsetFocusState = nil
    TEdoKey = nil
    TEsetText = nil
    TEdraw = nil
    TEsetOnChange = nil
    TEnewTextEdit = nil
    TEunload = nil
end