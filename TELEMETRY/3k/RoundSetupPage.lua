local destTimeSettingStepNumEdit = nil
local resetButton = nil
local prepTimeEdit = nil
local testTimeEdit = nil
local noflyTimeEdit = nil
local taskSelector = nil
local muteCheckbox = nil
local viewMatrix = nil
local lineArray = nil

LZ_runModule("TELEMETRY/common/ViewMatrixO.lua")
LZ_runModule("TELEMETRY/common/InputViewO.lua")
LZ_runModule("TELEMETRY/common/ButtonO.lua")
LZ_runModule("TELEMETRY/common/NumEditO.lua")
LZ_runModule("TELEMETRY/common/TimeEditO.lua")
LZ_runModule("TELEMETRY/common/SelectorO.lua")
LZ_runModule("TELEMETRY/3k/TaskSelectorO.lua")
LZ_runModule("TELEMETRY/common/CheckBoxO.lua")

local function onTaskSelectorChange(taskSelector)
    f3kCfg.kvs["task"] = taskSelector:getText(taskSelector.selectedIndex)
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
    taskSelector:setTask(f3kCfg:getStrField("task", "Train"))
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
    ViewMatrix = nil
    InputView = nil
    NumEdit = nil
    TimeEdit = nil
    Button = nil
    Selector = nil
    TaskSelector = nil
    CheckBox = nil
end

local function onResetRoundButtonClicked()
    gF3kCore.resetRound()
end

local function onMuteCheckBoxChanged(checkbox)
    setCfgValue()
    f3kCfg:writeToFile(gConfigFileName)
end

local function init()
    resetButton = Button:new()
    resetButton.text = "Reset Round"
    resetButton:setOnClick(onResetRoundButtonClicked)

    taskSelector = TaskSelector:new()
    taskSelector:setOnChange(onTaskSelectorChange)

    destTimeSettingStepNumEdit = NumEdit:new()
    destTimeSettingStepNumEdit.step = 5
    destTimeSettingStepNumEdit:setRange(1, 60)
    destTimeSettingStepNumEdit:setOnChange(onNumEditChange)

    prepTimeEdit = TimeEdit:new()
    prepTimeEdit:setRange(0, 600)
    prepTimeEdit.step = 5
    prepTimeEdit:setOnChange(onNumEditChange)

    testTimeEdit = TimeEdit:new()
    testTimeEdit:setRange(0, 600)
    testTimeEdit.step = 5
    testTimeEdit:setOnChange(onNumEditChange)

    noflyTimeEdit = TimeEdit:new()
    noflyTimeEdit:setRange(0, 600)
    noflyTimeEdit.step = 5
    noflyTimeEdit:setOnChange(onNumEditChange)

    muteCheckbox = CheckBox:new()
    muteCheckbox:setOnChange(onMuteCheckBoxChanged)
    muteCheckbox.checked = false

    viewMatrix = ViewMatrix:new()
    local row = viewMatrix:addRow()
    row[1] = resetButton
    row = viewMatrix:addRow()
    row[1] = taskSelector
    row = viewMatrix:addRow()
    row[1] = destTimeSettingStepNumEdit
    row = viewMatrix:addRow()
    row[1] = prepTimeEdit
    row = viewMatrix:addRow()
    row[1] = testTimeEdit
    row = viewMatrix:addRow()
    row[1] = noflyTimeEdit
    row = viewMatrix:addRow()
    row[1] = muteCheckbox
    viewMatrix:updateCurIVFocus()
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
    local eventProcessed = viewMatrix:doKey(event)
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
        lineArray[i][2]:draw(128, y, invers, SMLSIZE + RIGHT)
        y = y + 9
    end
    return doKey(event)
end

return {
    run = run,
    init = init,
    destroy = destroy
}
