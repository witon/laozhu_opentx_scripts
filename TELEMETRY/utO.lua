gScriptDir = "/SCRIPTS/"
gAssertFlag = "ASSERT FLAG!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"

--local function init()
    local c2 = collectgarbage("count")
    local fun, err = loadScript(gScriptDir .. "TELEMETRY/common/LoadModule.lua", "bt")
    fun()
--    print("begin load")
--    curCases = LZ_runModule(testFiles[curFileIndex])
--    print("loaded")
--    curCaseIndex = 1
    LZ_runModule("LAOZHU/EmuTestUtils.lua")
    LZ_runModule("LAOZHU/OTUtils.lua")
    LZ_runModule("LAOZHU/LuaUtils.lua")
    
--end

LZ_runModule("TELEMETRY/common/keyMap.lua")
local keyMap = KMgetKeyMap();
KMunload();



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
local switchPositionSelector = nil
local testFiles = {
--    "/emutest/testCfg.lua",
--    "/emutest/testCfgO.lua",
-- 
--    "/emutest/testLoadModule.lua",
--    "/emutest/testManagerOutput.lua",
--    "/emutest/testDataFileDecode.lua",
--    "/emutest/testSinkRateRecord.lua"
-- 
    --"/SCRIPTS/emutest/testOutputCurveManager.lua",
}


local curCaseIndex = 1
local curFileIndex = 1
local curCases = nil



local viewMatrix = nil
local function testLoadAndUnload()
    LZ_runModule("TELEMETRY/common/InputViewO.lua")
    LZ_runModule("TELEMETRY/common/TextEditO.lua")
    LZ_runModule("TELEMETRY/common/ButtonO.lua")
    LZ_runModule("TELEMETRY/common/CheckBoxO.lua")
	LZ_runModule("TELEMETRY/common/SelectorO.lua")
	LZ_runModule("TELEMETRY/common/InputSelectorO.lua")
	LZ_runModule("TELEMETRY/common/SwitchPositionSelectorO.lua")
	LZ_runModule("TELEMETRY/common/Fields.lua")
	initFieldsInfo()
    FieldsUnload()
    LZ_runModule("TELEMETRY/common/NumEditO.lua")
    LZ_runModule("TELEMETRY/common/OutputSelectorO.lua")
	LZ_runModule("TELEMETRY/common/CurveSelector.lua")
    CSunload()
	LZ_runModule("TELEMETRY/common/ModeSelectorO.lua")
	LZ_runModule("TELEMETRY/common/ViewMatrixO.lua")
	LZ_runModule("TELEMETRY/common/TimeEditO.lua")
	LZ_runModule("TELEMETRY/3k/TaskSelectorO.lua")
end

local function initUI()
    testLoadAndUnload()
    LZ_runModule("TELEMETRY/common/TextEditO.lua")
    LZ_runModule("TELEMETRY/common/InputViewO.lua")
    LZ_runModule("TELEMETRY/common/ButtonO.lua")
    LZ_runModule("TELEMETRY/common/CheckBoxO.lua")
	LZ_runModule("TELEMETRY/common/SelectorO.lua")
	LZ_runModule("TELEMETRY/common/InputSelector.lua")
	LZ_runModule("TELEMETRY/common/SwitchPositionSelectorO.lua")
	LZ_runModule("TELEMETRY/common/Fields.lua")
	initFieldsInfo()
    LZ_runModule("TELEMETRY/common/NumEditO.lua")
    LZ_runModule("TELEMETRY/common/OutputSelectorO.lua")
	LZ_runModule("TELEMETRY/common/CurveSelectorO.lua")
	LZ_runModule("TELEMETRY/common/ModeSelectorO.lua")
	LZ_runModule("TELEMETRY/common/ViewMatrixO.lua")
	LZ_runModule("TELEMETRY/3k/TaskSelectorO.lua")
	LZ_runModule("TELEMETRY/common/TimeEditO.lua")
 
    viewMatrix = ViewMatrix:new()
    viewMatrix.visibleRows = 6  -- EdgeTX屏幕64像素高，每行10像素，可显示6行

    inputSelector = InputSelector:new()
    inputSelector:setFieldType(FIELDS_INPUT)
    switchPositionSelector = SwitchPositionSelector:new()
    switchPositionSelector:setFieldType(FIELDS_SWITCH_POSITION)
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
    viewMatrix.matrix[5][1] = taskSelector  -- 独占一行
    viewMatrix.matrix[6] = {}
    viewMatrix.matrix[6][1] = switchPositionSelector  -- 独占一行
    viewMatrix.matrix[7] = {}
    viewMatrix.matrix[7][1] = timeEdit  -- 独占一行
 
--    IVsetFocusState(viewMatrix.matrix[viewMatrix.selectedRow][viewMatrix.selectedCol], 1)
    viewMatrix:updateCurIVFocus()
 
end

local function doOneCase()
    if curCaseIndex > #curCases then
        curFileIndex = curFileIndex + 1
        if curFileIndex > #testFiles then
            return false
        end
        curCaseIndex = 1
        local testFile = testFiles[curFileIndex]
        curCases = LZ_runModule(testFile)
    end
    curCases[curCaseIndex]()
    curCaseIndex = curCaseIndex + 1
    return true

end

-- 定义所有行的绘制配置
local rowDrawConfigs = {
    -- 第1行: CheckBox 和 TextEdit
    {
        draw = function(y, invers)
            lcd.drawText(1, y, "CheckBox:", SMLSIZE + LEFT)
            checkBox:draw(54, y, invers, SMLSIZE + RIGHT)
            lcd.drawText(60, y, "TextEdit:", SMLSIZE + LEFT)
            textEdit:draw(128, y, invers, SMLSIZE + RIGHT)
        end
    },
    -- 第2行: Button 和 InputSelector
    {
        draw = function(y, invers)
            lcd.drawText(1, y, "Button:", SMLSIZE + LEFT)
            button:draw(54, y, invers, SMLSIZE + RIGHT)
            lcd.drawText(60, y, "ipselect:", SMLSIZE + LEFT)
            inputSelector:draw(128, y, invers, SMLSIZE + RIGHT)
        end
    },
    -- 第3行: NumEdit 和 OutputSelector
    {
        draw = function(y, invers)
            lcd.drawText(1, y, "NumEdit:", SMLSIZE + LEFT)
            numEdit:draw(54, y, invers, SMLSIZE + RIGHT)
            lcd.drawText(60, y, "opselect:", SMLSIZE + LEFT)
            outputSelector:draw(128, y, invers, SMLSIZE + RIGHT)
        end
    },
    -- 第4行: ModeSelector 和 CurveSelector
    {
        draw = function(y, invers)
            lcd.drawText(0, y, "mdselect:", SMLSIZE + LEFT)
            modeSelector:draw(58, y, invers, SMLSIZE + RIGHT)
            lcd.drawText(60, y, "csselect:", SMLSIZE + LEFT)
            curveSelector:draw(128, y, invers, SMLSIZE + RIGHT)
        end
    },
    -- 第5行: TaskSelector (独占一行)
    {
        draw = function(y, invers)
            lcd.drawText(0, y, "tsselect:", SMLSIZE + LEFT)
            taskSelector:draw(128, y, invers, SMLSIZE + RIGHT)
        end
    },
    -- 第6行: SwitchPositionSelector (独占一行)
    {
        draw = function(y, invers)
            lcd.drawText(0, y, "swselect:", SMLSIZE + LEFT)
            switchPositionSelector:draw(128, y, invers, SMLSIZE + RIGHT)
        end
    },
    -- 第7行: TimeEdit (独占一行)
    {
        draw = function(y, invers)
            lcd.drawText(0, y, "timeedit:", SMLSIZE + LEFT)
            timeEdit:draw(128, y, invers, SMLSIZE + RIGHT)
        end
    }
}

local function run(event)
--    if curFileIndex <= #testFiles then
--        doOneCase()
--        return
--    end

    local invers = false
    if getRtcTime() % 2 == 1 then
        invers = true
    end

    if viewMatrix == nil then
        initUI()
    end

    lcd.clear()

	if event ~= 0 then
		print("before:", event)
	end
	e = keyMap[event];
	if e ~= nil then
		event = e;
	end
	if event ~= 0 then
		print("after:", event)
	end

    viewMatrix:doKey(event)

    -- 计算可见行范围
    local startRow = viewMatrix.scrollLine + 1
    local endRow = math.min(viewMatrix.scrollLine + viewMatrix.visibleRows, #rowDrawConfigs)

    -- 绘制可见行
    local y = 1
    for i = startRow, endRow do
        rowDrawConfigs[i].draw(y, invers)
        y = y + 10  -- 每行间隔10像素
    end


end



return {run=run}