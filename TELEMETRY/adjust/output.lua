local output1 = OSnewOutputSelector()
local output2 = OSnewOutputSelector()
local adjustCheckBox = CBnewCheckBox()
local channel1ReverseCB= CBnewCheckBox()
local channel2ReverseCB= CBnewCheckBox()





local channel1MinNumEdit = NEnewNumEdit()
local channel1CenterNumEdit = NEnewNumEdit()
local channel1MaxNumEdit = NEnewNumEdit()
local channel2MinNumEdit = NEnewNumEdit()
local channel2CenterNumEdit = NEnewNumEdit()
local channel2MaxNumEdit = NEnewNumEdit()

local ivArray = {
    adjustCheckBox,
    output1,
    output2,
}

local function onOutputSelectorChange(outputSelector)
    local o = model.getOutput(outputSelector.selectedIndex)
    if not o then
        return
    end
    if outputSelector == output1 then
        channel1MinNumEdit.num = o.min
        channel1MaxNumEdit.num = o.max
        channel1CenterNumEdit.num = o.offset
    elseif outputSelector == output2 then
        channel2MinNumEdit.num = o.min
        channel2MaxNumEdit.num = o.max
        channel2CenterNumEdit.num = o.offset
    end
end

local function onAdjustCheckBoxChange(checkBox)
    if checkBox.checked then
        if output1.selectedIndex == output2.selectedIndex then
            checkBox.checked = false
            return
        end
        onOutputSelectorChange(output1)
        onOutputSelectorChange(output2)
        ivArray = {
            adjustCheckBox,
            channel1MinNumEdit,
            channel2MinNumEdit,
            channel1CenterNumEdit,
            channel2CenterNumEdit,
            channel1MaxNumEdit,
            channel2MaxNumEdit,
            channel1ReverseCB,
            channel2ReverseCB
        }
        replaceMix(output1.selectedIndex, channel1ReverseCB.checked)
        replaceMix(output2.selectedIndex, channel2ReverseCB.checked)
    else
        ivArray = {
            adjustCheckBox,
            output1,
            output2
        }
        recoverMix(output1.selectedIndex)
        recoverMix(output2.selectedIndex)
    end
end

local function onReverseCheckBoxChange(checkBox)
    local channel = output1.selectedIndex
    if checkBox == channel2ReverseCB then
        channel = output2.selectedIndex
    end
    recoverMix(channel)
    replaceMix(channel, checkBox.checked)

end


local function onNumEditChange(numEdit)
    if numEdit == channel1MinNumEdit or numEdit == channel1MaxNumEdit or numEdit == channel1CenterNumEdit then
        local o1 = model.getOutput(output1.selectedIndex)
        o1.min = channel1MinNumEdit.num
        o1.max = channel1MaxNumEdit.num
        o1.offset = channel1CenterNumEdit.num
        model.setOutput(output1.selectedIndex, o1)
    elseif  numEdit == channel2MinNumEdit or numEdit == channel2MaxNumEdit or numEdit == channel2CenterNumEdit then 
        local o2 = model.getOutput(output2.selectedIndex)
        o2.min = channel2MinNumEdit.num
        o2.max = channel2MaxNumEdit.num
        o2.offset = channel2CenterNumEdit.num
        model.setOutput(output2.selectedIndex, o2)
    end
end

local curIvIndex = 1
local editingIv = nil

local function init()
    NEsetOnChange(channel1MinNumEdit, onNumEditChange)
    NEsetOnChange(channel1CenterNumEdit, onNumEditChange)
    NEsetOnChange(channel1MaxNumEdit, onNumEditChange)
    NEsetOnChange(channel2MinNumEdit, onNumEditChange)
    NEsetOnChange(channel2CenterNumEdit, onNumEditChange)
    NEsetOnChange(channel2MaxNumEdit, onNumEditChange)

    NEsetRange(channel1MinNumEdit, -1500, 1500)
    NEsetRange(channel1CenterNumEdit, -1500, 1500)
    NEsetRange(channel1MaxNumEdit, -1500, 1500)
    NEsetRange(channel2MinNumEdit, -1500, 1500)
    NEsetRange(channel2CenterNumEdit, -1500, 1500)
    NEsetRange(channel2MaxNumEdit, -1500, 1500)
 
    OSsetOnChange(output1, onOutputSelectorChange)
    OSsetOnChange(output2, onOutputSelectorChange)
    CBsetOnChange(adjustCheckBox, onAdjustCheckBoxChange)
    CBsetOnChange(channel1ReverseCB, onReverseCheckBoxChange)
    CBsetOnChange(channel2ReverseCB, onReverseCheckBoxChange)
 
    dofile(gScriptDir .. "TELEMETRY/adjust/ReplaceMix.lua")
    onOutputSelectorChange(output1)
    onOutputSelectorChange(output2)
end

local function doKey(event)
    if editingIv then
        if(event == EVT_EXIT_BREAK or event == EVT_ENTER_BREAK) then
            IVsetFocusState(editingIv, 1)
            editingIv = nil
            return true
        end
        editingIv.doKey(editingIv, event)
        return true
    end
 
    if(event == EVT_ENTER_BREAK) then
        editingIv = ivArray[curIvIndex]
        IVsetFocusState(editingIv, 2)
        return true
    end
    local eventProcessed = false

    local preFocus = ivArray[curIvIndex]
	if(event==36 or event==68) then
		curIvIndex = curIvIndex - 1
		if curIvIndex < 1 then
            curIvIndex = 1
        end
        eventProcessed = true
	elseif(event==35 or event==67) then
        curIvIndex = curIvIndex + 1
		if curIvIndex > #ivArray then
            curIvIndex = #ivArray
        end
        eventProcessed = true
    end
    IVsetFocusState(preFocus, 0)
    IVsetFocusState(ivArray[curIvIndex], 1)
    return eventProcessed
end

local function run(event, time)
    local invers = false
    if getRtcTime() % 2 == 1 then
        invers = true
    end

    lcd.drawText(2, 5, "thr:", SMLSIZE + LEFT)
    lcd.drawText(34, 5, getValue("thr"), SMLSIZE+LEFT)

    lcd.drawText(64, 5, "adj:", SMLSIZE + LEFT)
    IVdraw(adjustCheckBox, 84, 5, invers)

    lcd.drawText(2, 15, "output1:", SMLSIZE + LEFT)
    IVdraw(output1, 42, 15, invers)
    lcd.drawText(66, 15, "output2:", SMLSIZE + LEFT)
    IVdraw(output2, 106, 15, invers)

    lcd.drawText(2, 25, "min:", SMLSIZE+LEFT)
    IVdraw(channel1MinNumEdit, 62, 25, invers)
    IVdraw(channel2MinNumEdit, 126, 25, invers)

    lcd.drawText(2, 35, "center:", SMLSIZE+LEFT)
    IVdraw(channel1CenterNumEdit, 62, 35, invers)
    IVdraw(channel2CenterNumEdit, 126, 35, invers)

    lcd.drawText(2, 45, "max:", SMLSIZE+LEFT)
    IVdraw(channel1MaxNumEdit, 62, 45, invers)
    IVdraw(channel2MaxNumEdit, 126, 45, invers)

    lcd.drawText(2, 55, "reverse:", SMLSIZE+LEFT)
    IVdraw(channel1ReverseCB, 56, 55, invers)
    IVdraw(channel2ReverseCB, 120, 55, invers)


    return doKey(event)
end

return {run = run, init=init}