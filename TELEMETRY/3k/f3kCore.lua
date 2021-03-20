gConfigFileName = "3k.cfg"
LZ_runModule(gScriptDir .. "LAOZHU/Timer.lua")
LZ_runModule(gScriptDir .. "LAOZHU/SwitchTrigeDetector.lua")
local worktimeTimer = nil
local worktimeArray = {
	420,
	600,
	900
}
local selectWorktimeIndex = 2
local flightState = nil

local curAlt = 0
local altID = 0
local rxbtID = 0
local readVar = nil
local WTResetSwitchTrigeDetector = nil

--local monitor = nil

local function init()
	worktimeTimer = Timer_new()
	worktimeTimer.mute = true
	Timer_setForward(worktimeTimer, false)

	flightState = LZ_runModule(gScriptDir .. "LAOZHU/F3kState.lua")
	Timer_resetTimer(worktimeTimer, worktimeArray[selectWorktimeIndex])
	LZ_runModule(gScriptDir .. "/LAOZHU/Cfg.lua")
	altID = getTelemetryId("Alt")
	rxbtID = getTelemetryId("RxBt")
	readVar = LZ_runModule(gScriptDir .. "LAOZHU/readVar.lua")
	local f3kReadVarMap = LZ_runModule(gScriptDir .. "LAOZHU/f3kReadVarMap.lua")

	--LZ_runModule(gScriptDir .. "LAOZHU/Sensor.lua")
	--LZ_runModule(gScriptDir .. "LAOZHU/Queue.lua")
	--monitor = LZ_runModule(gScriptDir .. "LAOZHU/Monitor.lua")
	--monitor.init()

	f3kReadVarMap.setF3kState(flightState)
	readVar.setVarMap(f3kReadVarMap)
	WTResetSwitchTrigeDetector = STD_new(getValue(CFGgetNumberField(f3kCfg, 'WtResetSw')))
end

local function run(event)
	local curTime = getTime()
	local flightMode, flightModeName = getFlightMode()
	curAlt = getValue(altID)

	local rtcTime = getRtcTime()
	--monitor.run(rtcTime, 0, getValue(rxbtID), 0)

	flightState.setAlt(curAlt)
	flightState.doFlightState(curTime, flightModeName)

	local workTimeSwitchValue = getValue(CFGgetNumberField(f3kCfg, 'WtSw'))
	if workTimeSwitchValue > 0 and not Timer_isstart(worktimeTimer) then
		Timer_start(worktimeTimer)
	end

	local workTimeResetSwitchValue = getValue(CFGgetNumberField(f3kCfg, 'WtResetSw'))
	if STD_run(WTResetSwitchTrigeDetector, workTimeResetSwitchValue) then
		Timer_resetTimer(worktimeTimer, worktimeArray[selectWorktimeIndex])
		Timer_setCurTime(worktimeTimer, curTime)
	end

	Timer_setCurTime(worktimeTimer, curTime)
	Timer_run(worktimeTimer)

	local varSelectorSliderValue = getValue(CFGgetNumberField(f3kCfg, 'SelSlider'))
	local varReadSwitchValue = getValue(CFGgetNumberField(f3kCfg, 'ReadSw'))
	
	readVar.doReadVar(varSelectorSliderValue, varReadSwitchValue, curTime)
end

local function increaseWorktimeIndex()
	selectWorktimeIndex = selectWorktimeIndex + 1
	if selectWorktimeIndex > #worktimeArray then
		selectWorktimeIndex = 1
	end
	Timer_setDuration(worktimeTimer, worktimeArray[selectWorktimeIndex])
end

local function decreaseWorktimeIndex()
	selectWorktimeIndex = selectWorktimeIndex - 1
	if selectWorktimeIndex <= 0 then
		selectWorktimeIndex = #worktimeArray
	end
	Timer_setDuration(worktimeTimer, worktimeArray[selectWorktimeIndex])
end

local function getWorktimeTimer()
	return worktimeTimer
end

local function getFlightState()
	return flightState
end

return {run=run, init=init, increaseWorktimeIndex=increaseWorktimeIndex, decreaseWorktimeIndex=decreaseWorktimeIndex, getWorktimeTimer=getWorktimeTimer, getFlightState=getFlightState}
