gScriptDir = "/SCRIPTS/"
gAssertFlag = "ASSERT FLAG!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
local numEditArr = {}
local buttonArr = {}
local vm = nil
local state = 2

local function onNumEditChange(numEdit)
end

local function onButtonClick(button)
end
local function unload()
    InputView = nil
    ViewMatrix = nil
    Button = nil
    vm = nil
    for i=1, 5, 1 do
        buttonArr[i] = nil
    end
end


local function load()
    LZ_runModule("TELEMETRY/common/InputViewO.lua")
    --LZ_runModule("TELEMETRY/common/NumEditO.lua")
    LZ_runModule("TELEMETRY/common/ViewMatrixO.lua")
    LZ_runModule("TELEMETRY/common/ButtonO.lua")
    vm = ViewMatrix:new()
    for i=1, 5, 1 do
        --numEditArr[i] = NumEdit:new()
        --numEditArr[i]:setOnChange(onNumEditChange)
        buttonArr[i] = Button:new()
        buttonArr[i].text = "button" .. i
        buttonArr[i]:setOnClick(onButtonClick)
        local row = vm:addRow()
        --row[1] = numEditArr[i]
        row[1] = buttonArr[i]
    end
    vm:updateCurIVFocus()
end

local function init()
    local fun, err = loadScript(gScriptDir .. "TELEMETRY/common/LoadModule.lua", "bt")
    fun()
end

local function run(event)
    if event == 37 then
        state = state + 1
        if state > 2 then
            state = 1
        end
    end

    local invers = false
    if getRtcTime() % 2 == 1 then
        invers = true
    end
    lcd.clear()
    if state == 1 then
        if vm == nil then
            load()
        end
        vm:doKey(event)
        local y = 5
        for i=1, #buttonArr, 1 do
            lcd.drawText(1, y, "NumEdit:", SMLSIZE + LEFT)
            buttonArr[i]:draw(54, y, invers, SMLSIZE + LEFT)
            y = y + 10
        end
    else
        if vm ~= nil then
            unload()
        end
    end
    collectgarbage("collect")
    lcd.drawText(1, 55, collectgarbage("count")*1024, SMLSIZE + LEFT)

end

return {run=run, init=init }