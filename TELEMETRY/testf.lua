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
    IVunload()
    BTunload()
    VMunload()
    vm = nil
    for i=1, 5, 1 do
        buttonArr[i] = nil
    end
end

local function load()
    LZ_runModule("TELEMETRY/common/InputView.lua")
    --LZ_runModule("TELEMETRY/common/NumEdit.lua")
    LZ_runModule("TELEMETRY/common/Button.lua")
    LZ_runModule("TELEMETRY/common/ViewMatrix.lua")

    vm = VMnewViewMatrix()
    for i=1, 5, 1 do
        --numEditArr[i] = NEnewNumEdit()
        --NEsetOnChange(numEditArr, onNumEditChange)
        local row = VMaddRow(vm)
        buttonArr[i] = BTnewButton()
        BTsetOnClick(buttonArr[i], onButtonClick)
        --row[1] = numEditArr[i]
        row[1] = buttonArr[i]
        buttonArr[i].text = "button" .. i
    end
    VMupdateCurIVFocus(vm)
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
        VMdoKey(vm, event)
        local y = 5
        for i=1, #buttonArr, 1 do
            lcd.drawText(1, y, "NumEdit:", SMLSIZE + LEFT)
            IVdraw(buttonArr[i], 54, y, invers, SMLSIZE + LEFT)
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