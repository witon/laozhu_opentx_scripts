local destTimeSettingStepNumEdit = nil
local resetButton = nil
local prepTimeEdit = nil
local testTimeEdit = nil
local noflyTimeEdit = nil
local taskSelector = nil
local viewMatrix = nil

LZ_runModule(gScriptDir .. "TELEMETRY/common/ViewMatrix.lua")
LZ_runModule(gScriptDir .. "TELEMETRY/common/InputView.lua")
LZ_runModule(gScriptDir .. "TELEMETRY/common/Button.lua")
LZ_runModule(gScriptDir .. "TELEMETRY/common/NumEdit.lua")
LZ_runModule(gScriptDir .. "TELEMETRY/common/TimeEdit.lua")
LZ_runModule(gScriptDir .. "TELEMETRY/common/Selector.lua")
LZ_runModule(gScriptDir .. "TELEMETRY/3k/TaskSelector.lua")

local function onTaskSelectorChange(taskSelector)
    f3kCfg["task"] = SgetSelectedText(taskSelector)
    CFGwriteToFile(f3kCfg, gConfigFileName)
    gF3kCore.resetRound()
end

local function setCfgValue()
    f3kCfg["DestTimeStep"] = destTimeSettingStepNumEdit.num
    f3kCfg["PrepTime"] = prepTimeEdit.num
    f3kCfg["TestTime"] = testTimeEdit.num
    f3kCfg["NFlyTime"] = noflyTimeEdit.num
end

local function getCfgValue()
    destTimeSettingStepNumEdit.num = CFGgetNumberField(f3kCfg, "DestTimeStep", 15)
    prepTimeEdit.num = CFGgetNumberField(f3kCfg, "PrepTime", 120)
    testTimeEdit.num = CFGgetNumberField(f3kCfg, "TestTime", 40)
    noflyTimeEdit.num = CFGgetNumberField(f3kCfg, "NFlyTime", 60)
end

local function onNumEditChange(numEdit)
    setCfgValue()
    CFGwriteToFile(f3kCfg, gConfigFileName)
end

local function destroy()
    VMunload()
    IVunload()
    NEunload()
    TIMEEunload()
    BTunload()
    Sunload()
    TSunload()
end

local function onResetRoundButtonClicked()
    gF3kCore.resetRound()
end

local function init()
    resetButton = BTnewButton()
    resetButton.text = "Reset Round"
    BTsetOnClick(resetButton, onResetRoundButtonClicked)

    taskSelector = TSnewTaskSelector()
    TSsetTask(taskSelector, f3kCfg["task"])
    SsetOnChange(taskSelector, onTaskSelectorChange)

    destTimeSettingStepNumEdit = NEnewNumEdit()
    destTimeSettingStepNumEdit.step = 5
    NEsetRange(destTimeSettingStepNumEdit, 1, 60)
    NEsetOnChange(destTimeSettingStepNumEdit, onNumEditChange)

    prepTimeEdit = TIMEEnewTimeEdit()
    NEsetRange(prepTimeEdit, 0, 600)
    prepTimeEdit.step = 5
    NEsetOnChange(prepTimeEdit, onNumEditChange)

    testTimeEdit = TIMEEnewTimeEdit()
    NEsetRange(testTimeEdit, 0, 600)
    testTimeEdit.step = 5
    NEsetOnChange(testTimeEdit, onNumEditChange)

    noflyTimeEdit = TIMEEnewTimeEdit()
    NEsetRange(noflyTimeEdit, 0, 600)
    noflyTimeEdit.step = 5
    NEsetOnChange(noflyTimeEdit, onNumEditChange)

    viewMatrix = VMnewViewMatrix()
    local row = VMaddRow(viewMatrix)
    row[1] = resetButton
    local row = VMaddRow(viewMatrix)
    row[1] = taskSelector
    local row = VMaddRow(viewMatrix)
    row[1] = destTimeSettingStepNumEdit
    row = VMaddRow(viewMatrix)
    row[1] = prepTimeEdit
    row = VMaddRow(viewMatrix)
    row[1] = testTimeEdit
    row = VMaddRow(viewMatrix)
    row[1] = noflyTimeEdit
    VMupdateCurIVFocus(viewMatrix)
    getCfgValue()
end

local function doKey(event)
    local eventProcessed = VMdoKey(viewMatrix, event)
    return eventProcessed
end

local function run(event, time)
    local invers = false
    if getRtcTime() % 2 == 1 then
        invers = true
    end

    lcd.drawFilledRectangle(0, 0, 128, 8, FORCE)
    lcd.drawText(0, 0, "Round Setup", SMLSIZE + LEFT + INVERS)

    local drawOptions
    IVdraw(resetButton, 128, 10, invers, SMLSIZE + RIGHT)
    lcd.drawText(0, 19, "Task", SMLSIZE + LEFT)
    IVdraw(taskSelector, 128, 19, invers, SMLSIZE + RIGHT)
    lcd.drawText(0, 28, "Flight Time Step", SMLSIZE + LEFT)
    IVdraw(destTimeSettingStepNumEdit, 128, 28, invers, SMLSIZE + RIGHT)
    lcd.drawText(0, 37, "Preparation Time", SMLSIZE + LEFT)
    IVdraw(prepTimeEdit, 128, 37, invers, SMLSIZE + RIGHT)
    lcd.drawText(0, 46, "Test Time", SMLSIZE + LEFT)
    IVdraw(testTimeEdit, 128, 46, invers, SMLSIZE + RIGHT)
    lcd.drawText(0, 55, "No Fly Time", SMLSIZE + LEFT)
    IVdraw(noflyTimeEdit, 128, 55, invers, SMLSIZE + RIGHT)
 
    return doKey(event)
end

return {
    run = run,
    init = init,
    destroy = destroy
}
