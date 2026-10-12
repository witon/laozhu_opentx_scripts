-- 接收机电压滑动极差：6 个桶，每桶 10 秒，只保留 min/max/桶序号。
-- tick 为 EdgeTX getTime()，100 计数为 1 秒。
local N = 6
local SPAN = 10
local bMin = {}
local bMax = {}
local bId = {}

for i = 1, N do
	bMin[i] = 0
	bMax[i] = 0
	bId[i] = -1
end

local function note(tick, volts)
	if volts <= 0 then
		return
	end
	local id = math.floor(math.floor(tick / 100) / SPAN)
	local slot = (id % N) + 1
	if bId[slot] ~= id then
		bId[slot] = id
		bMin[slot] = volts
		bMax[slot] = volts
	else
		if volts < bMin[slot] then
			bMin[slot] = volts
		end
		if volts > bMax[slot] then
			bMax[slot] = volts
		end
	end
end

local function span(tick)
	local id = math.floor(math.floor(tick / 100) / SPAN)
	local lo = nil
	local hi = nil
	for i = 1, N do
		local bid = bId[i]
		if bid >= 0 and id >= bid and id - bid < N then
			if lo == nil or bMin[i] < lo then
				lo = bMin[i]
			end
			if hi == nil or bMax[i] > hi then
				hi = bMax[i]
			end
		end
	end
	if lo == nil then
		return 0
	end
	return hi - lo
end

return {note = note, span = span}
