local compileFiles = {
    "LAOZHU/SinkRateState.lua",
    "LAOZHU/SinkRateRecord.lua",
    "TELEMETRY/adjust/output.lua",
    "TELEMETRY/adjust.lua",
    "TELEMETRY/adjust/GlobalVar.lua",
    "TELEMETRY/adjust/OutputCurveManager.lua",
    "TELEMETRY/adjust/ReplaceMix.lua",
    "TELEMETRY/adjust/OutputCurve.lua",
    "TELEMETRY/adjust/SelectChannel.lua",
    "TELEMETRY/adjust/SinkRate/SinkRate.lua",
    "TELEMETRY/adjust/SinkRate/SinkRateCfgPage.lua",
    "TELEMETRY/common/button.lua",
    "TELEMETRY/common/CheckBox.lua",
    "TELEMETRY/common/CurveSelector.lua",
    "TELEMETRY/common/Fields.lua",
    "TELEMETRY/common/Selector.lua",
    "TELEMETRY/common/ModeSelector.lua",
    "TELEMETRY/common/InputSelector.lua",
    "TELEMETRY/common/InputView.lua",
    "TELEMETRY/common/NumEdit.lua",
    "TELEMETRY/common/OutputSelector.lua",
    "TELEMETRY/common/TextEdit.lua",
    "TELEMETRY/common/ViewMatrix.lua"
}

local curFileIndex = 1
local this = nil

local function init()
    local fun, err = loadScript(gScriptDir .. "TELEMETRY/common/LoadModule.lua", "bt")
    fun()
end

local function bg()
end


local function run(event, time)
    lcd.clear()
    if curFileIndex > #compileFiles then
        lcd.drawText(1, 20, "installation completed.", SMLSIZE+LEFT)
        lcd.drawText(1, 30, "you must restart the radio", SMLSIZE+LEFT)
        lcd.drawText(1, 40, "to use this script.", SMLSIZE+LEFT)
        return true
    end
    local fun, err = loadScript(gScriptDir .. compileFiles[curFileIndex])
    if fun == nil then
        assert(false, compileFiles[curFileIndex])
    end
    LZ_clearTable(fun)
    fun = nil
    collectgarbage()
    lcd.drawText(1, 20, compileFiles[curFileIndex], SMLSIZE+LEFT)
    curFileIndex = curFileIndex + 1
    if curFileIndex > #compileFiles then
        LZ_markCompiled()
    end
    return true
end

this = {run=run, init=init, bg=bg, pageState=0}

return this