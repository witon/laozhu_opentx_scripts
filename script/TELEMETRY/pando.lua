
local function __andBit(left,right)    --与
    return (left == 1 and right == 1) and 1 or 0
end

local function __orBit(left, right)    --或
    return (left == 1 or right == 1) and 1 or 0
end

local function __xorBit(left, right)   --异或
    return (left + right) == 1 and 1 or 0
end

local function __base(left, right, op) --对每一位进行op运算，然后将值返回
    if left < right then
        left, right = right, left
    end
    local res = 0
    local shift = 1
    while left ~= 0 do
        local ra = left % 2    --取得每一位(最右边)
        local rb = right % 2   
        res = shift * op(ra,rb) + res
        shift = shift * 2
        left = math.modf( left / 2)  --右移
        right = math.modf( right / 2)
    end
    return res
end

local function andOp(left, right)
    return __base(left, right, __andBit)
end

local function xorOp(left, right)
    return __base(left, right, __xorBit)
end

local function orOp(left, right)
    return __base(left, right, __orBit)
end

local function notOp(left)
    return left > 0 and -(left + 1) or -left - 1
end

local function lShiftOp(left, num)  --left左移num位
    return left * (2 ^ num)
end

local function rShiftOp(left,num)  --right右移num位
    return math.floor(left / (2 ^ num))
end



local flight = 0
local task = 0
local round = 0
local group = 0
local windowType = 0
local time = 0
local timeFieldInfo = nil
local windowTypeFieldInfo = nil



local function formatTime(time)
	local minute = time / 60
	local second= time % 60
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

	
	if timeFieldInfo ~= nil and windowTypeFieldInfo ~= nil  then
		time = getValue(timeFieldInfo['id'])
		windowType = getValue(windowTypeFieldInfo['id'])

		if windowType == 0 then
			windowType = "Prep"
		elseif windowType == 1 then
			windowType = "Test"
		elseif windowType == 2 then
			windowType = "Work"
		elseif windowType == 3 then
			windowType = "Land"
		else
			windowType = "Inval"
		end
		lcd.drawText(64, 10, "type:", LEFT + SMLSIZE)
		lcd.drawText(128, 8, windowType, RIGHT + MIDSIZE)

		lcd.drawText(64, 30, "time:", LEFT + SMLSIZE)
		lcd.drawText(128, 23, formatTime(time), RIGHT + DBLSIZE)


        --if(sensorID == 0x67) then -- and frameID == 0x10 and dataID == 0x5111) then
			--lcd.drawText(1, 15, "haha", SMLSIZE)
		--end
    end





end
local function init()
	timeFieldInfo = getFieldInfo('5112')
	windowTypeFieldInfo = getFieldInfo('5111')

end

return { run=run, init = init }
