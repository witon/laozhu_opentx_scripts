local destTimeSettingStepNumEdit = nil
local resetButton = nil
local prepTimeEdit = nil
local testTimeEdit = nil
local noflyTimeEdit = nil
local taskSelector = nil
local muteCheckbox = nil
local viewMatrix = nil
local lineArray = nil

LZ_runModule(gScriptDir .. "TELEMETRY/common/ViewMatrix.lua")
LZ_runModule(gScriptDir .. "TELEMETRY/common/InputView.lua")
LZ_runModule(gScriptDir .. "TELEMETRY/common/Button.lua")
LZ_runModule(gScriptDir .. "TELEMETRY/common/NumEdit.lua")
LZ_runModule(gScriptDir .. "TELEMETRY/common/TimeEdit.lua")
LZ_runModule(gScriptDir .. "TELEMETRY/common/Selector.lua")
LZ_runModule(gScriptDir .. "TELEMETRY/3k/TaskSelector.lua")
LZ_runModule(gScriptDir .. "TELEMETRY/common/CheckBox.lua")

local function onTaskSelectorChange(taskSelector)
    f3kCfg.kvs["task"] = SgetSelectedText(taskSelector)
    f3kCfg:writeToFile(gConfigFileName)
    gF3kCore.resetRound()
end

local function setCfgValue()
    local kvs = f3kCfg.kvs
    kvs["DestTimeStep"] = destTimeSettingStepNumEdit.num
    kvs["PrepTime"] = prepTimeEdit.num
    kvs["TestTime"] = testTimeEdit.num
    kvs["NFlyTime"] = noflyTimeEdit.num
    if muteCheckbox.checked then
        kvs["MuteRndTimer"] = 1
    else
        kvs["MuteRndTimer"] = 0
    end
end

local function getCfgValue()
    destTimeSettingStepNumEdit.num = f3kCfg:getNumberField("DestTimeStep", 15)
    prepTimeEdit.num = f3kCfg:getNumberField("PrepTime", 120)
    testTimeEdit.num = f3kCfg:getNumberField("TestTime", 40)
    noflyTimeEdit.num = f3kCfg:getNumberField("NFlyTime", 60)
    TSsetTask(taskSelector, f3kCfg:getStrField("task", "Train"))
    if f3kCfg:getNumberField("MuteRndTimer", 0) == 0 then
        muteCheckbox.checked = false
    else
        muteCheckbox.checked = true
    end
end

local function onNumEditChange(numEdit)
    setCfgValue()
    f3kCfg:writeToFile(gConfigFileName)
end

local function destroy()
    VMunload()
    IVunload()
    NEunload()
    TIMEEunload()
    BTunload()
    Sunload()
    TSunload()
    CBunload()
end

local function onResetRoundButtonClicked()
    gF3kCore.resetRound()
end

local function onMuteCheckBoxChanged(checkbox)
    setCfgValue()
    f3kCfg:writeToFile(gConfigFileName)
end

local function init()
    resetButton = BTnewButton()
    resetButton.text = "Reset Round"
    BTsetOnClick(resetButton, onResetRoundButtonClicked)

    taskSelector = TSnewTaskSelector()
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

    muteCheckbox = CBnewCheckBox()
    CBsetOnChange(muteCheckbox, onMuteCheckBoxChanged)
    muteCheckbox.checked = false

    viewMatrix = VMnewViewMatrix()
    local row = VMaddRow(viewMatrix)
    row[1] = resetButton
    row = VMaddRow(viewMatrix)
    row[1] = taskSelector
    row = VMaddRow(viewMatrix)
    row[1] = destTimeSettingStepNumEdit
    row = VMaddRow(viewMatrix)
    row[1] = prepTimeEdit
    row = VMaddRow(viewMatrix)
    row[1] = testTimeEdit
    row = VMaddRow(viewMatrix)
    row[1] = noflyTimeEdit
    row = VMaddRow(viewMatrix)
    row[1] = muteCheckbox
    VMupdateCurIVFocus(viewMatrix)
    lineArray = {{"", resetButton},
        {"Task", taskSelector},
        {"Flight Time Step", destTimeSettingStepNumEdit},
        {"Preparation Time", prepTimeEdit},
        {"Test Time", testTimeEdit},
        {"No Fly Time", noflyTimeEdit},
        {"Mute Round Timer", muteCheckbox}}
    getCfgValue()
    viewMatrix.visibleRows = 6
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

    local y = 10
    for i=viewMatrix.scrollLine + 1, 7, 1 do
        lcd.drawText(0, y, lineArray[i][1], SMLSIZE + LEFT)
        IVdraw(lineArray[i][2], 128, y, invers, SMLSIZE + RIGHT)
        y = y + 9
    end
    return doKey(event)
end

return {
    run = run,
    init = init,
    destroy = destroy
}
