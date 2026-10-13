gConfigFileName = "3k.cfg"
LZ_runModule(gSDCardDir .. "LAOZHU/comm/Timer.lua")
LZ_runModule(gSDCardDir .. "LAOZHU/SwitchTrigeDetector.lua")
local flightState = nil
local curAlt = 0
local altID = 0
local tpwrTracking = false
local readVar = nil
local roundResetSwitchTrigeDetector = nil
local f3kRound = nil
local monitor = nil
local core
local lastRoundState = nil
local lastFlightState = nil

local function logRoundState()
	local st = f3kRound.getState()
	if st == lastRoundState then
		return
	end
	lastRoundState = st
	DBG_dbg("round", st)
end

local function logFlightState()
	local st = flightState.getFlightState()
	if st == lastFlightState then
		return
	end
	lastFlightState = st
	DBG_dbg("fstate", flightState.getCurFlightStateName())
end

local function landedCallBack(flightTime, launchAlt, launchTime)
	f3kRound.getTask().addFlight(flightTime, launchAlt, launchTime)
	local records = F3KFRgetFlightArray(f3kRound.getTask().getFlightRecord())
	DBG_dbg("flights", #records)
end

local function resetRound()
	tpwrTracking = false
	monitor.resetTpwr()
	f3kRound.stop()
	local isRoundTimerMuted = false
	if f3kCfg:getNumberField("MuteRndTimer", 0) == 1 then
		isRoundTimerMuted = true
	end
	f3kRound.setRoundParam(f3kCfg:getNumberField("PrepTime", 120),
							f3kCfg:getNumberField("TestTime", 40),
							f3kCfg:getStrField('task', "-"),
							f3kCfg:getNumberField("NFlyTime", 60),
							isRoundTimerMuted
						)
end

local function init()

	flightState = LZ_runModule(gSDCardDir .. "LAOZHU/F3k/F3kState.lua")
	LZ_runModule(gSDCardDir .. "LAOZHU/F3k/F3kFlightRecord.lua")
	f3kRound = LZ_runModule(gSDCardDir .. "LAOZHU/F3kWF/F3kRoundWF.lua")
	f3kRound.init()
	monitor = LZ_runModule(gSDCardDir .. "LAOZHU/Monitor.lua")
	monitor.init()
	monitor.bind()
	core.monitor = monitor
	resetRound()
	flightState.landedCallback = landedCallBack
	altID = getTelemetryId("Alt")
	readVar = LZ_runModule(gSDCardDir .. "LAOZHU/readVar.lua")
	local f3kReadVarMap = LZ_runModule(gSDCardDir .. "LAOZHU/F3k/f3kReadVarMap.lua")

	f3kReadVarMap.setF3kState(flightState)
	readVar.setVarMap(f3kReadVarMap)
	roundResetSwitchTrigeDetector = STD_new(getValue(f3kCfg:getNumberField('RdResetSw')))
	logRoundState()
	logFlightState()
end

local function workWindowOn()
	if f3kRound.getState() ~= 4 then
		return false
	end
	local st, flight = f3kRound.getTask().getState()
	if flight ~= nil then
		return st >= 2 or flight > 1
	end
	return st >= 2
end

local function run(event)
	local curTime = getTime()
	f3kRound.run(curTime)
	local flightMode, flightModeName = getFlightMode()
	curAlt = getValue(altID)

	local rtcTime = getRtcTime()

	flightState.curAlt = curAlt
	flightState.doFlightState(curTime, flightModeName, rtcTime)


	local roundStartSwitchValue = getValue(f3kCfg:getNumberField('RdSw'))
	if roundStartSwitchValue > 0 and not f3kRound.isStart() then
		f3kRound.start(curTime)
	end
	
	local roundResetSwitchValue = getValue(f3kCfg:getNumberField('RdResetSw'))
	if STD_run(roundResetSwitchTrigeDetector, roundResetSwitchValue) then
		resetRound()
	end


	local varSelectorSliderValue = getValue(f3kCfg:getNumberField('SelSlider'))
	local varReadSwitchValue = getValue(f3kCfg:getNumberField('ReadSw'))
	
	readVar.doReadVar(varSelectorSliderValue, varReadSwitchValue, curTime)
	if not tpwrTracking and workWindowOn() then
		tpwrTracking = true
	end
	monitor.sample(curTime, tpwrTracking)
	logRoundState()
	logFlightState()
end

local function getRound()
	return f3kRound
end

local function getFlightState()
	return flightState
end

core = {run=run, init=init, getRound=getRound, getFlightState=getFlightState, resetRound=resetRound}
return core
