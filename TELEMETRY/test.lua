


local flight = 0
local task = 0
local round = 0
local group = 0
local windowType = 0
local time = 0
local fieldInfo = nil



local function formatTime(time)
	local minute = time / 6000
	local second= time / 100 % 60
	local str = string.format("%02d:%02d", minute, second)
	return str
end

local function run(event)
	lcd.clear()
	if(event ~= 0) then
		print(event)
	end
	local nowTime = getTime()
	if event==36 then --up
	elseif event==35 then --down
	elseif event==38 then --left
	elseif event==37 then --right
	elseif event==34 then --enter
	elseif event==33 then --exit
	elseif event==32 then --home
	elseif event==67 then --hold down
	elseif event==68 then --hold up
	elseif event==70 then --hold left
	elseif event==69 then --hold right
	elseif event==32 then --shift 
    end

	
	if(fieldInfo ~= nil) then
		lcd.drawText(64, 20, "time:", LEFT + SMLSIZE)
		lcd.drawText(128, 13, getValue(fieldInfo['id']), RIGHT + DBLSIZE)
		--lcd.drawText(1, 15, formatTime(getValue(fieldInfo['id'])), SMLSIZE)formatTime(

        --if(sensorID == 0x67) then -- and frameID == 0x10 and dataID == 0x5111) then
			--lcd.drawText(1, 15, "haha", SMLSIZE)
		--end
    end





end
local function init()
	fieldInfo = getFieldInfo('5111')
end

return { run=run, init = init }
