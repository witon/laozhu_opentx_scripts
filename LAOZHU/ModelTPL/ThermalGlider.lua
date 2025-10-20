local GVs = {
  {name = "AFL", index = 0},
  {name = "ELE", index = 1},
  {name = "ADR", index = 2},
  {name = "E-F", index = 3},
  {name = "EDR", index = 4},
  {name = "FFL", index = 5},
  {name = "RUD", index = 6},
  {name = "ET", index = 7},
}

-- 辅助函数：检查通道是否存在
local function hasChannel(channelList, channelName)
  for i = 1, #channelList do
    if channelList[i] == channelName then
      return true
    end
  end
  return false
end

-- 获取曲线定义列表（单一数据源）
-- 返回：曲线定义数组，每个元素包含 {channelName, curveName}
local function getCurveDefinitions(cfg, channelList)
  local defs = {}

  -- cfg.plane_type: 0=F3K, 1=F5J
  -- cfg.tail_type: 0=V尾, 1=十字尾
  -- cfg.flap_count: 0=无襟翼, 1-3=襟翼数量

  -- 1. 左副翼曲线 (Left Aileron -> la)
  if hasChannel(channelList, "LAil") then
    defs[#defs+1] = {
      channelName = "LAil",
      curveName = "la"
    }
  end

  -- 2. 左襟翼曲线 (Left Flap -> lf)
  if hasChannel(channelList, "LFlap") then
    defs[#defs+1] = {
      channelName = "LFlap",
      curveName = "lf"
    }
  end

  -- 3. 左V尾曲线 (Left V-Tail -> lvt)
  if cfg.tail_type == 0 and hasChannel(channelList, "LVTail") then
    defs[#defs+1] = {
      channelName = "LVTail",
      curveName = "lvt"
    }
  end

  return defs
end

local function genCurves(cfg, channelList)
  local curves = {}
  local curveDefs = getCurveDefinitions(cfg, channelList)

  -- 根据曲线定义生成曲线配置
  for i = 1, #curveDefs do
    local def = curveDefs[i]
    curves[#curves+1] = {
      index = i - 1,      -- 转换为 0-based 索引
      name = def.curveName,
      type = 1,           -- 1=Custom (自定义曲线)
      smooth = true,      -- 平滑曲线
      points = {-100, -75, -50, -25, 0, 25, 50, 75, 100}  -- 9点曲线
    }
  end

  return curves
end

local function genOutputs(cfg, channelList, pinToChannelMap)
  local outputs = {}

  -- 使用共用函数获取曲线定义，构建通道名到曲线索引的映射
  local curveDefs = getCurveDefinitions(cfg, channelList)
  local channelToCurveIndex = {}
  for i = 1, #curveDefs do
    local def = curveDefs[i]
    channelToCurveIndex[def.channelName] = i - 1  -- 转换为 0-based 索引
  end

  -- 遍历 8 个针脚（Pin1-8 对应 index 0-7）
  for pinNum = 1, 8 do
    local channelName = pinToChannelMap[pinNum]

    -- 如果该针脚分配了舵面
    if channelName and channelName ~= "" then
      local outputCfg = {
        index = pinNum - 1,  -- 转换为 0-based 索引
        name = channelName,
        min = -100,
        max = 100,
        offset = 0,
        revert = false
      }

      -- 如果该通道有对应的曲线，则设置曲线索引
      if channelToCurveIndex[channelName] then
        outputCfg.curve = channelToCurveIndex[channelName]
      end

      outputs[#outputs+1] = outputCfg
    else
      -- 未分配舵面的针脚使用默认通道号
      outputs[#outputs+1] = {
        index = pinNum - 1,
        name = "CH" .. pinNum,
        min = -100,
        max = 100,
        offset = 0,
        revert = false
      }
    end
  end

  return outputs
end

local function genMixers(cfg, channelList, pinToChannelMap)
  local mixers = {}
  --TODO: 根据模型类型和舵面数量，生成混控的逻辑
  -- cfg.plane_type: 0=F3K, 1=F5J
  -- cfg.tail_type: 0=V尾, 1=十字尾
  -- cfg.flap_count: 0=无襟翼, 1-3=襟翼数量
  return mixers
end

-- 生成需要用户选择的选项列表，用于CreateModal.lua主界面给用户选择
-- 返回格式：数组，每个元素包含：
--   label: 显示标签（用于UI）
--   cfgKey: 配置文件中的键名
--   values: 可选值数组（显示文本）
--   onChange: 可选的回调函数名称
local function genOptions()
  local options = {}
  options[#options+1] = {
    label = "Plane:",
    cfgKey = "plane_type",
    values = {"F3K", "F5J"}
  }
  options[#options+1] = {
    label = "Tail:",
    cfgKey = "tail_type",
    values = {"V-Tail", "Normal"}
  }
  options[#options+1] = {
    label = "Flap:",
    cfgKey = "flap_count",
    values = {"None", "1Flap", "2Flap", "3Flap"}
  }
  return options
end

-- 根据飞机配置生成所有可用的舵面（Channel）列表
-- 参数：cfg - 命名配置参数表
--   cfg.plane_type: 0=F3K, 1=F5J
--   cfg.tail_type: 0=V尾, 1=十字尾
--   cfg.flap_count: 0=无襟翼, 1-3=襟翼数量
-- 返回：舵面名称数组
local function genChannelList(cfg)
  local channels = {}
  local pType = cfg.plane_type
  local tType = cfg.tail_type
  local fCount = cfg.flap_count

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

return {
  GVs = GVs,
  genCurves = genCurves,
  genOutputs = genOutputs,
  genMixers = genMixers,
  genOptions = genOptions,
  genChannelList = genChannelList,
}