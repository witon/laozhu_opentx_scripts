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

local LogicalSwitches = {
  {name = "SpeedMode", index = 0},
  {name = "CruiseMode", index = 1},
  {name = "ThermalMode", index = 2},
  {name = "StayMode", index = 3},
  {name = "AccelMode", index = 4},
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

local function getCurves(cfg, channelList)
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

local function getOutputs(cfg, channelList, pinToChannelMap)
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

-- 辅助函数：根据舵面名称查找对应的输出通道索引（0-based）
local function getOutputIndex(channelName, pinToChannelMap)
  for pinNum = 1, 8 do
    if pinToChannelMap[pinNum] == channelName then
      return pinNum - 1  -- 转换为 0-based 索引
    end
  end
  return nil
end

-- 辅助函数：查找全局变量索引
local function getGVIndex(gvName)
  for i = 1, #GVs do
    if GVs[i].name == gvName then
      return GVs[i].index
    end
  end
  return nil
end

-- 生成输入配置
-- 返回：输入配置数组，每个元素包含 {index, name, source, weight}
local function getInputs(cfg)
  local inputs = {}

  -- cfg.plane_type: 0=F3K, 1=F5J
  local pType = cfg.plane_type

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
  if pType == 1 then
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

  return inputs
end

-- 生成混控器配置
local function getMixers(cfg, channelList, pinToChannelMap)
  local mixers = {}

  -- cfg.plane_type: 0=F3K, 1=F5J
  -- cfg.tail_type: 0=V尾, 1=十字尾
  -- cfg.flap_count: 0=无襟翼, 1-3=襟翼数量

  local pType = cfg.plane_type
  local tType = cfg.tail_type
  local fCount = cfg.flap_count

  -- 获取全局变量索引
  local aflGV = getGVIndex("AFL")  -- 副翼偏置
  local eleGV = getGVIndex("ELE")  -- 升降大小舵
  local adrGV = getGVIndex("ADR")  -- 副翼大小舵
  local efGV = getGVIndex("E-F")   -- 升降混控襟翼/副翼
  local fflGV = getGVIndex("FFL")  -- 襟翼偏置
  local rudGV = getGVIndex("RUD")  -- 方向大小舵

  -- 获取输入源ID
  local ailInput = getFieldInfo("ail").id   -- 副翼输入
  local eleInput = getFieldInfo("ele").id   -- 升降舵输入
  local rudInput = getFieldInfo("rud").id   -- 方向输入
  local thrInput = getFieldInfo("thr").id   -- 油门输入（刹车也使用此输入）

  -- 获取开关ID
  -- EdgeTX中三段开关上位通常表示为 "sb↑" 或 "sb2"
  -- 这里使用 getFieldInfo 获取SB开关的ID，需要根据实际EdgeTX版本调整
  local sbUpSwitch = getFieldInfo("sb").id  -- SB开关（注：可能需要调整为特定位置，如"sb↑"）
  -- 飞行模式位掩码
  -- EdgeTX中 flightModes 字段使用位掩码表示混控在哪些模式下禁用
  -- 0 = 在所有模式下启用
  -- 如果要在模式2-8中启用，需要禁用模式0和1
  -- 位掩码：bit0 | bit1 = 0x03 (二进制 0000 0011)
  local modes2to8 = 0x03  -- 禁用模式0,1，即在模式2-8中有效

  local line = nil
  for i=0, 3 do
    line = model.getMix(0, i)
    print("line:", i)
    printTable(line)
    
  end 

  -- 左副翼通道混控
  local lAilOut = getOutputIndex("LAil", pinToChannelMap)
  if lAilOut then
    -- 1. 副翼基础混控 (la)
    -- 名称"la"，source为副翼输入(Ail)，权重100，差动-5
    mixers[#mixers+1] = {
      channel = lAilOut,
      name = "la",
      source = ailInput,
      weight = 100,
      offset = 0,
      differential = -5,  -- 差动 -5
      multiplex = 0       -- 加法混控
    }

    -- 2. 刹车乘法混控 (brkm)
    -- 名称"brkm"，source为刹车输入(Brk)，有效模式(2-8)，开启开关SB上，乘法混控，权重90，偏移90
    mixers[#mixers+1] = {
      channel = lAilOut,
      name = "brkm",
      source = thrInput,      -- 刹车输入（来自油门摇杆）
      weight = 90,
      offset = 90,
      multiplex = 1,          -- 乘法混控
      switch = sbUpSwitch,    -- SB开关上位
      flightModes = modes2to8 -- 在模式2-8中有效
    }

    -- 3. 升降混控副翼 (ele)
    -- 名称"ele"，source为升降舵输入(Ele)，权重为全局变量"E-F"，偏置为全局变量"AFL"
    -- 注：EdgeTX中使用全局变量作为权重/偏置需要特殊处理
    -- 这里使用 getFieldInfo("gvarX") 的方式获取全局变量source ID
    local efGVSource = getFieldInfo("gvar" .. (efGV + 1)).id   -- GV索引+1得到名称，如GV0->gvar1
    local aflGVSource = getFieldInfo("gvar" .. (aflGV + 1)).id
    mixers[#mixers+1] = {
      channel = lAilOut,
      name = "ele",
      source = eleInput,
      weight = efGVSource,    -- 使用全局变量"E-F"作为权重
      offset = aflGVSource,   -- 使用全局变量"AFL"作为偏置
      multiplex = 0           -- 加法混控
    }

    -- 4. 刹车混控 (brk)
    -- 名称"brk"，source为刹车输入(Brk)，权重-30，有效模式(2-8)
    mixers[#mixers+1] = {
      channel = lAilOut,
      name = "brk",
      source = thrInput,      -- 刹车输入
      weight = -30,
      offset = 0,
      multiplex = 0,          -- 加法混控
      flightModes = modes2to8 -- 在模式2-8中有效
    }
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

local function genSwitchPositionList(cfg)
  local switchPositions = {}
  local switchPosition = nil

  -- 如果是F3K飞机（plane_type == 0），需要preset开关位置
  if cfg.plane_type == 0 then
    switchPosition = {
      name = "preset_sw",
      label = "Preset",
      switchIndex = -1
    }
    switchPositions[#switchPositions+1] = switchPosition
  end

  -- 飞行模式开关（所有飞机类型都需要）

  --爬升开关位置
  switchPosition = {
    name = "zoom_sw",
    label = "Zoom",
    switchIndex = -1
  }
  switchPositions[#switchPositions+1] = switchPosition


  --刹车开关位置
  switchPosition = {
    name = "brk_sw",
    label = "Brake",
    switchIndex = -1
  }
  switchPositions[#switchPositions+1] = switchPosition

  --速度模式开关位置
  switchPosition = {
    name = "speed_sw",
    label = "Speed",
    switchIndex = -1
  }
  switchPositions[#switchPositions+1] = switchPosition

  --巡航模式开关位置
  switchPosition = {
    name = "cruise_sw",
    label = "Cruise",
    switchIndex = -1
  }
  switchPositions[#switchPositions+1] = switchPosition

  --气流模式开关位置
  switchPosition = {
    name = "therm_sw",
    label = "Thermal",
    switchIndex = -1
  }
  switchPositions[#switchPositions+1] = switchPosition

  --精细模式开关位置
  switchPosition = {
    name = "fine_sw",
    label = "fine",
    switchIndex = -1
  }
  switchPositions[#switchPositions+1] = switchPosition


  return switchPositions
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

-- 生成逻辑开关配置
-- 参数：cfg - 配置参数表，switchPositionMap - 开关名称到 switchIndex 的映射
-- 返回：逻辑开关配置数组
local function getLogicalSwitches(cfg, switchPositionMap)
  local logicalSwitches = {}
  
  -- 获取开关索引
  local speedModeSwitch = switchPositionMap["speed_sw"]
  local cruiseModeSwitch = switchPositionMap["cruise_sw"]
  local thermalModeSwitch = switchPositionMap["therm_sw"]
  local fineModeSwitch = switchPositionMap["fine_sw"]
  local zoomModeSwitch = switchPositionMap["zoom_sw"]
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
  return logicalSwitches
end

return {
  GVs = GVs,
  LogicalSwitches = LogicalSwitches,
  getCurves = getCurves,
  getOutputs = getOutputs,
  getInputs = getInputs,
  getMixers = getMixers,
  getLogicalSwitches = getLogicalSwitches,
  genOptions = genOptions,
  genChannelList = genChannelList,
  genSwitchPositionList = genSwitchPositionList,
 
}