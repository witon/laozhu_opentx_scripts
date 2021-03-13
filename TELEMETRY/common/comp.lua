local compileFiles = {
    "LAOZHU/Cfg.lua",
    "LAOZHU/DataFileDecode.lua",
    "LAOZHU/EmuTestUtils.lua",
    "LAOZHU/F3kFlightRecord.lua",
    "LAOZHU/f3kReadVarMap.lua",
    "LAOZHU/F3kState.lua",
    "LAOZHU/f5jReadVarMap.lua",
    "LAOZHU/F5jState.lua",
    "LAOZHU/readVar.lua",
    "LAOZHU/SinkRateLog.lua",
    "LAOZHU/SinkRateRecord.lua",
    "LAOZHU/SinkRateState.lua",
    "LAOZHU/SwitchTrigeDetector.lua",
    "LAOZHU/Timer.lua",
    "LAOZHU/utils.lua",

    "TELEMETRY/3k/f3kCore.lua",
    "TELEMETRY/3k/FlightPage.lua",
    "TELEMETRY/3k/FlightStaticPage.lua",
    "TELEMETRY/3k/LargeFontFlightListPage.lua",
    "TELEMETRY/3k/SetupPage.lua",
    "TELEMETRY/3k/SmallFontFlightListPage.lua",
    "TELEMETRY/3k/F3kRecordListView.lua",


    "TELEMETRY/5j/FlightPage.lua",
    "TELEMETRY/5j/LargeFontFlightListPage.lua",
    "TELEMETRY/5j/SetupPage.lua",
    "TELEMETRY/5j/SmallFontFlightListPage.lua",

    "TELEMETRY/adjust/SinkRate/RecordListView.lua",
    "TELEMETRY/adjust/SinkRate/SinkRate.lua",
    "TELEMETRY/adjust/SinkRate/SinkRateCfgPage.lua",

    "TELEMETRY/adjust/BackupOutput.lua",
    "TELEMETRY/adjust/GlobalVar.lua",
    "TELEMETRY/adjust/ManagerOutput.lua",
    "TELEMETRY/adjust/output.lua",
    "TELEMETRY/adjust/OutputCurve.lua",
    "TELEMETRY/adjust/OutputCurveManager.lua",
    "TELEMETRY/adjust/ReplaceMix.lua",
    "TELEMETRY/adjust/SaveAndRestoreParam.lua",
    "TELEMETRY/adjust/SelectChannel.lua",

    "TELEMETRY/common/button.lua",
    "TELEMETRY/common/CheckBox.lua",
    "TELEMETRY/common/CurveSelector.lua",
    "TELEMETRY/common/Fields.lua",
    "TELEMETRY/common/InputSelector.lua",
    "TELEMETRY/common/InputView.lua",
    "TELEMETRY/common/ModeSelector.lua",
    "TELEMETRY/common/NumEdit.lua",
    "TELEMETRY/common/OutputSelector.lua",
    "TELEMETRY/common/Selector.lua",
    "TELEMETRY/common/TextEdit.lua",
    "TELEMETRY/common/ViewMatrix.lua",
    "TELEMETRY/3ktel.lua",
    "TELEMETRY/5jtel.lua",
    "TELEMETRY/adjust.lua",
    "TELEMETRY/ut.lua"
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
        lcd.drawText(1, 30, "press exit key to start.", SMLSIZE+LEFT)
        --lcd.drawText(1, 30, "you must restart the radio", SMLSIZE+LEFT)
        --lcd.drawText(1, 40, "to use this script.", SMLSIZE+LEFT)
        if event ~= EVT_EXIT_BREAK then
            return true
        else
            return false
        end
    end
    local fun, err = loadScript(gScriptDir .. compileFiles[curFileIndex])
    if fun == nil then
        assert(false, compileFiles[curFileIndex])
    end
    LZ_clearTable(fun)
    fun = nil
    collectgarbage()
    lcd.drawText(1, 20, "compiling", SMLSIZE+LEFT)
    lcd.drawText(1, 30, compileFiles[curFileIndex], SMLSIZE+LEFT)
    curFileIndex = curFileIndex + 1
    if curFileIndex > #compileFiles then
        LZ_markCompiled()
    end
    return true
end

this = {run=run, init=init, bg=bg, pageState=0}

return this