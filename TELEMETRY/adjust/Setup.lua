dofile(gScriptDir .. "TELEMETRY/common/InputView.lua")
local eleGvIndexNumEdit = NEnewNumEdit()
local flapGvIndexNumEdit = NEnewNumEdit()
local drGvIndexNumEdit = NEnewNumEdit()
local edrGvIndexNumEdit = NEnewNumEdit()












local selectorArray = {
    flapGvIndexNumEdit,
    eleGvIndexNumEdit,
    drGvIndexNumEdit,
    edrGvIndexNumEdit
}
local curSelectorIndex = 1
local editingView = nil

local function setCfgValue()
    local cfgs = adjustCfg.getCfgs()
    cfgs["eleGvIndex"] = eleGvIndexNumEdit.num
    cfgs["flapGvIndex"] = flapGvIndexNumEdit.num
    cfgs["drGvIndex"] = drGvIndexNumEdit.num
    cfgs["edrGvIndex"] = edrGvIndexNumEdit.num
end

local function getCfgValue()
    local cfgs = adjustCfg.getCfgs()
    flapGvIndexNumEdit.num = adjustCfg.getNumberField("flapGvIndex", 0)
    eleGvIndexNumEdit.num = adjustCfg.getNumberField("eleGvIndex", 1)
    drGvIndexNumEdit.num = adjustCfg.getNumberField("drGvIndex", 2)
    edrGvIndexNumEdit.num = adjustCfg.getNumberField("edrGvIndex")
end

local function init()
    getCfgValue()
end

local function doKey(event)
    if editingView then
        if(event == EVT_EXIT_BREAK or event == EVT_ENTER_BREAK) then
            IVsetFocusState(editingView, 1)
            editingView = nil
            setCfgValue()
            adjustCfg.writeToFile(gConfigFileName)
            return true
        end
        editingView.doKey(editingView, event)
        return true
    end
 
    if(event == EVT_ENTER_BREAK) then
        editingView = selectorArray[curSelectorIndex]
        IVsetFocusState(editingView, 2)
        return true
    end
    local eventProcessed = false

    local preFocus = selectorArray[curSelectorIndex]
	if(event==36 or event==68) then
		curSelectorIndex = curSelectorIndex - 1
		if curSelectorIndex < 1 then
            curSelectorIndex = 1
        end
        eventProcessed = true
	elseif(event==35 or event==67) then
		curSelectorIndex = curSelectorIndex + 1
		if curSelectorIndex > #selectorArray then
			curSelectorIndex = #selectorArray
        end
        eventProcessed = true
    end
    IVsetFocusState(preFocus, 0)
    IVsetFocusState(selectorArray[curSelectorIndex], 1)
    return eventProcessed
end

local function run(event, time)
    local invers = false
    if getRtcTime() % 2 == 1 then
        invers = true
    end
    local drawOptions
    lcd.drawText(2, 1, "flap gv index:", SMLSIZE + LEFT)
    IVdraw(flapGvIndexNumEdit, 94, 1, invers)
    lcd.drawText(2, 11, "ele gv index:", SMLSIZE + LEFT)
    IVdraw(eleGvIndexNumEdit, 94, 11, invers)
    lcd.drawText(2, 21, "dr gv index:", SMLSIZE + LEFT)
    IVdraw(drGvIndexNumEdit, 94, 21, invers)
    lcd.drawText(2, 31, "edr gv index:", SMLSIZE + LEFT)
    IVdraw(edrGvIndexNumEdit, 94, 31, invers)
    return doKey(event)
end

return {run = run, init=init}