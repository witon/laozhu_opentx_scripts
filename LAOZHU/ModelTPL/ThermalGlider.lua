LZ_runModule("LAOZHU/ModelTPL/ModelTPLUtils.lua")

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

local curConfig = 0
local curGVs = GVs
local curInputs = {}
local curOutputs = {}
local curCurves = {}
local curLogicalSwitches = {}
local curSwitchPositionMap = {}
local curFlightModes = {}
local curChannelList = {}

local curPinToChannelMap = {}

local curMixers = {}



local LogicalSwitches = {
  {key = "L01", index = 0, name = "SpeedMode"},
  {key = "L02", index = 1, name= "CruiseMode"},
  {key = "L03", index = 2, name= "ThermalMode"},
  {key = "L04", index = 3, name= "StayMode"},
  {key = "L05", index = 4, name= "AccelMode"},
}


local FlightModes = {
  -- F3K: 7个飞行模式
  -- trimsModes 数组格式：{ail, ele, thr, rud}，每个元素表示该微调使用哪个飞行模式的微调值，最后一位表示等于或者增加，从二位开始往前，作为模式索引。31表示禁用微调
  F3K = {
    {name = "Zoom", index = 0, switchName = nil, trimsModes = {0, 0, 31, 0}},
    {name = "Preset", index = 1, switchName = "preset_sw", trimsModes = {1*2, 1*2, 31, 1*2}}, 
    {name = "Accel", index = 2, lsName = "AccelMode", trimsModes = {2*2, 2*2, 31, 2*2}},     
    {name = "Speed", index = 3, lsName = "SpeedMode", trimsModes = {3*2, 3*2, 31, 2*2}},     
    {name = "Cruise", index = 4, lsName = "CruiseMode", trimsModes = {4*2, 4*2, 31, 2*2}},   
    {name = "Thermal", index = 5, lsName = "ThermalMode", trimsModes = {5*2, 5*2, 31, 2*2}}, 
    {name = "Stay", index = 6, lsName = "StayMode", trimsModes = {6*2, 6*2, 31, 2*2}}        
  },
  -- F5J: 8个飞行模式
  F5J = {
    {name = "Zoom1", index = 0, switchName = nil, trimsModes = {0, 0, 0, 0}},        
    {name = "Zoom2", index = 1, switchName = "zoom2_sw", trimsModes = {1, 1, 1, 1}}, 
    {name = "Zoom3", index = 2, switchName = "zoom3_sw", trimsModes = {2, 2, 2, 2}}, 
    {name = "Accel", index = 3, lsName = "AccelMode", trimsModes = {3, 3, 3, 3}},    
    {name = "Speed", index = 4, lsName = "SpeedMode", trimsModes = {4, 4, 4, 4}},    
    {name = "Cruise", index = 5, lsName = "CruiseMode", trimsModes = {5, 5, 5, 5}},  
    {name = "Thermal", index = 6, lsName = "ThermalMode", trimsModes = {6, 6, 6, 6}},
    {name = "Stay", index = 7, lsName = "StayMode", trimsModes = {7, 7, 7, 7}}       
  }
}

-- 开关位置配置表（按飞机类型分层）
local switchPositionConfigs = {
  -- 通用开关（所有飞机类型都需要）
  common = {
    {name = "zoom_sw", label = "Zoom"},
    {name = "brk_sw", label = "Brake"},
    {name = "speed_sw", label = "Speed"},
    {name = "cruise_sw", label = "Cruise"},
    {name = "therm_sw", label = "Thermal"},
    {name = "fine_sw", label = "fine"}
  },

  -- F3K 特有开关
  F3K = {
    {name = "preset_sw", label = "Preset"}
  },

  -- F5J 特有开关
  F5J = {
    {name = "zoom2_sw", label = "Zoom2"},
    {name = "zoom3_sw", label = "Zoom3"}
  }
}

-- 通道混控生成器映射表（按飞机类型和尾翼类型分层）
local channelMixerGenerators = {
  -- F3K 只使用十字尾
  F3K = {
    Normal = {
      LAil = function(ctx, outputIndex)
        return createAileronMixers(ctx, outputIndex, 'left')
      end,
      RAil = function(ctx, outputIndex)
        return createAileronMixers(ctx, outputIndex, 'right')
      end,
      Ele = function(ctx, outputIndex)
        return createElevatorMixers(ctx, outputIndex)
      end,
      Rud = function(ctx, outputIndex)
        return createRudderMixers(ctx, outputIndex)
      end,
      LFlap = function(ctx, outputIndex)
        return createFlapMixers(ctx, outputIndex, 'left')
      end,
      RFlap = function(ctx, outputIndex)
        return createFlapMixers(ctx, outputIndex, 'right')
      end,
      MFlap = function(ctx, outputIndex)
        return createFlapMixers(ctx, outputIndex, 'middle')
      end,
      Flap = function(ctx, outputIndex)
        return createFlapMixers(ctx, outputIndex, 'single')
      end
    }
  },

  -- F5J 支持 V尾和十字尾
  F5J = {
    VTail = {
      LAil = function(ctx, outputIndex)
        return createAileronMixers(ctx, outputIndex, 'left')
      end,
      RAil = function(ctx, outputIndex)
        return createAileronMixers(ctx, outputIndex, 'right')
      end,
      LVTail = function(ctx, outputIndex)
        return createVTailMixers(ctx, outputIndex, 'left')
      end,
      RVTail = function(ctx, outputIndex)
        return createVTailMixers(ctx, outputIndex, 'right')
      end,
      Thr = function(ctx, outputIndex)
        return createThrottleMixers(ctx, outputIndex)
      end,
      LFlap = function(ctx, outputIndex)
        return createFlapMixers(ctx, outputIndex, 'left')
      end,
      RFlap = function(ctx, outputIndex)
        return createFlapMixers(ctx, outputIndex, 'right')
      end,
      MFlap = function(ctx, outputIndex)
        return createFlapMixers(ctx, outputIndex, 'middle')
      end,
      Flap = function(ctx, outputIndex)
        return createFlapMixers(ctx, outputIndex, 'single')
      end
    },

    Normal = {
      LAil = function(ctx, outputIndex)
        return createAileronMixers(ctx, outputIndex, 'left')
      end,
      RAil = function(ctx, outputIndex)
        return createAileronMixers(ctx, outputIndex, 'right')
      end,
      Ele = function(ctx, outputIndex)
        return createElevatorMixers(ctx, outputIndex)
      end,
      Rud = function(ctx, outputIndex)
        return createRudderMixers(ctx, outputIndex)
      end,
      Thr = function(ctx, outputIndex)
        return createThrottleMixers(ctx, outputIndex)
      end,
      LFlap = function(ctx, outputIndex)
        return createFlapMixers(ctx, outputIndex, 'left')
      end,
      RFlap = function(ctx, outputIndex)
        return createFlapMixers(ctx, outputIndex, 'right')
      end,
      MFlap = function(ctx, outputIndex)
        return createFlapMixers(ctx, outputIndex, 'middle')
      end,
      Flap = function(ctx, outputIndex)
        return createFlapMixers(ctx, outputIndex, 'single')
      end
    }
  }
}

local function printTable(t, indent)
    indent = indent or ""
    if type(t) ~= "table" then
        print(indent .. tostring(t))
        return
    end

    for k, v in pairs(t) do
        if type(v) == "table" then
            print(indent .. k .. ":")
            printTable(v, indent .. "  ")
        else
            print(indent .. k .. ": " .. tostring(v))
        end
    end
end


-- 获取曲线定义列表（单一数据源）
-- 返回：曲线定义数组，每个元素包含 {channelName, curveName}
local function getCurveDefinitions()
  local defs = {}

  -- 1. 左副翼曲线 (Left Aileron -> la)
  if hasChannel(curChannelList, "LAil") then
    defs[#defs+1] = {
      channelName = "LAil",
      curveName = "la"
    }
  end

  -- 2. 左襟翼曲线 (Left Flap -> lf)
  if hasChannel(curChannelList, "LFlap") then
    defs[#defs+1] = {
      channelName = "LFlap",
      curveName = "lf"
    }
  end

  -- 3. 左V尾曲线 (Left V-Tail -> lvt)
  if curConfig.tail_type == 0 and hasChannel(curChannelList, "LVTail") then
    defs[#defs+1] = {
      channelName = "LVTail",
      curveName = "lvt"
    }
  end

  return defs
end

local function genCurves()
  local curves = {}
  local curveDefs = getCurveDefinitions()

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
  curCurves = curves
  return curves
end

local function genOutputs()
  local outputs = {}

  -- 使用共用函数获取曲线定义，构建通道名到曲线索引的映射
  local curveDefs = getCurveDefinitions()
  local channelToCurveIndex = {}
  for i = 1, #curveDefs do
    local def = curveDefs[i]
    channelToCurveIndex[def.channelName] = i - 1  -- 转换为 0-based 索引
  end

  -- 遍历 8 个针脚（Pin1-8 对应 index 0-7）
  for pinNum = 1, 8 do
    local channelName = curPinToChannelMap[pinNum]

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
  curOutputs = outputs
  return outputs
end




-- 准备混控生成器上下文对象
-- 参数：cfg - 配置对象，pinToChannelMap - 针脚到通道的映射
-- 返回：包含所有混控生成器需要的通用数据的上下文对象
local function prepareContext(cfg)
  local gvIndexes = {}
  for i = 1, #GVs do
    gvIndexes[GVs[i].name] = getGVIndex(curGVs, GVs[i].index)
  end
  return {
    -- 配置
    cfg = cfg,
    pinToChannelMap = curPinToChannelMap,
    switchPositionMap = curSwitchPositionMap,
    -- 全局变量索引
    gvIndexes = gvIndexes,
  }
end

-- 副翼混控生成器（支持左右副翼）
-- 参数：ctx - 上下文对象，outputIndex - 输出通道索引，side - 'left' 或 'right'
-- 返回：混控配置数组
local function createAileronMixers(ctx, outputIndex, side)
  local mixers = {}

  -- 差动：左副翼-5，右副翼+5
  local differential = (side == 'left') and -5 or 5

  -- 混控名称前缀
  local mixNamePrefix = (side == 'left') and 'l' or 'r'

  -- 获取全局变量
  local aflGV = ctx.gvIndexes.AFL
  local efGV = ctx.gvIndexes.EF

  -- 1. 副翼基础混控
  mixers[#mixers+1] = {
    channel = outputIndex,
    name = mixNamePrefix .. "a",
    source = getInputIndex(curInputs, "Ail"),
    weight = 100,
    offset = 0,
    differential = differential,
    multiplex = 0  -- 加法混控
  }

  -- 2. 刹车乘法混控
  -- F3K 和 F5J 可能有差异，这里预留判断
  local brkWeight = 90
  local brkOffset = 90
  if ctx.cfg.plane_type == 1 then
    -- F5J 特有参数（如果需要的话）
    -- brkWeight = 95
    -- brkOffset = 95
  end

  mixers[#mixers+1] = {
    channel = outputIndex,
    name = "brkm",
    source = ctx.inputIds.thr,  -- 刹车输入（来自油门摇杆）
    weight = brkWeight,
    offset = brkOffset,
    multiplex = 1,              -- 乘法混控
    switch = ctx.switchPositionMap.brk_sw,    -- 刹车开关位置
    flightModes = 0 
  }

  -- 3. 升降混控副翼
  -- 使用全局变量作为权重和偏置
  local efGVSource = getFieldInfo("gvar" .. (efGV + 1)).id
  local aflGVSource = getFieldInfo("gvar" .. (aflGV + 1)).id
  mixers[#mixers+1] = {
    channel = outputIndex,
    name = "ele",
    source = ctx.inputIds.ele,
    weight = efGVSource,    -- 使用全局变量"E-F"作为权重
    offset = aflGVSource,   -- 使用全局变量"AFL"作为偏置
    multiplex = 0           -- 加法混控
  }

  -- 4. 刹车混控
  mixers[#mixers+1] = {
    channel = outputIndex,
    name = "brk",
    source = ctx.inputIds.thr,  -- 刹车输入
    weight = -30,
    offset = 0,
    multiplex = 0,              -- 加法混控
    switch = ctx.switchPositionMap.brk_sw,    -- 刹车开关位置
    flightModes = 0 
  }

  return mixers
end

-- 襟翼混控生成器（F3K 和 F5J 共用）
-- 参数：ctx - 上下文对象，outputIndex - 输出通道索引，position - 'left'/'right'/'middle'/'single'
-- 返回：混控配置数组
local function createFlapMixers(ctx, outputIndex, position)
  local mixers = {}

  -- TODO: 实现襟翼混控逻辑

  return mixers
end

-- V尾混控生成器
-- 参数：ctx - 上下文对象，outputIndex - 输出通道索引，side - 'left' 或 'right'
-- 返回：混控配置数组
local function createVTailMixers(ctx, outputIndex, side)
  local mixers = {}

  -- TODO: 实现 V尾混控逻辑

  return mixers
end

-- 升降舵混控生成器（十字尾）
-- 参数：ctx - 上下文对象，outputIndex - 输出通道索引
-- 返回：混控配置数组
local function createElevatorMixers(ctx, outputIndex)
  local mixers = {}

  -- TODO: 实现升降舵混控逻辑

  return mixers
end

-- 方向舵混控生成器（十字尾）
-- 参数：ctx - 上下文对象，outputIndex - 输出通道索引
-- 返回：混控配置数组
local function createRudderMixers(ctx, outputIndex)
  local mixers = {}

  -- TODO: 实现方向舵混控逻辑

  return mixers
end

-- 油门混控生成器（仅 F5J）
-- 参数：ctx - 上下文对象，outputIndex - 输出通道索引
-- 返回：混控配置数组
local function createThrottleMixers(ctx, outputIndex)
  local mixers = {}

  -- TODO: 实现油门混控逻辑

  return mixers
end

-- 生成输入配置
-- 返回：输入配置数组，每个元素包含 {index, name, source, weight}
local function genInputs()
  local inputs = {}

  -- 基础输入索引（0-based）
  local inputIndex = 0

  -- 1. 副翼输入 (Aileron)
  inputs[#inputs+1] = {
    index = inputIndex,
    name = "Ail",
    source = getFieldInfo("ail").id,
    weight = 100
  }
  inputIndex = inputIndex + 1

  -- 2. 升降输入 (Elevator)
  inputs[#inputs+1] = {
    index = inputIndex,
    name = "Ele",
    source = getFieldInfo("ele").id,
    weight = 100
  }
  inputIndex = inputIndex + 1

  -- 3. 方向输入 (Rudder)
  inputs[#inputs+1] = {
    index = inputIndex,
    name = "Rud",
    source = getFieldInfo("rud").id,
    weight = 100
  }
  inputIndex = inputIndex + 1

  -- 4. 油门输入 (Throttle) - 仅 F5J
  if curConfig.plane_type == 1 then
    inputs[#inputs+1] = {
      index = inputIndex,
      name = "Thr",
      source = getFieldInfo("thr").id,
      weight = 100
    }
    inputIndex = inputIndex + 1
  end

  -- 5. 刹车输入 (Brake) - 来自油门摇杆
  inputs[#inputs+1] = {
    index = inputIndex,
    name = "Brk",
    source = getFieldInfo("thr").id,
    weight = 100
  }
  curInputs = inputs
  return inputs
end



-- 生成混控器配置
-- 返回：混控配置数组
local function genMixers()
  local mixers = {}

  -- 准备上下文对象
  local ctx = prepareContext(curConfig)

  -- 根据配置选择对应的生成器映射表
  local planeType = (curConfig.plane_type == 0) and "F3K" or "F5J"
  local tailType = (curConfig.tail_type == 0) and "VTail" or "Normal"

  local generatorTable = channelMixerGenerators[planeType][tailType]

  if not generatorTable then
    -- 错误处理：未找到对应的生成器表
    return mixers
  end

  -- 遍历 channelList，为每个通道生成混控
  for i = 1, #curChannelList do
    local channelName = curChannelList[i]
    local outputIndex = getOutputIndex(curPinToChannelMap, channelName)

    if outputIndex then
      local generator = generatorTable[channelName]
      if generator then
        local channelMixers = generator(ctx, outputIndex)

        -- 合并到总混控数组
        for j = 1, #channelMixers do
          mixers[#mixers+1] = channelMixers[j]
        end
      end
    end
  end

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



-- 生成开关位置列表
-- 返回：开关位置配置数组
local function genSwitchPositionList()
  local switchPositions = {}

  -- 获取飞机类型特有的开关配置
  local planeType = (curConfig.plane_type == 0) and "F3K" or "F5J"
  local specificConfigs = switchPositionConfigs[planeType]

  -- 添加特有开关
  if specificConfigs then
    for i = 1, #specificConfigs do
      switchPositions[#switchPositions+1] = {
        name = specificConfigs[i].name,
        label = specificConfigs[i].label,
        switchIndex = -1
      }
    end
  end

  -- 添加通用开关
  local commonConfigs = switchPositionConfigs.common
  for i = 1, #commonConfigs do
    switchPositions[#switchPositions+1] = {
      name = commonConfigs[i].name,
      label = commonConfigs[i].label,
      switchIndex = -1
    }
  end

  return switchPositions
end

-- 根据飞机配置生成所有可用的舵面（Channel）列表
-- 返回：舵面名称数组
local function genChannelList()
  local channels = {}
  local pType = curConfig.plane_type
  local tType = curConfig.tail_type
  local fCount = curConfig.flap_count

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

  curChannelList = channels
  return channels
end

-- 生成逻辑开关配置
-- 返回：逻辑开关配置数组
local function genLogicalSwitches()
  local logicalSwitches = {}
  
  -- 获取开关索引
  local speedModeSwitch = curSwitchPositionMap["speed_sw"]
  local cruiseModeSwitch = curSwitchPositionMap["cruise_sw"]
  local thermalModeSwitch = curSwitchPositionMap["therm_sw"]
  local fineModeSwitch = curSwitchPositionMap["fine_sw"]
  local zoomModeSwitch = curSwitchPositionMap["zoom_sw"]
  local ls = nil
  
  -- 1. SpeedMode 逻辑开关 (index 0)
  if speedModeSwitch then
    ls = {
      index = 0,
      name = "SpeedMode",
      func = LS_FUNC_AND,
      v1 = speedModeSwitch,
      v2 = zoomModeSwitch * -1,
    }
    ls["and"] = fineModeSwitch
    logicalSwitches[#logicalSwitches+1] = ls
  end
  
  -- 2. CruiseMode 逻辑开关 (index 1)
  if cruiseModeSwitch then
    logicalSwitches[#logicalSwitches+1] = {
      index = 1,
      name = "CruiseMode",
      func = LS_FUNC_AND,
      v1 = cruiseModeSwitch,
      v2 = zoomModeSwitch * -1
    }
  end
  -- 3. ThermalMode 逻辑开关 (index 2)
  if thermalModeSwitch and thermalModeSwitch ~= -1 then
    local ls = {
      index = 2,
      name = "ThermalMode",
      func = LS_FUNC_AND,
      v1 = thermalModeSwitch,
      v2 = zoomModeSwitch * -1,
    }
    ls["and"] = fineModeSwitch
    logicalSwitches[#logicalSwitches+1] = ls
  end

  -- 4. StayMode 逻辑开关 (index 3)
  if fineModeSwitch then
    if thermalModeSwitch then
      local ls = {
        index = 3,
        name = "StayMode",
        func = LS_FUNC_AND,
        v1 = thermalModeSwitch, 
        v2 = zoomModeSwitch * -1,
      }
      ls["and"] = fineModeSwitch * -1
      logicalSwitches[#logicalSwitches+1] = ls
    end
  end
  -- 5. AccelMode 逻辑开关 (index 4)
  if fineModeSwitch then
    if speed_mode_sw then
      ls = {
        index = 4,
        name = "AccelMode",
        func = 7,  -- LS_FUNC_AND
        v1 = speedModeSwitch,
        v2 = zoomModeSwitch * -1
      }
      ls["and"] = fineModeSwitch * -1
      logicalSwitches[#logicalSwitches+1] = ls
    end
  end
  curLogicalSwitches = logicalSwitches
  return logicalSwitches
end



-- 生成飞行模式配置
-- 返回：飞行模式配置数组
local function genFlightModes()
  local flightModes = {}

  -- 根据飞机类型选择模式列表
  local modeList = nil
  if curConfig.plane_type == 0 then
    -- F3K
    modeList = FlightModes.F3K
  else
    -- F5J
    modeList = FlightModes.F5J
  end

  -- 生成飞行模式配置
  for i = 1, #modeList do
    local modeDef = modeList[i]
    local fmCfg = {
      index = modeDef.index,
      name = modeDef.name
    }

    -- 设置微调模式（转换为零索引表）
    if modeDef.trimsModes then
      -- EdgeTX API 使用零索引表，例如 {[0]=0, [1]=0, [2]=0, [3]=0}
      fmCfg.trimsModes = {}
      for trimIdx = 1, #modeDef.trimsModes do
        fmCfg.trimsModes[trimIdx] = modeDef.trimsModes[trimIdx]
      end
    end

    -- 确定激活开关
    if modeDef.switchName then
      -- 使用物理开关
      local switchIndex = curSwitchPositionMap[modeDef.switchName]
      if switchIndex and switchIndex ~= -1 then
        fmCfg.switch = switchIndex
      end
    elseif modeDef.lsName then
      -- 使用逻辑开关
      local lsIndex = getLogicalSwitchIndex(curLogicalSwitches, modeDef.lsName)
      if lsIndex then
        fmCfg.switch = lsIndex
      end
    end
    -- 如果没有指定开关（如默认模式），则不设置 switch 字段

    flightModes[#flightModes+1] = fmCfg
  end
  curFlightModes = flightModes
  return flightModes
end

local function setSwitchPositionMap(switchPositionMap)
  curSwitchPositionMap = switchPositionMap
end

local function setPinToChannelMap(pinToChannelMap)
  curPinToChannelMap = pinToChannelMap
end

local function setConfig(config)
  curConfig = config
end

return {
  genCurves = genCurves,
  genOutputs = genOutputs,
  genInputs = genInputs,
  genMixers = genMixers,
  genLogicalSwitches = genLogicalSwitches,
  genFlightModes = genFlightModes,
  genOptions = genOptions,
  genChannelList = genChannelList,
  genSwitchPositionList = genSwitchPositionList,
  setSwitchPositionMap = setSwitchPositionMap,
  setPinToChannelMap = setPinToChannelMap,
  setConfig = setConfig,
}