-- 辅助函数：查找逻辑开关索引
function getLogicalSwitchIndex(LogicalSwitches, lsName)
  for i = 1, #LogicalSwitches do
    if LogicalSwitches[i].name == lsName then
      return getSwitchIndex(LogicalSwitches[i].key)
    end
  end
  return nil
end
-- 辅助函数：检查通道是否存在
function hasChannel(channelList, channelName)
  for i = 1, #channelList do
    if channelList[i] == channelName then
      return true
    end
  end
  return false
end

-- 辅助函数：查找全局变量索引
function getGVIndex(GVs, gvName)
  for i = 1, #GVs do
    if GVs[i].name == gvName then
      return GVs[i].index
    end
  end
  return nil
end

function getInputIndex(inputs, inputName)
  for i = 1, #inputs do
    if inputs[i].name == inputName then
      return inputs[i].index
    end
  end
  return nil
end

-- 辅助函数：根据舵面名称查找对应的输出通道索引（0-based）
function getOutputIndex(pinToChannelMap, channelName)
  for pinNum = 1, 8 do
    if pinToChannelMap[pinNum] == channelName then
      return pinNum - 1  -- 转换为 0-based 索引
    end
  end
  return nil
end