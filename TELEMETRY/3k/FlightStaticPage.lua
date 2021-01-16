
local function init()

end


local function run(event, time)

	gFLightStatic.getMaxAlt()
	lcd.drawText(1, 22, "MaxAlt:", SMLSIZE)
	lcd.drawNumber(68, 13, gFLightStatic.getMaxAlt(), DBLSIZE + RIGHT)
	lcd.drawText(1, 39, "MinRVol:", SMLSIZE)
	lcd.drawNumber(68, 30, gFLightStatic.getMinRxVol()*100, DBLSIZE + RIGHT + PREC2)
	lcd.drawText(1, 56, "MinRSSI:", SMLSIZE)
	lcd.drawNumber(68, 47, gFLightStatic.getMinRssi(), DBLSIZE + RIGHT)
end

return {run = run, init=init}