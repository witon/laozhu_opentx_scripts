gConfigFileName = "3k.cfg"
LZ_runModule("LAOZHU/comm/Timer.lua")
LZ_runModule("LAOZHU/SwitchTrigeDetector.lua")
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

	flightState = LZ_runModule("LAOZHU/F3k/F3kState.lua")
	LZ_runModule("LAOZHU/F3k/F3kFlightRecord.lua")
	f3kRound = LZ_runModule("LAOZHU/F3kWF/F3kRoundWF.lua")
	f3kRound.init()
	resetRound()
	flightState.landedCallback = landedCallBack
	altID = getTelemetryId("Alt")
	rxbtID = getTelemetryId("RxBt")
	readVar = LZ_runModule("LAOZHU/readVar.lua")
	local f3kReadVarMap = LZ_runModule("LAOZHU/F3k/f3kReadVarMap.lua")

	f3kReadVarMap.setF3kState(flightState)
	readVar.setVarMap(f3kReadVarMap)
	roundResetSwitchTrigeDetector = STD_new(getValue(f3kCfg:getNumberField('RdResetSw')))
end

local function run(event)
	local curTime = getTime()
	f3kRound.run(curTime)
	local flightMode, flightModeName = getFlightMode()
	curAlt = getValue(altID)

	local rtcTime = getRtcTime()
	--monitor.run(rtcTime, 0, getValue(rxbtID), 0)

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
end

local function getRound()
	return f3kRound
end

local function getFlightState()
	return flightState
end

return {run=run, init=init, getRound=getRound, getFlightState=getFlightState, resetRound=resetRound}
