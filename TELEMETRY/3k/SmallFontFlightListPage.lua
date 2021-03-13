local selectedIndex = 1
local scrollLine = 0
local flightArray = nil

local f3kRecordListView = nil

local function init()
	LZ_runModule(gScriptDir .. "TELEMETRY/common/InputView.lua")
	LZ_runModule(gScriptDir .. "TELEMETRY/3k/F3kRecordListView.lua")
	f3kRecordListView = F3KRLVnewRecordListView()
	f3kRecordListView.records = gF3kCore.getFlightState().getFlightRecord().getFlightArray()
	IVsetFocusState(f3kRecordListView, 2)
end

local function doKey(event)
	f3kRecordListView.doKey(f3kRecordListView, event)
end

local function run(event, time)
	flightArray = gF3kCore.getFlightState().getFlightRecord().getFlightArray()
	IVdraw(f3kRecordListView, 0, 0, false, 0)
    doKey(event)
end


local function unloadModule()
    IVunload()
    F3KRLVunload()
end

return {run = run, init=init, destroy=unloadModule}