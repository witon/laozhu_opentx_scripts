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

local selectorArray = {
    varSliderSelector,
    readSwitchSelector,
    resetSwitchSelector,
    flightSwitchSelector,
    throttleChannelSelector
}

local curSelectorIndex = 1
local editingSelector = nil

local function setCfgValue()
    local cfgs = f5jCfg.getCfgs()
    cfgs["ReadSw"] = ISgetSelectedItemId(readSwitchSelector)
    cfgs["SelSlider"] = ISgetSelectedItemId(varSliderSelector)
    cfgs["RsSw"] = ISgetSelectedItemId(resetSwitchSelector)
    cfgs["FlSw"] = ISgetSelectedItemId(flightSwitchSelector)
    cfgs["ThCh"] = ISgetSelectedItemId(throttleChannelSelector)
end

local function getCfgValue()
    local cfgs = f5jCfg.getCfgs()
    ISsetSelectedItemById(readSwitchSelector, cfgs["ReadSw"])
    ISsetSelectedItemById(varSliderSelector, cfgs["SelSlider"])
    ISsetSelectedItemById(resetSwitchSelector, cfgs["RsSw"])
    ISsetSelectedItemById(flightSwitchSelector, cfgs["FlSw"])
    ISsetSelectedItemById(throttleChannelSelector, cfgs["ThCh"])
end

local function init()
    getCfgValue()
end

local function doKey(event)
    if editingSelector then
        if(event == EVT_EXIT_BREAK or event == EVT_ENTER_BREAK) then
            ISsetFocusState(editingSelector, 1)
            editingSelector = nil
            setCfgValue()
            f5jCfg.writeToFile(gConfigFileName)
            return true
        end
        ISdoKey(editingSelector, event)
        return true
    end
 
    if(event == EVT_ENTER_BREAK) then
        editingSelector = selectorArray[curSelectorIndex]
        ISsetFocusState(editingSelector, 2)
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
    ISsetFocusState(preFocus, 0)
    ISsetFocusState(selectorArray[curSelectorIndex], 1)
    return eventProcessed
end

local function run(event, time)
    local invers = false
    if getRtcTime() % 2 == 1 then
        invers = true
    end
    local drawOptions
    lcd.drawText(2, 5, "Var Slider", SMLSIZE + LEFT)
    ISdrawSelector(varSliderSelector, 84, 5, invers)
    lcd.drawText(2, 17, "Read Switch", SMLSIZE + LEFT)
    ISdrawSelector(readSwitchSelector, 84, 17, invers)
    lcd.drawText(2, 29, "Reset Switch", SMLSIZE + LEFT)
    ISdrawSelector(resetSwitchSelector, 84, 29, invers)
    lcd.drawText(2, 41, "Flight Switch", SMLSIZE + LEFT)
    ISdrawSelector(flightSwitchSelector, 84, 41, invers)
    lcd.drawText(2, 53, "Throttle Channel", SMLSIZE + LEFT)
    ISdrawSelector(throttleChannelSelector, 84, 53, invers)
    return doKey(event)

end

return {run = run, init=init}