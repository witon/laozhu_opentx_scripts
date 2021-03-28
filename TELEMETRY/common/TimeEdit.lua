function TIMEEdraw(timeEdit, x, y, invers, option)
	lcd.drawText(x, y, LZ_formatTime(timeEdit.num), option)
end

function TIMEEnewTimeEdit()
    return {num = 0, step = 1, focusState = 0, doKey = NEdoKey, draw = TIMEEdraw}
end

function TIMEEunload()
    TIMEEnewTimeEdit = nil
    TIMEEnewTimeEdit = nil
    TIMEEunload = nil
end
