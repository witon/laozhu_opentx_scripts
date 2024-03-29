local f3kRecordListView = nil

local function init()
	LZ_runModule("TELEMETRY/common/InputView.lua")
	LZ_runModule("TELEMETRY/3k/F3kRecordListView.lua")
	f3kRecordListView = F3KRLVnewRecordListView()
	f3kRecordListView.records = F3KFRgetFlightArray(gF3kCore.getRound().getTask().getFlightRecord())
	IVsetFocusState(f3kRecordListView, 2)
end

local function doKey(event)
	f3kRecordListView.doKey(f3kRecordListView, event)
end

local function run(event, time)
	IVdraw(f3kRecordListView, 0, 0, false, 0)
    doKey(event)
end


local function unloadModule()
    IVunload()
    F3KRLVunload()
end

init()

return {run = run, destroy=unloadModule}