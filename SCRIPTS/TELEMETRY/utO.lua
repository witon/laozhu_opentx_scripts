gSDCardDir = "/"
gAssertFlag = "ASSERT FLAG!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
local textEdit = nil
local button = nil
local checkBox = nil
local inputSelector = nil
local numEdit = nil
local outputSelector = nil
local curveSelector = nil
local modeSelector = nil
local taskSelector = nil
local timeEdit = nil


local viewMatrix = nil

-- 调试：见 LAOZHU/DBGTools/dbg.lua；DEBUG_LOG 关则 DBG_dbg 不输出；SHOW_LOG_SCREEN 开且 DEBUG_LOG 开时写入日志缓冲（遥测侧 DBGTelemetryLog 尚未绘制覆盖层，宜保持 false）。
local DBG_OPTS = {
	printTag = "[utO]",
	DEBUG_LOG = true,
	SHOW_LOG_SCREEN = false,
	LOG_MAX = 20,
}

LZ_runModule(gSDCardDir .. "SCRIPTS/TELEMETRY/common/keyMap.lua")
local keyMap = KMgetKeyMap();
KMunload();

local testFiles = {
    "/emutest/testCfg.lua",
    "/emutest/testCfgO.lua",
 
    "/emutest/testLoadModule.lua",
    "/emutest/testManagerOutput.lua",
    "/emutest/testDataFileDecode.lua",
    "/emutest/testSinkRateRecord.lua"
 
    --"/SCRIPTS/emutest/testOutputCurveManager.lua",
}


local curCaseIndex = 1
local curFileIndex = 1
local curCases = nil

local function testLoadAndUnload()
    LZ_runModule(gSDCardDir .. "SCRIPTS/TELEMETRY/common/InputViewO.lua")
    LZ_runModule(gSDCardDir .. "SCRIPTS/TELEMETRY/common/TextEditO.lua")
    LZ_runModule(gSDCardDir .. "SCRIPTS/TELEMETRY/common/ButtonO.lua")
    LZ_runModule(gSDCardDir .. "SCRIPTS/TELEMETRY/common/CheckBoxO.lua")
	LZ_runModule(gSDCardDir .. "SCRIPTS/TELEMETRY/common/SelectorO.lua")
	LZ_runModule(gSDCardDir .. "SCRIPTS/TELEMETRY/common/InputSelectorO.lua")
	LZ_runModule(gSDCardDir .. "SCRIPTS/TELEMETRY/common/Fields.lua")
	initFieldsInfo()
    FieldsUnload()
    LZ_runModule(gSDCardDir .. "SCRIPTS/TELEMETRY/common/NumEditO.lua")
    LZ_runModule(gSDCardDir .. "SCRIPTS/TELEMETRY/common/OutputSelectorO.lua")
	LZ_runModule(gSDCardDir .. "SCRIPTS/TELEMETRY/common/CurveSelector.lua")
    CSunload()
	LZ_runModule(gSDCardDir .. "SCRIPTS/TELEMETRY/common/ModeSelectorO.lua")
	LZ_runModule(gSDCardDir .. "SCRIPTS/TELEMETRY/common/ViewMatrixO.lua")
	LZ_runModule(gSDCardDir .. "SCRIPTS/TELEMETRY/common/TimeEditO.lua")
	LZ_runModule(gSDCardDir .. "SCRIPTS/TELEMETRY/3k/TaskSelectorO.lua")
end

local function initUI()
    testLoadAndUnload()
    LZ_runModule(gSDCardDir .. "SCRIPTS/TELEMETRY/common/TextEditO.lua")
    LZ_runModule(gSDCardDir .. "SCRIPTS/TELEMETRY/common/InputViewO.lua")
    LZ_runModule(gSDCardDir .. "SCRIPTS/TELEMETRY/common/ButtonO.lua")
    LZ_runModule(gSDCardDir .. "SCRIPTS/TELEMETRY/common/CheckBoxO.lua")
	LZ_runModule(gSDCardDir .. "SCRIPTS/TELEMETRY/common/SelectorO.lua")
	LZ_runModule(gSDCardDir .. "SCRIPTS/TELEMETRY/common/InputSelector.lua")
	LZ_runModule(gSDCardDir .. "SCRIPTS/TELEMETRY/common/Fields.lua")
	initFieldsInfo()
    LZ_runModule(gSDCardDir .. "SCRIPTS/TELEMETRY/common/NumEditO.lua")
    LZ_runModule(gSDCardDir .. "SCRIPTS/TELEMETRY/common/OutputSelectorO.lua")
	LZ_runModule(gSDCardDir .. "SCRIPTS/TELEMETRY/common/CurveSelectorO.lua")
	LZ_runModule(gSDCardDir .. "SCRIPTS/TELEMETRY/common/ModeSelectorO.lua")
	LZ_runModule(gSDCardDir .. "SCRIPTS/TELEMETRY/common/ViewMatrixO.lua")
	LZ_runModule(gSDCardDir .. "SCRIPTS/TELEMETRY/3k/TaskSelectorO.lua")
	LZ_runModule(gSDCardDir .. "SCRIPTS/TELEMETRY/common/TimeEditO.lua")
 
    viewMatrix = ViewMatrix:new()

    inputSelector = InputSelector:new()
    inputSelector:setFieldType(FIELDS_INPUT)
    checkBox = CheckBox:new()
    textEdit = TextEdit:new()
    textEdit.str = "abcd"

    button = Button:new()
    button.text = "a bt"

    numEdit = NumEdit:new()
    outputSelector = OutputSelector:new()
    curveSelector = CurveSelector:new()
    modeSelector = ModeSelector:new()
    taskSelector = TaskSelector:new()

    timeEdit = TimeEdit:new()
    timeEdit:setRange(0, 600)
    timeEdit.step = 15



    viewMatrix.matrix = {}
    viewMatrix.matrix[1] = {}
    viewMatrix.matrix[1][1] = checkBox
    viewMatrix.matrix[1][2] = textEdit
    viewMatrix.matrix[2] = {}
    viewMatrix.matrix[2][1] = button
    viewMatrix.matrix[2][2] = inputSelector
    viewMatrix.matrix[3] = {}
    viewMatrix.matrix[3][1] = numEdit
    viewMatrix.matrix[3][2] = outputSelector
    viewMatrix.matrix[4] = {}
    viewMatrix.matrix[4][1] = modeSelector
    viewMatrix.matrix[4][2] = curveSelector
    viewMatrix.matrix[5] = {}
    viewMatrix.matrix[5][1] = taskSelector
    viewMatrix.matrix[6] = {}
    viewMatrix.matrix[6][1] = timeEdit
 
--    IVsetFocusState(viewMatrix.matrix[viewMatrix.selectedRow][viewMatrix.selectedCol], 1)
    viewMatrix:updateCurIVFocus()
 
end

local function init()
    local c2 = collectgarbage("count")
    local fun, err = loadScript(gSDCardDir .. "SCRIPTS/TELEMETRY/common/LoadModule.lua", "bt")
    fun()
    LZ_runModule(gSDCardDir .. "LAOZHU/DBGTools/dbg.lua")
    DBG_init(DBG_OPTS)
    DBG_dbg("begin load")
    curCases = LZ_runModule(gSDCardDir .. "SCRIPTS" .. testFiles[curFileIndex])
    DBG_dbg("loaded")
    DBG_dbg("emutest", "file 1/" .. tostring(#testFiles), testFiles[1])
    curCaseIndex = 1
    LZ_runModule(gSDCardDir .. "LAOZHU/EmuTestUtils.lua")
    LZ_runModule(gSDCardDir .. "LAOZHU/OTUtils.lua")

end

local function doOneCase()
    if curCaseIndex > #curCases then
        curFileIndex = curFileIndex + 1
        if curFileIndex > #testFiles then
            return false
        end
        curCaseIndex = 1
        local testFile = testFiles[curFileIndex]
        curCases = LZ_runModule(gSDCardDir .. "SCRIPTS" .. testFile)
        DBG_dbg("emutest", "file " .. tostring(curFileIndex) .. "/" .. tostring(#testFiles), testFile)
    end
    curCases[curCaseIndex]()
    curCaseIndex = curCaseIndex + 1
    return true

end

local function run(event)
    if curFileIndex <= #testFiles then
        doOneCase()
        if curFileIndex > #testFiles then
            DBG_dbg("emutest OK")
        end
        return
    end

    local invers = false
    if getRtcTime() % 2 == 1 then
        invers = true
    end

    if viewMatrix == nil then
        initUI()
    end
 
    lcd.clear()


	local rawEv = event or 0
	if rawEv ~= 0 then
		local m = keyMap[rawEv]
		DBG_dbg("KEY", "raw=" .. tostring(rawEv), "mapped=" .. tostring(m or rawEv), "hasMap=" .. tostring(m ~= nil))
	end
	e = keyMap[event];
	if e ~= nil then
		event = e;
	end



    viewMatrix:doKey(event)
    lcd.drawText(1, 1, "CheckBox:", SMLSIZE + LEFT)
    checkBox:draw(54, 1, invers, SMLSIZE + RIGHT)
    lcd.drawText(60, 1, "TextEdit:", SMLSIZE + LEFT)
    textEdit:draw(128, 1, invers, SMLSIZE + RIGHT)


    lcd.drawText(1, 10, "Button:", SMLSIZE + LEFT)
    button:draw(54, 10, invers, SMLSIZE + RIGHT)

    lcd.drawText(60, 10, "ipselect:", SMLSIZE + LEFT)
    inputSelector:draw(128, 10, invers, SMLSIZE + RIGHT)

    lcd.drawText(1, 20, "NumEdit:", SMLSIZE + LEFT)
    numEdit:draw(54, 20, invers, SMLSIZE + RIGHT)

    lcd.drawText(60, 20, "opselect:", SMLSIZE + LEFT)
    outputSelector:draw(128, 20, invers, SMLSIZE + RIGHT)
--
    lcd.drawText(60, 30, "csselect:", SMLSIZE + LEFT)
    curveSelector:draw(128, 30, invers, SMLSIZE + RIGHT)
--
    lcd.drawText(0, 30, "mdselect:", SMLSIZE + LEFT)
    modeSelector:draw(58, 30, invers, SMLSIZE + RIGHT)
--
    lcd.drawText(0, 40, "tsselect:", SMLSIZE + LEFT)
    taskSelector:draw(84, 40, invers, SMLSIZE + RIGHT)
--
    lcd.drawText(0, 50, "timeedit:", SMLSIZE + LEFT)
    timeEdit:draw(84, 50, invers, SMLSIZE + RIGHT)
end

return {run=run, init=init }