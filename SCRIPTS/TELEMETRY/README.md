# TELEMETRY 目录说明

## 概述

TELEMETRY目录包含EdgeTX/OpenTX遥控器上运行的遥测和飞行辅助脚本。这些脚本主要为F3K（手抛模型飞机）和F5J（电动滑翔机）比赛和训练提供辅助功能，同时还包含调机工具。

## 目录结构

```
TELEMETRY/
├── common/        - 公共组件和工具
├── 3k/            - F3K相关页面和功能
├── 5j/            - F5J相关页面和功能
├── adjust/        - 调机工具相关功能
├── 3ktel.lua      - F3K主入口脚本
├── 5jtel.lua      - F5J主入口脚本
├── adjust.lua     - 调机工具主入口脚本
└── [其他工具脚本]
```

## 主要功能模块

### 1. F3K飞行辅助 (3ktel.lua 和 3k/ 目录)

F3K手抛模型飞机比赛和训练辅助脚本，主要功能包括：

- 飞行时间记录和管理
- 比赛轮次设置
- 任务选择和管理
- 飞行数据显示和统计

关键文件：
- `3ktel.lua` - F3K功能主入口
- `3k/f3kCore.lua` - F3K核心功能实现
- `3k/FlightPage.lua` - 飞行信息页面
- `3k/SetupPage.lua` - 设置页面

### 2. F5J飞行辅助 (5jtel.lua 和 5j/ 目录)

F5J电动滑翔机比赛和训练辅助脚本，主要功能包括：

- 飞行状态监控
- 高度记录和报告
- 电机运行时间管理
- 飞行数据显示

关键文件：
- `5jtel.lua` - F5J功能主入口
- `5j/FlightPage.lua` - 飞行信息页面
- `5j/SetupPage.lua` - 设置页面

### 3. 调机工具 (adjust.lua 和 adjust/ 目录)

提供各种调机辅助功能，包括：

- 全局变量调整
- 输出通道调整（舵机行程和一致性）
- 下沉率调整
- 升力阻力比(LD)调整
- 发射高度调整

关键文件：
- `adjust.lua` - 调机工具主入口
- `adjust/GlobalVar.lua` - 全局变量调整功能
- `adjust/Output.lua` - 输出通道调整功能
- `adjust/SinkRate/` - 下沉率调整相关功能
- `adjust/LD/` - 升力阻力比调整功能
- `adjust/Launch/` - 发射高度调整功能

### 4. 公共组件 (common/ 目录)

提供各种UI组件和工具函数，供所有功能模块使用：

- `LoadModule.lua` - 模块加载器
- `keyMap.lua` - 按键映射功能
- 各种UI控件（NumEdit, TextEdit, Selector等）
- `comp.lua` - 编译功能
- `Fields.lua` - 字段相关功能