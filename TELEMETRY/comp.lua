gScriptDir = "/SCRIPTS/"

local compileFiles = {
    "TELEMETRY/adjust/output.lua",
    "TELEMETRY/adjust.lua",
    "TELEMETRY/adjust/GlobalVar.lua",
    "TELEMETRY/adjust/OutputCurveManager.lua",
    "TELEMETRY/adjust/ReplaceMix.lua",
    "TELEMETRY/adjust/OutputCurve.lua",
    "TELEMETRY/adjust/SelectChannel.lua",
    "TELEMETRY/common/button.lua",
    "TELEMETRY/common/CheckBox.lua",
    "TELEMETRY/common/CurveSelector.lua",
    "TELEMETRY/common/Fields.lua",
    "TELEMETRY/common/InputSelector.lua",
    "TELEMETRY/common/InputView.lua",
    "TELEMETRY/common/NumEdit.lua",
    "TELEMETRY/common/OutputSelector.lua",
    "TELEMETRY/common/TextEdit.lua",
    "TELEMETRY/common/ViewMatrix.lua"
}


local curFileIndex = 1

local function init()
    local fun, err = loadScript(gScriptDir .. "TELEMETRY/common/LoadModule.lua", "bt")
    fun()
end

local function run(event)
    lcd.clear()
    if curFileIndex > #compileFiles then
        return
    end
    local fun, err = loadScript(gScriptDir .. compileFiles[curFileIndex], "bt")
    lcd.drawText(2, 20, compileFiles[curFileIndex], SMLSIZE+LEFT)
    curFileIndex = curFileIndex + 1
end

return {run=run, init=init }