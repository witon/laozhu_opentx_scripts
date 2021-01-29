LZ_runModule(gScriptDir .. "TELEMETRY/common/InputView.lua")
local varSliderSelector = ISnewInputSelector()
ISsetFieldType(varSliderSelector, FIELDS_INPUT)
local readSwitchSelector = ISnewInputSelector()
ISsetFieldType(readSwitchSelector, FIELDS_SWITCH)
local workTimeSwitchSelector = ISnewInputSelector()
ISsetFieldType(workTimeSwitchSelector, FIELDS_SWITCH)
local workTimeResetSwitchSelector = ISnewInputSelector()
ISsetFieldType(workTimeResetSwitchSelector, FIELDS_SWITCH)
local destTimeSettingStepNumEdit = NEnewNumEdit()
destTimeSettingStepNumEdit.step = 5



local selectorArray = {
    destTimeSettingStepNumEdit,
    workTimeSwitchSelector,
    workTimeResetSwitchSelector,
    varSliderSelector,
    readSwitchSelector,
}
local curSelectorIndex = 1
local editingSelector = nil

local function setCfgValue()
    local cfgs = f3kCfg.getCfgs()
    cfgs["ReadSw"] = ISgetSelectedItemId(readSwitchSelector)
    cfgs["SelSlider"] = ISgetSelectedItemId(varSliderSelector)
    cfgs["WtSw"] = ISgetSelectedItemId(workTimeSwitchSelector)
    cfgs["WtResetSw"] = ISgetSelectedItemId(workTimeResetSwitchSelector)
    cfgs["DestTimeStep"] = destTimeSettingStepNumEdit.num
end

local function getCfgValue()
    local cfgs = f3kCfg.getCfgs()
    ISsetSelectedItemById(readSwitchSelector, cfgs["ReadSw"])
    ISsetSelectedItemById(varSliderSelector, cfgs["SelSlider"])
    ISsetSelectedItemById(workTimeSwitchSelector, cfgs["WtSw"])
    ISsetSelectedItemById(workTimeResetSwitchSelector, cfgs["WtResetSw"])
    destTimeSettingStepNumEdit.num = f3kCfg.getNumberField("DestTimeStep", 15)
end

local function init()
    getCfgValue()
end

local function doKey(event)
    if editingSelector then
        if(event == EVT_EXIT_BREAK or event == EVT_ENTER_BREAK) then
            IVsetFocusState(editingSelector, 1)
            editingSelector = nil
            setCfgValue()
            f3kCfg.writeToFile(gConfigFileName)
            return true
        end
        editingSelector.doKey(editingSelector, event)
        return true
    end
 
    if(event == EVT_ENTER_BREAK) then
        editingSelector = selectorArray[curSelectorIndex]
        IVsetFocusState(editingSelector, 2)
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
    lcd.drawText(2, 2, "Target Flight Time Step", SMLSIZE + LEFT)
    IVdraw(destTimeSettingStepNumEdit, 122, 2, invers)
    lcd.drawText(2, 12, "WTime Start Switch", SMLSIZE + LEFT)
    IVdraw(workTimeSwitchSelector, 110, 12, invers)
    lcd.drawText(2, 22, "WTime Reset Switch", SMLSIZE + LEFT)
    IVdraw(workTimeResetSwitchSelector, 110, 22, invers)
    lcd.drawText(2, 32, "Var Slider", SMLSIZE + LEFT)
    IVdraw(varSliderSelector, 110, 32, invers)
    lcd.drawText(2, 42, "Read Switch", SMLSIZE + LEFT)
    IVdraw(readSwitchSelector, 110, 42, invers)
 
    return doKey(event)
end

return {run = run, init=init}