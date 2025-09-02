# CLAUDE.md

此文件为 Claude Code (claude.ai/code) 在此代码库中工作时提供指导。

## 项目概述

EdgeTX/OpenTX 遥控器脚本，用于 F3K（手抛滑翔机）和 F5J（电动滑翔机）比赛和训练辅助。该项目提供飞行数据记录、遥测显示和飞机调整工具，运行在搭载 EdgeTX 固件的遥控器上。

## 开发命令

### 安装和构建
- `install.bat [盘符:]` - 将脚本安装到遥控器SD卡（Windows）
- `build_sound_dll.bat` - 构建 Windows 声音库用于测试
- `build_sound_so.sh` - 构建 Linux 声音库用于测试

### 编译
- `lua GenCompileList.lua` - 生成编译文件列表
- 脚本在遥控器首次运行时自动编译
- 当遥控器检测到缺失 .luac 文件时进行编译

### 测试
- `lua test/test.lua` - 运行单元测试
- `emutest/` 目录下的自动化测试用于遥控器/模拟器测试
- CI 通过 GitHub Actions 在推送/PR 到 master 时运行测试

## 架构

### 核心目录结构

**LAOZHU/** - 核心功能模块（业务逻辑）
- 状态管理类（F3kState.lua, F5jState.lua, SinkRateState.lua）
- 数据记录（F3kFlightRecord.lua, SinkRateRecord.lua, launchRecord.lua）
- 工作流实现（F3kWF/ 子目录）
- 工具函数（OTUtils.lua, LuaUtils.lua）
- 通用模块（comm/ 子目录）

**TELEMETRY/** - 用户界面层
- 主入口点：3ktel.lua（F3K）、5jtel.lua（F5J）、adjust.lua（调整工具）
- UI 页面按功能组织（3k/, 5j/, adjust/, common/）
- 通用 UI 组件在 common/ 目录

**data/** - 飞行数据存储
**test/** - 单元测试
**emutest/** - 遥控器/模拟器集成测试

### 模块加载系统

使用自定义模块加载器，带缓存：
```lua
LZ_runModule("path/to/module.lua")  -- 加载并执行模块
LZ_loadModule("path/to/module.lua") -- 仅加载模块函数
```

脚本在首次运行时自动将 .lua 编译为 .luac 以提升性能。

### 关键配置文件

- `3k.cfg`, `5j.cfg` - F3K/F5J 功能的用户设置
- `launch.cfg`, `sinkrate.cfg`, `ld.cfg` - 调整工具的设置
- 配置通过 Cfg.lua/CfgO.lua 模块管理

## 开发说明

- 代码使用混合函数式/面向对象风格 - 面向对象提供清晰度，函数式用于内存控制
- 针对资源受限的遥控器环境设计
- 所有界面文本为中文（目标市场）
- 脚本必须与 EdgeTX Lua API 兼容
- 由于遥控器限制，内存管理至关重要
- 通过自定义 C++ 库（competition_lib/）提供声音反馈

## 测试方法

- test/ 目录下的单元测试使用自定义测试框架
- emutest/ 中的集成测试用于遥控器特定测试
- CI 在 Ubuntu 上使用 Lua 5.2.2 运行测试
- 需要在真实的 EdgeTX 硬件/模拟器上进行手动测试