local viewMatrix = nil
local this = nil
local planeTypeSelector = nil
local tailTypeSelector = nil
local flapCountSelector = nil
local channelSetButton = nil
local saveButton = nil
local channelSetPage = nil
local createModalCfg = nil
local channelList = {}              -- 可用的舵面（Channel）列表
local pinToChannelMap = {}          -- 针脚（Pin）到舵面（Channel）的映射 (索引1-8对应Pin1-8，值为Channel名称或nil)

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

-- 根据飞机配置获取所有可用的舵面（Channel）列表
local function buildChannelList(pType, tType, fCount)
    local channels = {}

    -- 尾翼
    if tType == 0 then
        -- V尾
        channels[#channels+1] = "LVTail"
        channels[#channels+1] = "RVTail"
    else
        -- 十字尾
        channels[#channels+1] = "Ele"
        channels[#channels+1] = "Rud"
    end

    -- 副翼（始终存在）
    channels[#channels+1] = "LAil"
    channels[#channels+1] = "RAil"

    -- 襟翼
    if fCount == 1 then
        channels[#channels+1] = "Flap"
    elseif fCount == 2 then
        channels[#channels+1] = "LFlap"
        channels[#channels+1] = "RFlap"
    elseif fCount == 3 then
        channels[#channels+1] = "LFlap"
        channels[#channels+1] = "MFlap"
        channels[#channels+1] = "RFlap"
    end

    -- 油门（仅F5J）
    if pType == 1 then
        channels[#channels+1] = "Thr"
    end

    return channels
end

-- 更新舵面列表和针脚映射
local function updatePinMapping()
    -- 根据当前配置生成舵面列表
    channelList = buildChannelList(
        planeTypeSelector.selectedIndex - 1,
        tailTypeSelector.selectedIndex - 1,
        flapCountSelector.selectedIndex - 1
    )

    -- 从配置文件读取针脚到舵面的映射
    -- 配置文件格式: Pin1=RAil:s, Pin2=LAil:s, etc.
    pinToChannelMap = {}
    for pinNum = 1, 8 do
        local cfgKey = "Pin" .. pinNum
        local channelName = createModalCfg:getStrField(cfgKey, "")
        if channelName ~= "" then
            pinToChannelMap[pinNum] = channelName
        else
            pinToChannelMap[pinNum] = nil
        end
    end
end

local function loadChannelSetPage()
    if channelSetPage ~= nil then
        return
    end
    -- 更新针脚映射
    updatePinMapping()

    channelSetPage = LZ_runModule("TELEMETRY/adjust/CreateModal/ChannelSetPage.lua")
    -- 传递舵面列表和针脚到舵面的映射给 ChannelSetPage
    channelSetPage.init(channelList, pinToChannelMap)
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

    -- 保存针脚到舵面的映射
    for pinNum = 1, 8 do
        local cfgKey = "Pin" .. pinNum
        local channelName = pinToChannelMap[pinNum]
        if channelName and channelName ~= "" then
            createModalCfg.kvs[cfgKey] = channelName
        else
            createModalCfg.kvs[cfgKey] = ""
        end
    end

    createModalCfg:writeToFile("createmodal.cfg")
end

-- 设置输出通道针脚
local function setupOutputChannels()
    -- 更新针脚映射
    updatePinMapping()

    for pinNum = 1, 8 do
        local channelName = pinToChannelMap[pinNum]

        -- 针脚号是 1-based，API 使用 0-based
        local outputIndex = pinNum - 1
        local output = model.getOutput(outputIndex)

        -- 如果已分配舵面，使用舵面名称；否则使用默认通道号
        if channelName and channelName ~= "" then
            output.name = channelName
        else
            output.name = "CH" .. pinNum
        end

        -- 应用配置到遥控器
        model.setOutput(outputIndex, output)
    end
end

local function onSaveButtonClick(button)
    saveCfgToFile()
    -- 设置输出通道
    setupOutputChannels()

    -- 设置全局变量（初始化为0）
    -- 定义固定的GV索引（0-based，GV1对应index 0）
    local gvIndexes = {0, 1, 2, 3, 4, 6, 8}  -- GV1, GV2, GV3, GV4, GV5, GV7, GV9

    -- 如果有襟翼，添加GV6（index 5）
    local fCount = flapCountSelector.selectedIndex - 1
    if fCount > 0 then
        table.insert(gvIndexes, 5, 5)  -- 插入到第6个位置，对应GV6
    end

    -- 为所有飞行模式初始化这些GV为0
    for i = 1, #gvIndexes do
        local gvIndex = gvIndexes[i]
        for mode = 0, 8 do  -- FM0 到 FM8
            model.setGlobalVariable(gvIndex, mode, 0)
        end
    end

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
        updatePinMapping()
    end)

    -- 尾类型选择器
    tailTypeSelector = Selector:new()
    tailTypeSelector:setTexts({"V-Tail", "Normal"})
    tailTypeSelector:setOnChange(function(selector)
        updatePinMapping()
    end)

    -- 襟翼数量选择器
    flapCountSelector = Selector:new()
    flapCountSelector:setTexts({"None", "1Flap", "2Flap", "3Flap"})
    flapCountSelector:setOnChange(function(selector)
        updatePinMapping()
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

    -- 初始化针脚映射
    updatePinMapping()
end

init()

this = {run=run, bg=bg, pageState=0}

return this
