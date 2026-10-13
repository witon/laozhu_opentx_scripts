-- 多路传感器监测。方法在类表上，实例只存数据。
-- span：滑动极差，tick 为 getTime()，100 计数为 1 秒。
-- max / min：极值，reset 回到初值。
local SensorMetric = {}
SensorMetric.__index = SensorMetric

function SensorMetric:new(rule, buckets, spanSec)
	local o = setmetatable({}, self)
	o.rule = rule
	if rule == "span" then
		o.n = buckets
		o.span = spanSec
		o.bMin = {}
		o.bMax = {}
		o.bId = {}
		for i = 1, buckets do
			o.bMin[i] = 0
			o.bMax[i] = 0
			o.bId[i] = -1
		end
	elseif rule == "max" then
		o.ext = 0
	else
		o.ext = nil
	end
	return o
end

function SensorMetric:note(tick, value)
	if self.rule == "span" then
		if value <= 0 then
			return
		end
		local id = math.floor(math.floor(tick / 100) / self.span)
		local slot = (id % self.n) + 1
		if self.bId[slot] ~= id then
			self.bId[slot] = id
			self.bMin[slot] = value
			self.bMax[slot] = value
		else
			if value < self.bMin[slot] then
				self.bMin[slot] = value
			end
			if value > self.bMax[slot] then
				self.bMax[slot] = value
			end
		end
	elseif self.rule == "max" then
		if value > self.ext then
			self.ext = value
		end
	else
		if self.ext == nil or value < self.ext then
			self.ext = value
		end
	end
end

function SensorMetric:read(tick)
	if self.rule ~= "span" then
		return self.ext
	end
	local id = math.floor(math.floor(tick / 100) / self.span)
	local lo = nil
	local hi = nil
	for i = 1, self.n do
		local bid = self.bId[i]
		if bid >= 0 and id >= bid and id - bid < self.n then
			if lo == nil or self.bMin[i] < lo then
				lo = self.bMin[i]
			end
			if hi == nil or self.bMax[i] > hi then
				hi = self.bMax[i]
			end
		end
	end
	if lo == nil then
		return 0
	end
	return hi - lo
end

function SensorMetric:reset()
	if self.rule == "max" then
		self.ext = 0
	elseif self.rule == "min" then
		self.ext = nil
	end
end

return SensorMetric
