local viewMatrix = nil
local this = nil
local scrollLine = 0
local channelNumEdits = {}
local channelNames = {}
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

-- 根据配置构建通道列表
local function buildChannelList()
    channelNames = {}

    -- 尾翼
    if tailType == 0 then
        -- V尾
        channelNames[#channelNames+1] = "LVTail"
        channelNames[#channelNames+1] = "RVTail"
    else
        -- 十字尾
        channelNames[#channelNames+1] = "Ele"
        channelNames[#channelNames+1] = "Rud"
    end

    -- 副翼（始终存在）
    channelNames[#channelNames+1] = "LAil"
    channelNames[#channelNames+1] = "RAil"

    -- 襟翼
    if flapCount == 1 then
        channelNames[#channelNames+1] = "Flap"
    elseif flapCount == 2 then
        channelNames[#channelNames+1] = "LFlap"
        channelNames[#channelNames+1] = "RFlap"
    elseif flapCount == 3 then
        channelNames[#channelNames+1] = "LFlap"
        channelNames[#channelNames+1] = "MFlap"
        channelNames[#channelNames+1] = "RFlap"
    end

    -- 油门（仅F5J）
    if planeType == 1 then
        channelNames[#channelNames+1] = "Thr"
    end
end

-- 创建 NumEdit 用于输入通道号
local function createChannelNumEdits()
    channelNumEdits = {}
    for i = 1, #channelNames do
        local numEdit = NumEdit:new()
        numEdit:setRange(1, 32)  -- 通道号范围 1-32
        local channelName = channelNames[i]
        local savedChannel = createModalCfg:getNumberField(channelName, -1)
        if savedChannel >= 1 and savedChannel <= 32 then
            numEdit.num = savedChannel
        else
            numEdit.num = 1
        end

        -- 设置 onChange 回调
        numEdit:setOnChange(function(ne)
            createModalCfg.kvs[channelName] = ne.num
        end)

        channelNumEdits[i] = numEdit
    end
end

-- 保存通道配置
local function saveChannelConfig()
    for i = 1, #channelNames do
        createModalCfg.kvs[channelNames[i]] = channelNumEdits[i].num
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
        saveChannelConfig()
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
    lcd.drawText(2, 0, "Channel", SMLSIZE + LEFT + INVERS)
    lcd.drawText(126, 0, "Output", SMLSIZE + RIGHT + INVERS)

    -- 显示通道列表
    for i = scrollLine + 1, math.min(scrollLine + 6, #channelNames) do
        local y = (i - scrollLine) * 10
        lcd.drawText(2, y, channelNames[i], SMLSIZE + LEFT)
        channelNumEdits[i]:draw(126, y, invers, SMLSIZE + RIGHT)
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

    buildChannelList()
    createChannelNumEdits()

    viewMatrix = ViewMatrix:new()

    -- 将所有 NumEdit 添加到 ViewMatrix
    for i = 1, #channelNumEdits do
        viewMatrix:addRow()
        viewMatrix.matrix[i][1] = channelNumEdits[i]
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
