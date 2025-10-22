local viewMatrix = nil
local this = nil
local scrollLine = 0
local switchSelectors = {}       -- 每个开关位置的选择器
local switchPositionList = {}    -- 开关位置列表（从模板获取）
local switchPositionMap = {}     -- 开关名称到 switchIndex 的映射

local function loadModule()
    LZ_runModule("TELEMETRY/common/InputViewO.lua")
    LZ_runModule("TELEMETRY/common/SwitchPositionSelectorO.lua")
    LZ_runModule("TELEMETRY/common/ViewMatrixO.lua")
    LZ_runModule("TELEMETRY/common/Fields.lua")
	initFieldsInfo()
end

local function unloadModule()
    SwitchPositionSelector = nil
    InputView = nil
    ViewMatrix = nil
    FieldsUnload()
end

-- 创建 SwitchPositionSelector 用于选择开关位置
local function createSwitchSelectors()
    switchSelectors = {}

    -- 为每个开关位置创建选择器
    for i = 1, #switchPositionList do
        local switchCfg = switchPositionList[i]
        local selector = SwitchPositionSelector:new()
        selector:setFieldType(FIELDS_SWITCH_POSITION)

        -- 设置当前选中的开关位置
        local currentSwitchIndex = switchPositionMap[switchCfg.name]
        if currentSwitchIndex and currentSwitchIndex ~= -1 then
            selector:setSelectedItemById(currentSwitchIndex)
        else
            selector.selectedIndex = 0  -- 未设置
        end

        -- 设置 onChange 回调，更新映射
        selector:setOnChange(function(sel)
            local selectedId = sel:getSelectedItemId()
            switchPositionMap[switchCfg.name] = selectedId
        end)

        switchSelectors[i] = selector
    end
end

local function doKey(event)
    local ret = viewMatrix:doKey(event)

    if event == 36 or event == 68 then
        if viewMatrix.selectedRow - scrollLine < 2 and scrollLine > 0 then
            scrollLine = scrollLine - 1
        end
    elseif event == 35 or event == 67 then
        if viewMatrix.selectedRow - scrollLine > 5 then
            scrollLine = scrollLine + 1
        end
    end

    if (not ret) and event == EVT_EXIT_BREAK then
        -- switchPositionMap 已经通过 onChange 回调实时更新，无需额外保存
        this.pageState = 1
        unloadModule()
    end
    return ret
end

local function run(event, time)
    local invers = false
    if getRtcTime() % 2 == 1 then
        invers = true
    end

    -- 标题
    lcd.drawFilledRectangle(0, 0, 128, 9, FORCE)
    lcd.drawText(2, 0, "Name", SMLSIZE + LEFT + INVERS)
    lcd.drawText(126, 0, "Switch", SMLSIZE + RIGHT + INVERS)

    -- 显示开关位置（每页最多显示 6 行）
    local totalSwitches = #switchPositionList
    for idx = scrollLine + 1, math.min(scrollLine + 6, totalSwitches) do
        local y = (idx - scrollLine) * 10
        local switchCfg = switchPositionList[idx]

        -- 显示开关名称（或标签）
        local displayName = switchCfg.label or switchCfg.name
        lcd.drawText(2, y, displayName, SMLSIZE + LEFT)

        -- 显示开关位置选择器
        switchSelectors[idx]:draw(126, y, invers, SMLSIZE + RIGHT)
    end

    return doKey(event)
end

local function bg()
end

local function init(switchPosList, switchPosMap)
    switchPositionList = switchPosList
    switchPositionMap = switchPosMap

    loadModule()

    createSwitchSelectors()

    viewMatrix = ViewMatrix:new()

    -- 将所有 SwitchPositionSelector 添加到 ViewMatrix
    for i = 1, #switchPositionList do
        viewMatrix:addRow()
        viewMatrix.matrix[i][1] = switchSelectors[i]
    end

    viewMatrix.selectedRow = 1
    viewMatrix.selectedCol = 1
    viewMatrix:updateCurIVFocus()
end

this = {
    init = init,
    run = run,
    bg = bg,
    pageState = 0
}

return this
