local viewMatrix = nil
local this = nil
local channelSetButton = nil
local switchSetButton = nil
local saveButton = nil
local channelSetPage = nil
local switchSetPage = nil
local createModalCfg = nil
local channelList = {}              -- 可用的舵面（Channel）列表
local pinToChannelMap = {}          -- 针脚（Pin）到舵面（Channel）的映射 (索引1-8对应Pin1-8，值为Channel名称或nil)
local switchPositionList = {}       -- 开关位置列表（从模板获取）
local switchPositionMap = {}        -- 开关名称到 switchIndex 的映射

-- 模板相关
local template = nil                -- 当前使用的模板（ThermalGlider）
local optionSelectors = {}          -- 动态生成的选择器数组
local optionConfigs = {}            -- 选项配置数组（从模板的genOptions()返回）

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

-- 从当前选择器获取配置参数（0-based索引）
local function getCurrentConfig()
    local config = {}
    for i = 1, #optionSelectors do
        config[i] = optionSelectors[i].selectedIndex - 1  -- 转换为0-based
    end
    return config
end

-- 从当前选择器获取命名配置参数表
local function getCurrentConfigTable()
    local configTable = {}
    for i = 1, #optionConfigs do
        local key = optionConfigs[i].cfgKey
        configTable[key] = optionSelectors[i].selectedIndex - 1  -- 转换为0-based
    end
    return configTable
end

-- 更新舵面列表和针脚映射
local function updatePinMapping()
    -- 根据当前配置生成舵面列表（使用模板的genChannelList）
    local configTable = getCurrentConfigTable()
    channelList = template.genChannelList(configTable)

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

local function loadSwitchSetPage()
    if switchSetPage ~= nil then
        return
    end

    switchSetPage = LZ_runModule("TELEMETRY/adjust/CreateModal/SwitchSetPage.lua")
    -- 传递开关位置列表和开关位置映射给 SwitchSetPage
    switchSetPage.init(switchPositionList, switchPositionMap)
end

local function unloadSwitchSetPage()
    if switchSetPage == nil then
        return
    end
    LZ_clearTable(switchSetPage)
    switchSetPage = nil
    collectgarbage()
end

local function onChannelSetButtonClick(button)
    loadChannelSetPage()
end

local function onSwitchSetButtonClick(button)
    loadSwitchSetPage()
end

local function saveCfgToFile()
    -- 动态保存所有选项配置（保存为 0-based 索引）
    for i = 1, #optionConfigs do
        local cfgKey = optionConfigs[i].cfgKey
        local value = optionSelectors[i].selectedIndex - 1  -- 转换为 0-based
        createModalCfg.kvs[cfgKey] = value
    end

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

    -- 保存开关位置映射
    for i = 1, #switchPositionList do
        local switchCfg = switchPositionList[i]
        local cfgKey = switchCfg.name
        local switchIndex = switchPositionMap[switchCfg.name]
        if switchIndex and switchIndex ~= -1 then
            createModalCfg.kvs[cfgKey] = switchIndex
        else
            createModalCfg.kvs[cfgKey] = -1
        end
    end

    createModalCfg:writeToFile("createmodal.cfg")
end

-- 设置曲线
local function setupCurves()
    -- 更新针脚映射（确保 channelList 是最新的）
    updatePinMapping()

    -- 使用模板的 getCurves 生成曲线配置
    local configTable = getCurrentConfigTable()
    local curves = template.getCurves(configTable, channelList)

    -- 应用生成的曲线配置到遥控器
    for i = 1, #curves do
        local curveCfg = curves[i]
        local curveIndex = curveCfg.index  -- 模板应返回 0-based 索引

        -- 读取当前曲线配置
        local curve = model.getCurve(curveIndex)

        -- 应用模板生成的配置
        if curveCfg.name then
            curve.name = curveCfg.name
        end
        if curveCfg.type then
            curve.type = curveCfg.type  -- 0=Standard, 1=Custom
        end
        if curveCfg.smooth then
            curve.smooth = curveCfg.smooth
        end
        if curveCfg.points then
            -- 设置曲线点数
            curve.points = #curveCfg.points
            -- 设置曲线点的值
            for j = 1, #curveCfg.points do
                curve.y[j] = curveCfg.points[j]  -- EdgeTX API 使用 0-based 索引
            end
        end


        -- 写入到遥控器
        local ret = model.setCurve(curveIndex, curve)
    end
end

-- 设置输出通道针脚
local function setupOutputChannels()
    -- 更新针脚映射
    updatePinMapping()

    -- 使用模板的 getOutputs 生成输出配置
    local configTable = getCurrentConfigTable()
    local outputs = template.getOutputs(configTable, channelList, pinToChannelMap)

    -- 应用生成的输出配置到遥控器
    for i = 1, #outputs do
        local outputCfg = outputs[i]
        local outputIndex = outputCfg.index  -- 模板应返回 0-based 索引

        -- 读取当前输出配置
        local output = model.getOutput(outputIndex)

        -- 应用模板生成的配置
        if outputCfg.name then
            output.name = outputCfg.name
        end
        if outputCfg.min then
            output.min = outputCfg.min
        end
        if outputCfg.max then
            output.max = outputCfg.max
        end
        if outputCfg.offset then
            output.offset = outputCfg.offset
        end
        if outputCfg.curve then
            output.curve = outputCfg.curve
        end
        if outputCfg.revert then
            output.revert = outputCfg.revert
        end

        -- 写入到遥控器
        model.setOutput(outputIndex, output)
    end
end

-- 设置输入
local function setupInputs()
    -- 使用模板的 getInputs 生成输入配置
    local configTable = getCurrentConfigTable()
    local inputs = template.getInputs(configTable)

    model.deleteInputs()

    -- 应用生成的输入配置到遥控器
    for i = 1, #inputs do
        local inputCfg = inputs[i]
        local inputIndex = inputCfg.index  -- 模板应返回 0-based 索引

        -- 创建输入对象
        local input = {}
        input.name = inputCfg.name
        input.inputName = inputCfg.name
        input.source = inputCfg.source
        input.weight = inputCfg.weight

        -- 插入输入（清除后从 0 开始）
        model.insertInput(inputIndex, 0, input)
    end
end

-- 设置混控器
local function setupMixers()
    -- 更新针脚映射
    updatePinMapping()

    -- 使用模板的 getMixers 生成混控配置
    local configTable = getCurrentConfigTable()
    local mixers = template.getMixers(configTable, channelList, pinToChannelMap)

    -- 清除所有输出通道的现有混控器（可选，取决于需求）
    -- 注意：这里我们选择不清除，而是直接插入新的混控器
    -- 如果需要清除，可以取消下面的注释
    -- for channel = 0, 7 do
    --     local mixesCount = model.getMixesCount(channel)
    --     for i = mixesCount - 1, 0, -1 do
    --         model.deleteMix(channel, i)
    --     end
    -- end

    -- 应用生成的混控配置到遥控器
    for i = 1, #mixers do
        local mixCfg = mixers[i]
        local channel = mixCfg.channel  -- 输出通道索引（0-based）

        -- 创建混控器对象
        local mix = {}
        mix.source = mixCfg.source
        mix.weight = mixCfg.weight
        mix.offset = mixCfg.offset or 0
        mix.multiplex = mixCfg.multiplex or 0
        mix.flightModes = mixCfg.flightModes or 0
        mix.name = mixCfg.name or ""

        -- 获取当前通道的混控器数量，插入到末尾
        local mixesCount = model.getMixesCount(channel)

    -- 插入混控器
    model.insertMix(channel, mixesCount, mix)
  end
end

-- 设置逻辑开关
local function setupLogicalSwitches()
  -- 使用模板的 getLogicalSwitches 生成逻辑开关配置
  local configTable = getCurrentConfigTable()
  local logicalSwitches = template.getLogicalSwitches(configTable, switchPositionMap)

  -- 应用生成的逻辑开关配置到遥控器
  for i = 1, #logicalSwitches do
    local lsCfg = logicalSwitches[i]
    local lsIndex = lsCfg.index  -- 模板应返回 0-based 索引

    -- 读取当前逻辑开关配置
    local logicalSwitch = model.getLogicalSwitch(lsIndex)

    -- 应用模板生成的配置
    if lsCfg.name then
      logicalSwitch.name = lsCfg.name
    end
    if lsCfg.func then
      logicalSwitch.func = lsCfg.func
    end
    if lsCfg.v1 then
      logicalSwitch.v1 = lsCfg.v1
    end
    if lsCfg.v2 then
      logicalSwitch.v2 = lsCfg.v2
    end

    if lsCfg["and"] then
        logicalSwitch["and"] = lsCfg["and"]
    end

    -- 写入到遥控器
    model.setLogicalSwitch(lsIndex, logicalSwitch)
  end
end

local function onSaveButtonClick(button)
    saveCfgToFile()

    -- 设置曲线
    setupCurves()

    -- 设置输出通道
    setupOutputChannels()

    -- 设置输入
    setupInputs()

    -- 设置混控
    setupMixers()

    -- 设置逻辑开关
    setupLogicalSwitches()

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

    if switchSetPage then
        if switchSetPage.pageState == 1 then
            unloadSwitchSetPage()
            return true
        end
        switchSetPage.run(event, curTime)
        return true
    end

    local invers = false
    if getRtcTime() % 2 == 1 then
        invers = true
    end

    -- 动态绘制选项
    local yPos = 0
    for i = 1, #optionConfigs do
        lcd.drawText(2, yPos, optionConfigs[i].label, SMLSIZE + LEFT)
        optionSelectors[i]:draw(50, yPos, invers, SMLSIZE + LEFT)
        yPos = yPos + 10
    end

    -- 绘制固定按钮
    lcd.drawText(2, yPos, "Ch Setup:", SMLSIZE + LEFT)
    channelSetButton:draw(50, yPos, invers, SMLSIZE + LEFT)
    yPos = yPos + 10

    lcd.drawText(2, yPos, "Sw Setup:", SMLSIZE + LEFT)
    switchSetButton:draw(50, yPos, invers, SMLSIZE + LEFT)
    yPos = yPos + 10

    lcd.drawText(2, yPos, "Save:", SMLSIZE + LEFT)
    saveButton:draw(50, yPos, invers, SMLSIZE + LEFT)

    return doKey(event)
end

local function bg()
end

local function init()
    loadModule()

    -- 加载模板（ThermalGlider）
    template = LZ_runModule("LAOZHU/ModelTPL/ThermalGlider.lua")

    -- 获取选项配置
    optionConfigs = template.genOptions()

    -- 配置文件
    createModalCfg = CFGC:new()
    createModalCfg:readFromFile("createmodal.cfg")

    -- 动态创建选择器
    viewMatrix = ViewMatrix:new()
    viewMatrix:addRow()
    local row = viewMatrix.matrix[1]

    for i = 1, #optionConfigs do
        local optCfg = optionConfigs[i]

        -- 创建选择器
        local selector = Selector:new()
        selector:setTexts(optCfg.values)
        selector:setOnChange(function(sel)
            updatePinMapping()
        end)

        -- 从配置文件读取保存的值（0-based，需要转换为 1-based）
        local savedValue = createModalCfg:getNumberField(optCfg.cfgKey, 0)
        local maxIndex = #optCfg.values - 1
        if savedValue >= 0 and savedValue <= maxIndex then
            selector.selectedIndex = savedValue + 1
        end

        -- 保存到数组
        optionSelectors[i] = selector
        row[i] = selector
    end

    -- 通道设置按钮
    channelSetButton = Button:new()
    channelSetButton.text = "Setup"
    channelSetButton:setOnClick(onChannelSetButtonClick)
    row[#optionConfigs + 1] = channelSetButton

    -- 开关设置按钮
    switchSetButton = Button:new()
    switchSetButton.text = "Setup"
    switchSetButton:setOnClick(onSwitchSetButtonClick)
    row[#optionConfigs + 2] = switchSetButton

    -- 保存按钮
    saveButton = Button:new()
    saveButton.text = "Save"
    saveButton:setOnClick(onSaveButtonClick)
    row[#optionConfigs + 3] = saveButton

    -- 设置 ViewMatrix 焦点
    viewMatrix.selectedRow = 1
    viewMatrix.selectedCol = 1
    viewMatrix:updateCurIVFocus()

    -- 初始化针脚映射
    updatePinMapping()

    -- 初始化开关位置列表和映射
    local configTable = getCurrentConfigTable()
    switchPositionList = template.genSwitchPositionList(configTable)

    -- 从配置文件读取已保存的开关位置
    for i = 1, #switchPositionList do
        local switchCfg = switchPositionList[i]
        local savedSwitchIndex = createModalCfg:getNumberField(switchCfg.name, -1)
        switchPositionMap[switchCfg.name] = savedSwitchIndex
    end
end

init()

this = {run=run, bg=bg, pageState=0}

return this
