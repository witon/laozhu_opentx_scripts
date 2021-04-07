gConfigFileName = "3k.cfg"
LZ_runModule(gScriptDir .. "LAOZHU/Timer.lua")
LZ_runModule(gScriptDir .. "LAOZHU/SwitchTrigeDetector.lua")
local flightState = nil
local curAlt = 0
local altID = 0
local rxbtID = 0
local readVar = nil
local roundResetSwitchTrigeDetector = nil
local f3kRound = nil

--local monitor = nil

local function landedCallBack(flightTime, launchAlt, launchTime)
	f3kRound.getTask().addFlight(flightTime, launchAlt, launchTime)
end

local function resetRound()
	f3kRound.stop()
	local isRoundTimerMuted = false
	if CFGgetNumberField(f3kCfg, "MuteRndTimer", 0) == 1 then
		isRoundTimerMuted = true
	end
	f3kRound.setRoundParam(CFGgetNumberField(f3kCfg, "PrepTime", 120),
							CFGgetNumberField(f3kCfg, "TestTime", 40),
							CFGgetStrField(f3kCfg, 'task'),
							CFGgetNumberField(f3kCfg, "NFlyTime", 60),
							isRoundTimerMuted
						)
end

local function init()

	flightState = LZ_runModule(gScriptDir .. "LAOZHU/F3k/F3kState.lua")

	f3kRound = LZ_runModule(gScriptDir .. "LAOZHU/F3k/F3kRound.lua")
	f3kRound.init()
	resetRound()
	flightState.setLandedCallback(landedCallBack)
	LZ_runModule(gScriptDir .. "/LAOZHU/Cfg.lua")
	altID = getTelemetryId("Alt")
	rxbtID = getTelemetryId("RxBt")
	readVar = LZ_runModule(gScriptDir .. "LAOZHU/readVar.lua")
	local f3kReadVarMap = LZ_runModule(gScriptDir .. "LAOZHU/F3k/f3kReadVarMap.lua")

	--LZ_runModule(gScriptDir .. "LAOZHU/Sensor.lua")
	--LZ_runModule(gScriptDir .. "LAOZHU/Queue.lua")
	--monitor = LZ_runModule(gScriptDir .. "LAOZHU/Monitor.lua")
	--monitor.init()

	f3kReadVarMap.setF3kState(flightState)
	readVar.setVarMap(f3kReadVarMap)
	roundResetSwitchTrigeDetector = STD_new(getValue(CFGgetNumberField(f3kCfg, 'RdResetSw')))
end

local function run(event)
	local curTime = getTime()
	f3kRound.run(curTime)
	local flightMode, flightModeName = getFlightMode()
	curAlt = getValue(altID)

	local rtcTime = getRtcTime()
	--monitor.run(rtcTime, 0, getValue(rxbtID), 0)

	flightState.setAlt(curAlt)
	flightState.doFlightState(curTime, flightModeName, rtcTime)


	local roundStartSwitchValue = getValue(CFGgetNumberField(f3kCfg, 'RdSw'))
	if roundStartSwitchValue > 0 and not f3kRound.isStart() then
		f3kRound.start(curTime)
	end
	
	local roundResetSwitchValue = getValue(CFGgetNumberField(f3kCfg, 'RdResetSw'))
	if STD_run(roundResetSwitchTrigeDetector, roundResetSwitchValue) then
		resetRound()
	end


	local varSelectorSliderValue = getValue(CFGgetNumberField(f3kCfg, 'SelSlider'))
	local varReadSwitchValue = getValue(CFGgetNumberField(f3kCfg, 'ReadSw'))
	
	readVar.doReadVar(varSelectorSliderValue, varReadSwitchValue, curTime)
end

local function getRound()
	return f3kRound
end

local function getFlightState()
	return flightState
end

return {run=run, init=init, getRound=getRound, getFlightState=getFlightState, resetRound=resetRound}
