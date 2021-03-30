function NEsetRange(numEdit, min, max)
    numEdit.min = min
    numEdit.max = max
end

function NEdoKey(numEdit, event)
    if event == 35 then
        numEdit.num = numEdit.num - numEdit.step
        if numEdit.min and numEdit.min > numEdit.num then
            numEdit.num = numEdit.min
        end
        if numEdit.onChange then
            numEdit.onChange(numEdit)
        end
    elseif event == 67 then
        numEdit.num = numEdit.num - 10 * numEdit.step
        if numEdit.min and numEdit.min > numEdit.num then
            numEdit.num = numEdit.min
        end
        if numEdit.onChange then
            numEdit.onChange(numEdit)
        end
    elseif event == 36 then
        numEdit.num = numEdit.num + numEdit.step
        if numEdit.max and numEdit.max < numEdit.num then
            numEdit.num = numEdit.max
        end
        if numEdit.onChange then
            numEdit.onChange(numEdit)
        end
    elseif event == 68 then
        numEdit.num = numEdit.num + 10 * numEdit.step
        if numEdit.max and numEdit.max < numEdit.num then
            numEdit.num = numEdit.max
        end
        if numEdit.onChange then
            numEdit.onChange(numEdit)
        end
    end
end


function NEdraw(numEdit, x, y, invers, option)
    lcd.drawText(x, y, numEdit.num, option)
end

function NEsetOnChange(numEdit, onChange)
    numEdit.onChange = onChange
end

function NEnewNumEdit()
    return {num = 0, step = 1, focusState = 0, doKey = NEdoKey, draw = NEdraw}
end

function NEunload()
    NEsetRange = nil
    NEdoKey = nil
    NEdraw = nil
    NEsetOnChange = nil
    NEnewNumEdit = nil
    NEunload = nil
end
