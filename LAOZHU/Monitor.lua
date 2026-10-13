-- 接收机电压滑动极差、发射功率峰值、连接质量最低值。
local SensorMetric = nil
local rxMetric = nil
local tpwrMetric = nil
local lqMetric = nil
local rxbtID = 0
local tpwrID = 0
local rqlyID = 0

local function init()
	SensorMetric = LZ_runModule(gSDCardDir .. "LAOZHU/SensorMetric.lua")
	rxMetric = SensorMetric:new("span", 6, 10)
	tpwrMetric = SensorMetric:new("max")
	lqMetric = SensorMetric:new("min")
end

local function bind()
	rxbtID = getTelemetryId("RxBt")
	tpwrID = getTelemetryId("TPWR")
	rqlyID = getTelemetryId("RQly")
end

local function run(tick, rxVolt, tpwr, lq, trackTpwr)
	rxMetric:note(tick, rxVolt)
	if trackTpwr ~= false then
		tpwrMetric:note(tick, tpwr)
	end
	lqMetric:note(tick, lq)
end

local function sample(tick, trackTpwr)
	run(tick, getValue(rxbtID), getValue(tpwrID), getValue(rqlyID), trackTpwr)
end

local function resetTpwr()
	tpwrMetric:reset()
end

local function rxSpan(tick)
	return rxMetric:read(tick)
end

local function tpwrMax()
	return tpwrMetric:read()
end

local function lqMin()
	return lqMetric:read()
end

local function rx()
	return getValue(rxbtID)
end

local function tpwr()
	return getValue(tpwrID)
end

local function lq()
	return getValue(rqlyID)
end

return {
	init = init,
	bind = bind,
	run = run,
	sample = sample,
	resetTpwr = resetTpwr,
	rxSpan = rxSpan,
	tpwrMax = tpwrMax,
	lqMin = lqMin,
	rx = rx,
	tpwr = tpwr,
	lq = lq,
}
