
local varSliderSelector = dofile("/SCRIPTS/TELEMETRY/InputSelector.lua")
initFieldsInfo()
varSliderSelector.setFieldType(FIELDS_INPUT)
local readSwitchSelector = dofile("/SCRIPTS/TELEMETRY/InputSelector.lua")
readSwitchSelector.setFieldType(FIELDS_SWITCH)
local workTimeSwitchSelector = dofile("/SCRIPTS/TELEMETRY/InputSelector.lua")
workTimeSwitchSelector.setFieldType(FIELDS_SWITCH)


local selectorArray = {
    varSliderSelector,
    readSwitchSelector,
    workTimeSwitchSelector
}
local curSelectorIndex = 1
local editingSelector = nil

local function setCfgValue()
    f3kCfg.setVarReadSwitch(readSwitchSelector.getSelectedItemId())
    f3kCfg.setVarSelectorSlider(varSliderSelector.getSelectedItemId())
    f3kCfg.setWorkTimeSwitch(workTimeSwitchSelector.getSelectedItemId())
end

local function getCfgValue()
    readSwitchSelector.setSelectedItemById(f3kCfg.getVarReadSwitch())
    varSliderSelector.setSelectedItemById(f3kCfg.getVarSelectorSlider())
    workTimeSwitchSelector.setSelectedItemById(f3kCfg.getWorkTimeSwitch())
end
local function init()
    getCfgValue()
end

local function doKey(event)
    if editingSelector then
        if(event == EVT_EXIT_BREAK or event == EVT_ENTER_BREAK) then
            editingSelector.setFocusState(1)
            editingSelector = nil
            f3kCfg.writeToFile()
            return
        end
        editingSelector.doKey(event)
        setCfgValue()
        return
    end


 
    if(event == EVT_ENTER_BREAK) then
        editingSelector = selectorArray[curSelectorIndex]
        editingSelector.setFocusState(2)
        return
    end

    preFocus = selectorArray[curSelectorIndex]
	if(event==36 or event==68) then
		curSelectorIndex = curSelectorIndex - 1
		if curSelectorIndex < 1 then
            curSelectorIndex = 1
		end
	elseif(event==35 or event==67) then
		curSelectorIndex = curSelectorIndex + 1
		if curSelectorIndex > #selectorArray then
			curSelectorIndex = #selectorArray
        end
    end
    preFocus.setFocusState(0)
    selectorArray[curSelectorIndex].setFocusState(1)
end

local function run(event, time)
    local invers = false
    if time % 2 == 1 then
        invers = true
    end
    doKey(event)
    local drawOptions
    lcd.drawText(2, 10, "Var Slider", SMLSIZE + LEFT)
    varSliderSelector.drawSelector(64, 10, invers)
    lcd.drawText(2, 22, "Read Switch", SMLSIZE + LEFT)
    readSwitchSelector.drawSelector(64, 22, invers)
    lcd.drawText(2, 34, "WTime Switch", SMLSIZE + LEFT)
    workTimeSwitchSelector.drawSelector(64, 34)

end

return {run = run, init=init}