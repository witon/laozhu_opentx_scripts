
local lastTime = 0;
local function run(event)
	if(event ~= 0) then
		print(event)
	end
	local nowTime = getTime()
	local time = math.floor(nowTime / 100);
	if time == lastTime then
		return
	end
	lcd.clear()
	lastTime = time



	if time % 2 == 0 then
		local r = serialRead(10);
		lcd.drawText(1, 10, "read:" .. r, SMLSIZE + LEFT)
	
	else
		serialWrite(tostring(time))
		lcd.drawText(1, 10, "send:" .. time, SMLSIZE + LEFT)
	end


end
local function init()


end

return { run=run, init = init }
