local rxbtID = 0
local rqlyID = 0

local function voltHundredths(v)
	return math.floor(v * 100 + 0.5)
end

local function init()
	rxbtID = getTelemetryId("RxBt")
	rqlyID = getTelemetryId("RQly")
end

local function fontBoxHeight(flags, bwHeight)
	if lcd.sizeText then
		local _, h = lcd.sizeText("0", flags)
		return h
	end
	return bwHeight
end

local function drawCell(x, valueY, labelY, right, label, num, flags)
	lcd.drawText(x + 1, labelY, label, MIDSIZE or LZ_ui.font)
	lcd.drawNumber(right, valueY, num, LZ_ui.fontL1 + RIGHT + flags)
end

local function drawPair(row, rowH, valueY0, labelY0, midX, leftLabel, leftNum, leftFlags, rightLabel, rightNum, rightFlags)
	local valueY = valueY0 + row * rowH
	local labelY = labelY0 + row * rowH
	drawCell(0, valueY, labelY, midX - 1, leftLabel, leftNum, leftFlags)
	drawCell(midX + 1, valueY, labelY, LCD_W - 1, rightLabel, rightNum, rightFlags)
end

local function run(event, time)
	local midX = math.floor(LCD_W / 2)
	local rowH = math.floor(LCD_H / 3)
	local valueH = fontBoxHeight(LZ_ui.fontL1, 16)
	local labelH = fontBoxHeight(MIDSIZE or LZ_ui.font, 12)
	local valueY0 = math.floor((rowH - valueH) / 2)
	if valueY0 < 0 then
		valueY0 = 0
	end
	local labelY0 = valueY0 + valueH - labelH
	local rx = getValue(rxbtID)
	local tx = getValue("tx-voltage")

	drawPair(0, rowH, valueY0, labelY0, midX, "RxV", voltHundredths(rx), PREC2, "dRx", voltHundredths(gF3kCore.getRxVoltSpan(time)), PREC2)
	drawPair(1, rowH, valueY0, labelY0, midX, "TxV", math.floor(tx * 10 + 0.5), PREC1, "LQ", getValue(rqlyID), 0)
	drawPair(2, rowH, valueY0, labelY0, midX, "Pwr", gF3kCore.getTpwr(), 0, "Max", gF3kCore.getTpwrMax(), 0)
	lcd.drawLine(midX, 0, midX, LCD_H - 1, SOLID, 0)
end

init()

return {run = run}
