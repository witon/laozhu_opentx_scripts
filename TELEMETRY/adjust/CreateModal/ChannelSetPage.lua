local viewMatrix = nil
local this = nil
local scrollLine = 0
local channelSelectors = {}      -- 每个针脚的舵面选择器
local channelList = {}           -- 可用舵面（Channel）列表
local pinToChannelMap = {}       -- 针脚（Pin）到舵面（Channel）的映射

local function loadModule()

end

local function unloadModule()

end

-- 创建 Selector 用于选择舵面（Channel）
local function createChannelSelectors()
    channelSelectors = {}

    -- 构建选择器选项列表：包含 "---"（表示未分配）和所有舵面名称
    local selectorTexts = {"---"}
    for i = 1, #channelList do
        selectorTexts[#selectorTexts+1] = channelList[i]
    end

    -- 为针脚 1-8 创建选择器
    for pinNum = 1, 8 do
        local selector = Selector:new()
        selector:setTexts(selectorTexts)

        -- 设置当前选中的舵面
        local currentChannel = pinToChannelMap[pinNum]
        if currentChannel and currentChannel ~= "" then
            -- 在舵面列表中查找对应的索引
            for i = 1, #channelList do
                if channelList[i] == currentChannel then
                    selector.selectedIndex = i + 1  -- +1 因为第一个是 "---"
                    break
                end
            end
        else
            selector.selectedIndex = 1  -- 默认选择 "---"
        end

        -- 设置 onChange 回调，更新映射
        selector:setOnChange(function(sel)
            if sel.selectedIndex == 1 then
                -- 选择了 "---"，清除映射
                pinToChannelMap[pinNum] = nil
            else
                -- 选择了舵面，更新映射
                pinToChannelMap[pinNum] = channelList[sel.selectedIndex - 1]
            end
        end)

        channelSelectors[pinNum] = selector
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
        -- pinToChannelMap 已经通过 onChange 回调实时更新，无需额外保存
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
    lcd.drawText(2, 0, "Pin", SMLSIZE + LEFT + INVERS)
    lcd.drawText(126, 0, "Channel", SMLSIZE + RIGHT + INVERS)

    -- 显示针脚 1-8（每页最多显示 6 行）
    for pinNum = scrollLine + 1, math.min(scrollLine + 6, 8) do
        local y = (pinNum - scrollLine) * 10
        -- 显示针脚号
        lcd.drawText(2, y, "Pin" .. pinNum, SMLSIZE + LEFT)
        -- 显示舵面选择器
        channelSelectors[pinNum]:draw(126, y, invers, SMLSIZE + RIGHT)
    end

    return doKey(event)
end

local function bg()
end

local function init(channels, pinToChMap)
    channelList = channels
    pinToChannelMap = pinToChMap

    loadModule()

    createChannelSelectors()

    viewMatrix = ViewMatrix:new()

    -- 将所有 Selector 添加到 ViewMatrix（8 个针脚）
    for pinNum = 1, 8 do
        viewMatrix:addRow()
        viewMatrix.matrix[pinNum][1] = channelSelectors[pinNum]
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
