local viewMatrix = nil
local this = nil
local planeTypeSelector = nil
local tailTypeSelector = nil
local flapCountSelector = nil
local channelSetButton = nil
local saveButton = nil
local channelSetPage = nil
local createModalCfg = nil
local channelList = {}        -- 通道名称列表
local channelNumList = {}     -- 通道号配置列表

local function loadModule()
    LZ_runModule("TELEMETRY/common/InputViewO.lua")
    LZ_runModule("TELEMETRY/common/SelectorO.lua")
    LZ_runModule("TELEMETRY/common/ButtonO.lua")
    LZ_runModule("TELEMETRY/common/ViewMatrixO.lua")
    LZ_runModule("LAOZHU/CfgO.lua")
end

local function unloadModule()
    Selector = nil
    Button = nil
    InputView = nil
    ViewMatrix = nil
    CFGC = nil
end

-- 根据飞机配置获取所有需要设置的通道名称（供其他模块复用）
local function buildChannelList(pType, tType, fCount)
    local names = {}

    -- 尾翼
    if tType == 0 then
        -- V尾
        names[#names+1] = "LVTail"
        names[#names+1] = "RVTail"
    else
        -- 十字尾
        names[#names+1] = "Ele"
        names[#names+1] = "Rud"
    end

    -- 副翼（始终存在）
    names[#names+1] = "LAil"
    names[#names+1] = "RAil"

    -- 襟翼
    if fCount == 1 then
        names[#names+1] = "Flap"
    elseif fCount == 2 then
        names[#names+1] = "LFlap"
        names[#names+1] = "RFlap"
    elseif fCount == 3 then
        names[#names+1] = "LFlap"
        names[#names+1] = "MFlap"
        names[#names+1] = "RFlap"
    end

    -- 油门（仅F5J）
    if pType == 1 then
        names[#names+1] = "Thr"
    end

    return names
end

-- 更新 channelList 和 channelNumList
local function updateChannelLists()
    -- 根据当前配置生成通道列表
    channelList = buildChannelList(
        planeTypeSelector.selectedIndex - 1,
        tailTypeSelector.selectedIndex - 1,
        flapCountSelector.selectedIndex - 1
    )

    -- 从配置文件读取通道号配置
    channelNumList = {}
    for i = 1, #channelList do
        local channelName = channelList[i]
        local channelNum = createModalCfg:getNumberField(channelName, -1)
        channelNumList[i] = channelNum
    end
end

local function loadChannelSetPage()
    if channelSetPage ~= nil then
        return
    end
    -- 更新通道列表
    updateChannelLists()

    channelSetPage = LZ_runModule("TELEMETRY/adjust/CreateModal/ChannelSetPage.lua")
    -- 传递通道列表和通道号配置给 ChannelSetPage
    channelSetPage.init(channelList, channelNumList, createModalCfg)
end

local function unloadChannelSetPage()
    if channelSetPage == nil then
        return
    end
    LZ_clearTable(channelSetPage)
    channelSetPage = nil
    collectgarbage()
end

local function onChannelSetButtonClick(button)
    loadChannelSetPage()
end

local function saveCfgToFile()
    -- 保存为 0-based 索引
    createModalCfg.kvs["plane_type"] = planeTypeSelector.selectedIndex - 1
    createModalCfg.kvs["tail_type"] = tailTypeSelector.selectedIndex - 1
    createModalCfg.kvs["flap_count"] = flapCountSelector.selectedIndex - 1
    createModalCfg:writeToFile("createmodal.cfg")
end

-- 设置输出通道
local function setupOutputChannels()
    -- 更新通道列表
    updateChannelLists()

    for i = 1, #channelList do
        local channelName = channelList[i]
        local channelNum = channelNumList[i]

        -- 仅处理用户已配置的通道（>= 1）
        if channelNum >= 1 and channelNum <= 32 then
            -- 配置文件中是 1-based，API 使用 0-based
            local outputIndex = channelNum - 1
            local output = model.getOutput(outputIndex)

            -- 设置通道名称
            output.name = channelName

            -- 应用配置到遥控器
            model.setOutput(outputIndex, output)
        end
    end
end

local function onSaveButtonClick(button)
    saveCfgToFile()
    -- 设置输出通道
    setupOutputChannels()
    -- TODO: 创建混控的逻辑
    playTone(2000, 200, 0)
end

local function doKey(event)
    local ret = viewMatrix:doKey(event)
    if (not ret) and event == EVT_EXIT_BREAK then
        this.pageState = 1
        unloadModule()
    end
    return ret
end

local function run(event, curTime)
    if channelSetPage then
        if channelSetPage.pageState == 1 then
            unloadChannelSetPage()
            return true
        end
        channelSetPage.run(event, curTime)
        return true
    end

    local invers = false
    if getRtcTime() % 2 == 1 then
        invers = true
    end

    -- 绘制界面
    lcd.drawText(2, 0, "Plane:", SMLSIZE + LEFT)
    planeTypeSelector:draw(50, 0, invers, SMLSIZE + LEFT)

    lcd.drawText(2, 10, "Tail:", SMLSIZE + LEFT)
    tailTypeSelector:draw(50, 10, invers, SMLSIZE + LEFT)

    lcd.drawText(2, 20, "Flap:", SMLSIZE + LEFT)
    flapCountSelector:draw(50, 20, invers, SMLSIZE + LEFT)

    lcd.drawText(2, 30, "Ch Setup:", SMLSIZE + LEFT)
    channelSetButton:draw(50, 30, invers, SMLSIZE + LEFT)

    lcd.drawText(2, 40, "Save:", SMLSIZE + LEFT)
    saveButton:draw(50, 40, invers, SMLSIZE + LEFT)

    return doKey(event)
end

local function bg()
end

local function init()
    loadModule()

    viewMatrix = ViewMatrix:new()

    -- 飞机类型选择器
    planeTypeSelector = Selector:new()
    planeTypeSelector:setTexts({"F3K", "F5J"})
    planeTypeSelector:setOnChange(function(selector)
        updateChannelLists()
    end)

    -- 尾类型选择器
    tailTypeSelector = Selector:new()
    tailTypeSelector:setTexts({"V-Tail", "Normal"})
    tailTypeSelector:setOnChange(function(selector)
        updateChannelLists()
    end)

    -- 襟翼数量选择器
    flapCountSelector = Selector:new()
    flapCountSelector:setTexts({"None", "1Flap", "2Flap", "3Flap"})
    flapCountSelector:setOnChange(function(selector)
        updateChannelLists()
    end)

    -- 通道设置按钮
    channelSetButton = Button:new()
    channelSetButton.text = "Setup"
    channelSetButton:setOnClick(onChannelSetButtonClick)

    -- 保存按钮
    saveButton = Button:new()
    saveButton.text = "Save"
    saveButton:setOnClick(onSaveButtonClick)

    -- 配置文件
    createModalCfg = CFGC:new()
    createModalCfg:readFromFile("createmodal.cfg")

    -- 从配置文件读取上次的选择（配置文件中是 0-based，需要转换为 1-based）
    local savedPlaneType = createModalCfg:getNumberField("plane_type", 0)
    local savedTailType = createModalCfg:getNumberField("tail_type", 0)
    local savedFlapCount = createModalCfg:getNumberField("flap_count", 0)

    if savedPlaneType >= 0 and savedPlaneType <= 1 then
        planeTypeSelector.selectedIndex = savedPlaneType + 1
    end
    if savedTailType >= 0 and savedTailType <= 1 then
        tailTypeSelector.selectedIndex = savedTailType + 1
    end
    if savedFlapCount >= 0 and savedFlapCount <= 3 then
        flapCountSelector.selectedIndex = savedFlapCount + 1
    end

    -- 设置 ViewMatrix
    viewMatrix:addRow()
    local row = viewMatrix.matrix[1]
    row[1] = planeTypeSelector
    row[2] = tailTypeSelector
    row[3] = flapCountSelector
    row[4] = channelSetButton
    row[5] = saveButton

    viewMatrix.selectedRow = 1
    viewMatrix.selectedCol = 1
    viewMatrix:updateCurIVFocus()

    -- 初始化通道列表
    updateChannelLists()
end

init()

this = {run=run, bg=bg, pageState=0}

return this
