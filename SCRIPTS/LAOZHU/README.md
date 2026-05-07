# LAOZHU 目录说明

## 概述

LAOZHU目录包含EdgeTX/OpenTX遥控器脚本的核心功能实现。该目录中的模块提供了底层功能支持，被TELEMETRY目录中的界面脚本调用。主要支持F3K（手抛模型飞机）和F5J（电动滑翔机）比赛和训练功能，以及各种调机工具的核心算法实现。

## 目录结构

```
LAOZHU/
├── comm/           - 通用和系统相关功能
├── F3k/            - F3K核心功能实现
├── F3kWF/          - F3K工作流相关功能
├── *.lua           - 各种核心功能模块
└── *.luac          - 编译后的Lua字节码文件
```

## 主要功能模块

### 0. 主目录下文件

#### 基础和通用方法
- `Cfg.lua` / `CfgO.lua` - 配置文件读写功能
- `DataFileDecode.lua` - 飞行数据文件解码功能
- `EmuTestUtils.lua` - 模拟或真机测试工具函数
- `LuaUtils.lua` - Lua通用工具函数
- `OTUtils.lua` - OpenTX/EdgeTX工具函数集，提供时间格式化、遥测ID获取、遥控器全局变量操作等功能
- `Queue.lua` - 队列数据结构实现
- `SwitchTrigeDetector.lua` - 开关触发检测器

#### F5J相关基础和通用方法
- `f5jReadVarMap.lua` - F5J变量映射，用于语音播报F5J飞行数据
- `f5jState.lua` - F5J飞行状态管理

#### 起飞相关基础和通用方法
- `launchReadVarMap.lua` - 起飞参数变量映射，用于语音播报起飞参数
- `launchRecord.lua` - 起飞/发射数据记录

#### 升力阻力比相关基础和通用方法
- `LDReadVarMap.lua` - 升力阻力比变量映射，用于语音播报升力阻力比
- `LDRecord.lua` - 升力阻力比数据记录
- `LDState.lua` - 升力阻力比状态管理

#### 基础飞行数据监控
- `Monitor.lua` - 飞行数据监控功能
- `readVar.lua` - 播报功能
- `Sensor.lua` - 传感器数据规则监控

#### 下沉率相关基础和通用方法
- `SinkRateLog.lua` - 下沉率日志记录(暂未使用)
- `SinkRateReadVarMap.lua` - 下沉率变量映射，用于语音播报下沉率
- `SinkRateRecord.lua` - 下沉率数据记录
- `SinkRateState.lua` - 下沉率状态管理


### 1. comm目录文件
- `LinuxSound.lua` - Linux平台声音功能（用于模拟测试）
- `PCIO.lua` - PC文件读写功能（用于模拟测试）
- `PCLoadModule.lua` - PC端模块加载器（用于模拟测试）
- `TestSound.lua` - 测试声音功能（用于模拟测试）
- `OTSound.lua` - OpenTX/EdgeTX声音功能
- `Timer.lua` - 计时器功能实现

### 2. F3k目录文件
- `F3kState.lua` - F3K飞行状态管理
- `F3kFlightRecord.lua` - F3K飞行记录功能
- `f3kReadVarMap.lua` - F3K变量映射，用于语音播报F3K飞行数据

### 3. F3kWF目录文件
- `F3kRoundWF.lua` - F3K比赛轮次工作流
- `AULDWF.lua` - 同时起飞最后降落工作流
- `CommonTaskWF.lua` - 通用任务工作流
- `F3kCompetitionWF.lua` - F3K比赛工作流（之前用于F3K比赛组织，单人飞行时不需要，暂时未使用）

## 使用方法

LAOZHU目录中的模块通常不直接使用，而是被TELEMETRY目录中的界面脚本调用。这些模块提供了核心算法和状态管理功能，由界面脚本通过模块加载机制加载使用。

主要加载方式：
```lua
-- 在界面脚本中加载LAOZHU模块的示例
LZ_runModule("LAOZHU/LuaUtils.lua")
LZ_runModule("LAOZHU/OTUtils.lua")
gF3kCore = LZ_runModule("LAOZHU/F3k/F3kState.lua")
```

## 开发说明

- 模块设计采用函数式和面向对象混合风格，面向对象逻辑清晰，函数式在内存使用管理上更可控。
- 各模块间通过加载器(LZ_runModule)进行依赖管理