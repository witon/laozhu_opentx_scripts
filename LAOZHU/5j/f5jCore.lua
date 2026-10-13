-- F5J 遥测采样与状态推进（与 TELEMETRY background / Widget beforePageRun 共用）。
local readVar = nil
local altID = 0
local monitor = nil

local function init()
	if gFlightState ~= nil then
		return
	end
	gFlightState = LZ_runModule(gSDCardDir .. "LAOZHU/F5jState.lua")
	LZ_runModule(gSDCardDir .. "LAOZHU/Cfg.lua")
	f5jCfg = CFGnewCfg()
	CFGreadFromFile(f5jCfg, gConfigFileName)
	altID = getTelemetryId("Alt")
	monitor = LZ_runModule(gSDCardDir .. "LAOZHU/Monitor.lua")
	monitor.init()
	monitor.bind()
	readVar = LZ_runModule(gSDCardDir .. "LAOZHU/readVar.lua")
	local f5jReadVarMap = LZ_runModule(gSDCardDir .. "LAOZHU/f5jReadVarMap.lua")
	f5jReadVarMap.setF5jState(gFlightState)
	readVar.setVarMap(f5jReadVarMap)
end

local function run()
	local curTime = getTime()
	monitor.sample(curTime)
	local curAlt = getValue(altID)
	local resetSwitchValue = getValue(CFGgetNumberField(f5jCfg, "RsSw"))
	local flightSwitchValue = getValue(CFGgetNumberField(f5jCfg, "FlSw"))
	local throttleValue = getValue(CFGgetNumberField(f5jCfg, "ThCh"))
	gFlightState.setThrottleThreshold(CFGgetNumberField(f5jCfg, "ThThreshold"))
	gFlightState.setWorkTime(CFGgetNumberField(f5jCfg, "WorkTime", 10) * 60)
	gFlightState.setAlt(curAlt)
	gFlightState.doFlightState(curTime, resetSwitchValue, throttleValue, flightSwitchValue)
	local varSelectorSliderValue = getValue(CFGgetNumberField(f5jCfg, "SelSlider"))
	local varReadSwitchValue = getValue(CFGgetNumberField(f5jCfg, "ReadSw"))
	readVar.doReadVar(varSelectorSliderValue, varReadSwitchValue, curTime)
end

return { init = init, run = run }
