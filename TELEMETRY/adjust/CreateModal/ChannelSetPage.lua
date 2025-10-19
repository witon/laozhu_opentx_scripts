local viewMatrix = nil
local this = nil
local scrollLine = 0
local outputSelectors = {}
local surfaceNames = {}
local surfaceConfigKeys = {}
local planeType = 0
local tailType = 0
local flapCount = 0
local createModalCfg = nil

local function loadModule()
    LZ_runModule("TELEMETRY/common/InputViewO.lua")
    LZ_runModule("TELEMETRY/common/NumEditO.lua")
    LZ_runModule("TELEMETRY/common/ViewMatrixO.lua")
end

local function unloadModule()
    NumEdit = nil
    InputView = nil
    ViewMatrix = nil
end

-- 根据配置构建舵面列表
local function buildSurfaceList()
    surfaceNames = {}
    surfaceConfigKeys = {}

    -- 尾翼
    if tailType == 0 then
        -- V尾
        surfaceNames[#surfaceNames+1] = "LVTail"
        surfaceConfigKeys[#surfaceConfigKeys+1] = "ch_lvtail"
        surfaceNames[#surfaceNames+1] = "RVTail"
        surfaceConfigKeys[#surfaceConfigKeys+1] = "ch_rvtail"
    else
        -- 十字尾
        surfaceNames[#surfaceNames+1] = "Ele"
        surfaceConfigKeys[#surfaceConfigKeys+1] = "ch_ele"
        surfaceNames[#surfaceNames+1] = "Rud"
        surfaceConfigKeys[#surfaceConfigKeys+1] = "ch_rud"
    end

    -- 副翼（始终存在）
    surfaceNames[#surfaceNames+1] = "LAil"
    surfaceConfigKeys[#surfaceConfigKeys+1] = "ch_lail"
    surfaceNames[#surfaceNames+1] = "RAil"
    surfaceConfigKeys[#surfaceConfigKeys+1] = "ch_rail"

    -- 襟翼
    if flapCount == 1 then
        surfaceNames[#surfaceNames+1] = "Flap"
        surfaceConfigKeys[#surfaceConfigKeys+1] = "ch_flap"
    elseif flapCount == 2 then
        surfaceNames[#surfaceNames+1] = "LFlap"
        surfaceConfigKeys[#surfaceConfigKeys+1] = "ch_lflap"
        surfaceNames[#surfaceNames+1] = "RFlap"
        surfaceConfigKeys[#surfaceConfigKeys+1] = "ch_rflap"
    elseif flapCount == 3 then
        surfaceNames[#surfaceNames+1] = "LFlap"
        surfaceConfigKeys[#surfaceConfigKeys+1] = "ch_lflap"
        surfaceNames[#surfaceNames+1] = "MFlap"
        surfaceConfigKeys[#surfaceConfigKeys+1] = "ch_mflap"
        surfaceNames[#surfaceNames+1] = "RFlap"
        surfaceConfigKeys[#surfaceConfigKeys+1] = "ch_rflap"
    end

    -- 油门（仅F5J）
    if planeType == 1 then
        surfaceNames[#surfaceNames+1] = "Thr"
        surfaceConfigKeys[#surfaceConfigKeys+1] = "ch_thr"
    end
end

-- 创建 NumEdit 用于输入通道号
local function createChannelNumEdits()
    outputSelectors = {}
    for i = 1, #surfaceNames do
        local numEdit = NumEdit:new()
        numEdit:setRange(1, 32)  -- 通道号范围 1-32
        local savedChannel = createModalCfg:getNumberField(surfaceConfigKeys[i], -1)
        if savedChannel >= 1 and savedChannel <= 32 then
            numEdit.num = savedChannel
        else
            numEdit.num = 1
        end

        -- 设置 onChange 回调
        numEdit:setOnChange(function(ne)
            createModalCfg.kvs[surfaceConfigKeys[i]] = ne.num
        end)

        outputSelectors[i] = numEdit
    end
end

-- 保存选择到配置
local function saveSelectionsToConfig()
    for i = 1, #surfaceNames do
        createModalCfg.kvs[surfaceConfigKeys[i]] = outputSelectors[i].num
    end
    createModalCfg:writeToFile("createmodal.cfg")
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
        saveSelectionsToConfig()
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
    lcd.drawText(2, 0, "Surface", SMLSIZE + LEFT + INVERS)
    lcd.drawText(126, 0, "Output", SMLSIZE + RIGHT + INVERS)

    -- 显示舵面列表
    for i = scrollLine + 1, math.min(scrollLine + 6, #surfaceNames) do
        local y = (i - scrollLine) * 10
        lcd.drawText(2, y, surfaceNames[i], SMLSIZE + LEFT)
        outputSelectors[i]:draw(126, y, invers, SMLSIZE + RIGHT)
    end

    return doKey(event)
end

local function bg()
end

local function init(pType, tType, fCount, cfg)
    planeType = pType
    tailType = tType
    flapCount = fCount
    createModalCfg = cfg

    loadModule()

    buildSurfaceList()
    createChannelNumEdits()

    viewMatrix = ViewMatrix:new()

    -- 将所有 NumEdit 添加到 ViewMatrix
    for i = 1, #outputSelectors do
        viewMatrix:addRow()
        viewMatrix.matrix[i][1] = outputSelectors[i]
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
