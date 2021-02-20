
local varSliderSelector = ISnewInputSelector()
ISsetFieldType(varSliderSelector, FIELDS_INPUT)
local readSwitchSelector = ISnewInputSelector()
ISsetFieldType(readSwitchSelector, FIELDS_SWITCH)

local resetSwitchSelector = ISnewInputSelector()
ISsetFieldType(resetSwitchSelector, FIELDS_SWITCH)
local flightSwitchSelector = ISnewInputSelector()
ISsetFieldType(flightSwitchSelector, FIELDS_SWITCH)
local throttleChannelSelector = ISnewInputSelector()
ISsetFieldType(throttleChannelSelector, FIELDS_CHANNEL) 
local throttleThresholdNumEdit = NEnewNumEdit()



local inputArray = {
    varSliderSelector,
    readSwitchSelector,
    resetSwitchSelector,
    flightSwitchSelector,
    throttleChannelSelector,
    throttleThresholdNumEdit
}

local curSelectorIndex = 1
local editingSelector = nil

local function setCfgValue()
    f5jCfg["ReadSw"] = ISgetSelectedItemId(readSwitchSelector)
    f5jCfg["SelSlider"] = ISgetSelectedItemId(varSliderSelector)
    f5jCfg["RsSw"] = ISgetSelectedItemId(resetSwitchSelector)
    f5jCfg["FlSw"] = ISgetSelectedItemId(flightSwitchSelector)
    f5jCfg["ThCh"] = ISgetSelectedItemId(throttleChannelSelector)
    f5jCfg["ThThreshold"] = throttleThresholdNumEdit.num
end

local function getCfgValue()
    ISsetSelectedItemById(readSwitchSelector, f5jCfg["ReadSw"])
    ISsetSelectedItemById(varSliderSelector, f5jCfg["SelSlider"])
    ISsetSelectedItemById(resetSwitchSelector, f5jCfg["RsSw"])
    ISsetSelectedItemById(flightSwitchSelector, f5jCfg["FlSw"])
    ISsetSelectedItemById(throttleChannelSelector, f5jCfg["ThCh"])
    throttleThresholdNumEdit.num = CFGgetNumberField(f5jCfg, "ThThreshold", 0)
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
            CFGwriteToFile(f5jCfg, gConfigFileName)
            return true
        end
        editingSelector.doKey(editingSelector, event)
        return true
    end
 
    if(event == EVT_ENTER_BREAK) then
        editingSelector = inputArray[curSelectorIndex]
        IVsetFocusState(editingSelector, 2)
        return true
    end

    local eventProcessed = false

    local preFocus = inputArray[curSelectorIndex]
	if(event==36 or event==68) then
		curSelectorIndex = curSelectorIndex - 1
		if curSelectorIndex < 1 then
            curSelectorIndex = 1
        end
        eventProcessed = true
	elseif(event==35 or event==67) then
		curSelectorIndex = curSelectorIndex + 1
		if curSelectorIndex > #inputArray then
			curSelectorIndex = #inputArray
        end
        eventProcessed = true
    end
    IVsetFocusState(preFocus, 0)
    IVsetFocusState(inputArray[curSelectorIndex], 1)
    return eventProcessed
end

local function run(event, time)
    local invers = false
    if getRtcTime() % 2 == 1 then
        invers = true
    end
    local drawOptions
    lcd.drawText(2, 1, "Var Slider", SMLSIZE + LEFT)
    IVdraw(varSliderSelector, 100, 1, invers, SMLSIZE + LEFT)
    lcd.drawText(2, 11, "Read Switch", SMLSIZE + LEFT)
    IVdraw(readSwitchSelector, 100, 11, invers, SMLSIZE + LEFT)
    lcd.drawText(2, 21, "Reset Switch", SMLSIZE + LEFT)
    IVdraw(resetSwitchSelector, 100, 21, invers, SMLSIZE + LEFT)
    lcd.drawText(2, 31, "Flight Switch", SMLSIZE + LEFT)
    IVdraw(flightSwitchSelector, 100, 31, invers, SMLSIZE + LEFT)
    lcd.drawText(2, 41, "Throttle Channel", SMLSIZE + LEFT)
    IVdraw(throttleChannelSelector, 100, 41, invers, SMLSIZE + LEFT)
    lcd.drawText(2, 51, "Throttle Threshold", SMLSIZE + LEFT)
    IVdraw(throttleThresholdNumEdit, 117, 51, invers, SMLSIZE + RIGHT)
 
    return doKey(event)

end

return {run = run, init=init}