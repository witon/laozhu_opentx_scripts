local varSliderSelector = nil
local readSwitchSelector = nil
local workTimeSwitchSelector = nil
local workTimeResetSwitchSelector = nil
local destTimeSettingStepNumEdit = nil

local selectorArray = nil
local curSelectorIndex = 1
local editingSelector = nil

local function setCfgValue()
    f3kCfg["ReadSw"] = ISgetSelectedItemId(readSwitchSelector)
    f3kCfg["SelSlider"] = ISgetSelectedItemId(varSliderSelector)
    f3kCfg["WtSw"] = ISgetSelectedItemId(workTimeSwitchSelector)
    f3kCfg["WtResetSw"] = ISgetSelectedItemId(workTimeResetSwitchSelector)
    f3kCfg["DestTimeStep"] = destTimeSettingStepNumEdit.num
end

local function getCfgValue()
    ISsetSelectedItemById(readSwitchSelector, f3kCfg["ReadSw"])
    ISsetSelectedItemById(varSliderSelector, f3kCfg["SelSlider"])
    ISsetSelectedItemById(workTimeSwitchSelector, f3kCfg["WtSw"])
    ISsetSelectedItemById(workTimeResetSwitchSelector, f3kCfg["WtResetSw"])
    destTimeSettingStepNumEdit.num = CFGgetNumberField(f3kCfg, "DestTimeStep", 15)
end

local function init()
    LZ_runModule(gScriptDir .. "TELEMETRY/common/InputView.lua")
    LZ_runModule(gScriptDir .. "TELEMETRY/common/InputSelector.lua")
    LZ_runModule(gScriptDir .. "TELEMETRY/common/NumEdit.lua")
    LZ_runModule(gScriptDir .. "TELEMETRY/common/Fields.lua")
    initFieldsInfo()
    varSliderSelector = ISnewInputSelector()
    ISsetFieldType(varSliderSelector, FIELDS_INPUT)
    readSwitchSelector = ISnewInputSelector()
    ISsetFieldType(readSwitchSelector, FIELDS_SWITCH)
    workTimeSwitchSelector = ISnewInputSelector()
    ISsetFieldType(workTimeSwitchSelector, FIELDS_SWITCH)
    workTimeResetSwitchSelector = ISnewInputSelector()
    ISsetFieldType(workTimeResetSwitchSelector, FIELDS_SWITCH)
    destTimeSettingStepNumEdit = NEnewNumEdit()
    destTimeSettingStepNumEdit.step = 5
    selectorArray = {
        destTimeSettingStepNumEdit,
        workTimeSwitchSelector,
        workTimeResetSwitchSelector,
        varSliderSelector,
        readSwitchSelector
    }


    getCfgValue()
end

local function doKey(event)
    if editingSelector then
        if(event == EVT_EXIT_BREAK or event == EVT_ENTER_BREAK) then
            IVsetFocusState(editingSelector, 1)
            editingSelector = nil
            setCfgValue()
            CFGwriteToFile(f3kCfg, gConfigFileName)
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
    IVdraw(destTimeSettingStepNumEdit, 122, 2, invers, SMLSIZE + RIGHT)
    lcd.drawText(2, 12, "WTime Start Switch", SMLSIZE + LEFT)
    IVdraw(workTimeSwitchSelector, 110, 12, invers, SMLSIZE + LEFT)
    lcd.drawText(2, 22, "WTime Reset Switch", SMLSIZE + LEFT)
    IVdraw(workTimeResetSwitchSelector, 110, 22, invers, SMLSIZE + LEFT)
    lcd.drawText(2, 32, "Var Slider", SMLSIZE + LEFT)
    IVdraw(varSliderSelector, 110, 32, invers, SMLSIZE + LEFT)
    lcd.drawText(2, 42, "Read Switch", SMLSIZE + LEFT)
    IVdraw(readSwitchSelector, 110, 42, invers, SMLSIZE + LEFT)
 
    return doKey(event)
end

return {run = run, init=init}