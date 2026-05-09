local files = {

	"LAOZHU/Cfg.lua",

	"LAOZHU/CfgO.lua",

	"LAOZHU/DataFileDecode.lua",

	"LAOZHU/EmuTestUtils.lua",

	"LAOZHU/F3k/F3kFlightRecord.lua",

	"LAOZHU/F3k/F3kState.lua",

	"LAOZHU/F3k/f3kReadVarMap.lua",

	"LAOZHU/F3kWF/AULDWF.lua",

	"LAOZHU/F3kWF/CommonTaskWF.lua",

	"LAOZHU/F3kWF/F3kCompetitionWF.lua",

	"LAOZHU/F3kWF/F3kRoundWF.lua",

	"LAOZHU/F5jState.lua",

	"LAOZHU/LDReadVarMap.lua",

	"LAOZHU/LDRecord.lua",

	"LAOZHU/LDState.lua",

	"LAOZHU/LuaUtils.lua",

	"LAOZHU/Monitor.lua",

	"LAOZHU/OTUtils.lua",

	"LAOZHU/Queue.lua",

	"LAOZHU/Sensor.lua",

	"LAOZHU/SinkRateLog.lua",

	"LAOZHU/SinkRateReadVarMap.lua",

	"LAOZHU/SinkRateRecord.lua",

	"LAOZHU/SinkRateState.lua",

	"LAOZHU/SwitchTrigeDetector.lua",

	"LAOZHU/comm/LinuxSound.lua",

	"LAOZHU/comm/OTSound.lua",

	"LAOZHU/comm/PCIO.lua",

	"LAOZHU/comm/TestSound.lua",

	"LAOZHU/comm/Timer.lua",

	"LAOZHU/f5jReadVarMap.lua",

	"LAOZHU/launchReadVarMap.lua",

	"LAOZHU/launchRecord.lua",

	"LAOZHU/readVar.lua",

	"TELEMETRY/3k/F3KRecordListView.lua",

	"TELEMETRY/3k/FlightPage.lua",

	"TELEMETRY/3k/FlightPageNew.lua",

	"TELEMETRY/3k/FlightStaticPage.lua",

	"TELEMETRY/3k/RoundSetupPage.lua",

	"TELEMETRY/3k/SetupPage.lua",

	"TELEMETRY/3k/SmallFontFlightListPage.lua",

	"TELEMETRY/3k/TaskSelector.lua",

	"TELEMETRY/3k/TaskSelectorO.lua",

	"TELEMETRY/3k/f3kCore.lua",

	"TELEMETRY/3ktel.lua",

	"TELEMETRY/5j/FlightPage.lua",

	"TELEMETRY/5j/LargeFontFlightListPage.lua",

	"TELEMETRY/5j/SetupPage.lua",

	"TELEMETRY/5j/SmallFontFlightListPage.lua",

	"TELEMETRY/5jtel.lua",

	"TELEMETRY/adjust.lua",

	"TELEMETRY/adjust/BackupOutput.lua",

	"TELEMETRY/adjust/GlobalVar.lua",

	"TELEMETRY/adjust/LD/LD.lua",

	"TELEMETRY/adjust/LD/LDCfgPage.lua",

	"TELEMETRY/adjust/LD/LDRecordListView.lua",

	"TELEMETRY/adjust/LD/RecordListView.lua",

	"TELEMETRY/adjust/Launch/LRecordListView.lua",

	"TELEMETRY/adjust/Launch/Launch.lua",

	"TELEMETRY/adjust/Launch/LaunchCfgPage.lua",

	"TELEMETRY/adjust/Launch/RecordListView.lua",

	"TELEMETRY/adjust/ManagerOutput.lua",

	"TELEMETRY/adjust/OutputCurve.lua",

	"TELEMETRY/adjust/OutputCurveManager.lua",

	"TELEMETRY/adjust/Output_old.lua",

	"TELEMETRY/adjust/ReplaceMix.lua",

	"TELEMETRY/adjust/SaveAndRestoreParam.lua",

	"TELEMETRY/adjust/SelectChannel.lua",

	"TELEMETRY/adjust/SinkRate/RecordListView.lua",

	"TELEMETRY/adjust/SinkRate/SRRecordListView.lua",

	"TELEMETRY/adjust/SinkRate/SinkRate.lua",

	"TELEMETRY/adjust/SinkRate/SinkRateCfgPage.lua",

	"TELEMETRY/adjust/output.lua",

	"LAOZHU/uilib/Button.lua",

	"LAOZHU/uilib/ButtonO.lua",

	"LAOZHU/uilib/CheckBox.lua",

	"LAOZHU/uilib/CheckBoxO.lua",

	"LAOZHU/uilib/CurveSelector.lua",

	"LAOZHU/uilib/CurveSelectorO.lua",

	"LAOZHU/uilib/Fields.lua",

	"LAOZHU/uilib/InputSelector.lua",

	"LAOZHU/uilib/InputSelectorO.lua",

	"LAOZHU/uilib/InputView.lua",

	"LAOZHU/uilib/InputViewO.lua",

	"LAOZHU/uilib/LoadModule.lua",

	"LAOZHU/uilib/ModeSelector.lua",

	"LAOZHU/uilib/ModeSelectorO.lua",

	"LAOZHU/uilib/NumEdit.lua",

	"LAOZHU/uilib/NumEditO.lua",

	"LAOZHU/uilib/OutputSelector.lua",

	"LAOZHU/uilib/OutputSelectorO.lua",

	"LAOZHU/uilib/Selector.lua",

	"LAOZHU/uilib/SelectorO.lua",

	"LAOZHU/uilib/TextEdit.lua",

	"LAOZHU/uilib/TextEditO.lua",

	"LAOZHU/uilib/TimeEdit.lua",

	"LAOZHU/uilib/TimeEditO.lua",

	"LAOZHU/uilib/UiParams.lua",

	"LAOZHU/uilib/ViewMatrix.lua",

	"LAOZHU/uilib/ViewMatrixO.lua",

	"LAOZHU/uilib/comp.lua",

	"LAOZHU/uilib/keyMap.lua",

	"TELEMETRY/key.lua",

	"TELEMETRY/ut.lua",

	"TELEMETRY/utO.lua",

	"emutest/luaForTestLoadModule.lua",

	"emutest/testCfg.lua",

	"emutest/testCfgO.lua",

	"emutest/testDataFileDecode.lua",

	"emutest/testLoadModule.lua",

	"emutest/testManagerOutput.lua",

	"emutest/testOutputCurveManager.lua",

	"emutest/testSinkRateRecord.lua",

	"test/TestF3kCompetitionWF.lua",

	"test/TestF3kFlightRecord.lua",

	"test/TestF3kRound.lua",

	"test/TestF3kState.lua",

	"test/TestF5jState.lua",

	"test/TestLaozhuUtils.lua",

	"test/TestQueue.lua",

	"test/TestReadVar.lua",

	"test/TestSensor.lua",

	"test/TestSinkRateState.lua",

	"test/TestSwitchTrigeDetector.lua",

	"test/TestTimer.lua",

	"test/test.lua",

	"test/testF3kTask/TestAULD.lua",

	"test/testF3kTask/TestCommonTask.lua",

	"test/utils4Test.lua",

}
return files
