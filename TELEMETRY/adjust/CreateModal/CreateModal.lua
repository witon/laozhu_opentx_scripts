local viewMatrix = nil
local this = nil
local planeTypeSelector = nil
local tailTypeSelector = nil
local flapCountSelector = nil
local channelSetButton = nil
local saveButton = nil
local channelSetPage = nil
local createModalCfg = nil

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

local function loadChannelSetPage()
    if channelSetPage ~= nil then
        return
    end
    channelSetPage = LZ_runModule("TELEMETRY/adjust/CreateModal/ChannelSetPage.lua")
    -- 传递 0-based 索引给 ChannelSetPage
    channelSetPage.init(
        planeTypeSelector.selectedIndex - 1,
        tailTypeSelector.selectedIndex - 1,
        flapCountSelector.selectedIndex - 1,
        createModalCfg
    )
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

local function onSaveButtonClick(button)
    saveCfgToFile()
    -- TODO: 实现设置输出通道和创建混控的逻辑
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

-- 自定义 Selector 的 inc/dec 方法，添加边界检查
local function createBoundedSelector(texts)
    local selector = Selector:new()
    selector:setTexts(texts)
    selector.selectedIndex = 1

    -- 重写 inc 方法
    local originalInc = selector.inc
    selector.inc = function(self)
        if self.selectedIndex < #texts then
            self.selectedIndex = self.selectedIndex + 1
            return true
        end
        return false
    end

    -- 重写 dec 方法
    local originalDec = selector.dec
    selector.dec = function(self)
        if self.selectedIndex > 1 then
            self.selectedIndex = self.selectedIndex - 1
            return true
        end
        return false
    end

    return selector
end

local function init()
    loadModule()

    viewMatrix = ViewMatrix:new()

    -- 飞机类型选择器
    planeTypeSelector = createBoundedSelector({"F3K", "F5J"})

    -- 尾类型选择器
    tailTypeSelector = createBoundedSelector({"V-Tail", "Normal"})

    -- 襟翼数量选择器
    flapCountSelector = createBoundedSelector({"None", "1Flap", "2Flap", "3Flap"})

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
end

init()

this = {run=run, bg=bg, pageState=0}

return this
