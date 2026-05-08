# CLAUDE.md

此文件为 Claude Code (claude.ai/code) 在此代码库中工作时提供指导。

## 项目概述

EdgeTX/OpenTX 遥控器脚本，用于 F3K（手抛滑翔机）和 F5J（电动滑翔机）比赛和训练辅助。该项目提供飞行数据记录、遥测显示和飞机调整工具，运行在搭载 EdgeTX 固件的遥控器上。

## 开发命令

### 安装和构建
- `install.bat [盘符:]` - 将脚本安装到遥控器SD卡（Windows）
- `./install_mac.sh [/Volumes/SD名]` - 将脚本安装到遥控器SD卡（macOS，挂载根目录下需有或自动创建 `SCRIPTS`）
- `build_sound_dll.bat` - 构建 Windows 声音库用于测试
- `build_sound_so.sh` - 构建 Linux 声音库用于测试

### 编译
- `cd SCRIPTS && lua GenCompileList.lua` - 生成编译文件列表（需 Lua 与 [LuaFileSystem](https://keplerproject.github.io/luafilesystem/) `lfs` 模块；会扫描 `../LAOZHU` 并输出 `LAOZHU/...` 条目）
- 脚本在遥控器首次运行时自动编译
- 当遥控器检测到缺失 .luac 文件时进行编译

### 测试
- **开发机 / CI**：在仓库根目录执行 `lua test/test.lua`（单元测试）；CI 在推送/PR 到 master 时通过 GitHub Actions 运行
- **macOS**：安装 LuaRocks 后执行 `luarocks install luaunit lua-mock`（与 CI 一致），再在仓库根执行 `./run_tests.sh`；脚本会调用 `luarocks path` 注入 `LUA_PATH`/`LUA_CPATH`，并用仓库内 [tools/lua/5.2.2](tools/lua/5.2.2/README.md) 的 Lua 5.2.2 与 CI 对齐
- **模拟器 / 遥控器（黑白屏）**：自动化测试入口为遥测脚本 `SCRIPTS/TELEMETRY/utO.lua`，用例脚本位于 `SCRIPTS/emutest/`
- **彩屏 WIDGET**：在 App 布局下添加 `WIDGETS/LzUtO` widget，与 `utO.lua` 相同批跑 `emutest/` 并可在跑完后演练 ViewMatrix 控件（需长按 ENT 交权后按键才生效）

## 架构

### 核心目录结构

仓库根目录与 SD 卡一致：**`SCRIPTS/`**（遥测脚本、`emutest/` 等）、**`LAOZHU/`**（核心库）、**`WIDGETS/`**（彩屏 widget）与 **`test/`**（开发机单元测试源码；安装到 SD 时为 `SCRIPTS/test/`）并列；SD 卡上亦为 `SCRIPTS`、`LAOZHU`、`WIDGETS` 同级。

**LAOZHU/** - 核心功能模块（业务逻辑，与 `SCRIPTS/` 同级；脚本路径以 **`gSDCardDir`** 为 SD 卡根目录：`/`（真机/模拟器）或 `./`（本机跑 `test/test.lua`），`LZ_runModule` 将 `LAOZHU/...` 解析为 `gSDCardDir .. "LAOZHU/..."`，其余相对路径解析为 `gSDCardDir .. "SCRIPTS/..."`）
- 状态管理类（F3kState.lua, F5jState.lua, SinkRateState.lua）
- 数据记录（F3kFlightRecord.lua, SinkRateRecord.lua, launchRecord.lua）
- 工作流实现（F3kWF/ 子目录）
- 工具函数（OTUtils.lua, LuaUtils.lua）
- 通用模块（comm/ 子目录）

**TELEMETRY/** - 用户界面层（位于 `SCRIPTS/` 下）
- 主入口点：3ktel.lua（F3K）、5jtel.lua（F5J）、adjust.lua（调整工具）
- UI 页面按功能组织（3k/, 5j/, adjust/, common/）
- 通用 UI 组件在 common/ 目录

**data/** - 飞行数据存储
**test/** - 单元测试（仓库根目录，`SCRIPTS` 与 `WIDGETS` 共用逻辑的开发机测试）
**emutest/** - 模拟器/真机自动化用例（位于 `SCRIPTS/` 下，由 `TELEMETRY/utO.lua` 或彩屏 `WIDGETS/LzUtO` 加载）
**WIDGETS/** - 彩屏 Lua widget（SD 卡根目录下 `WIDGETS/`，与 `SCRIPTS` 同级）

### 模块加载系统

入口脚本须先设置全局 **`gSDCardDir`**（SD 根：`"/"` 或测试时 `"./"`），再加载 `SCRIPTS/TELEMETRY/common/LoadModule.lua`。使用自定义模块加载器：
```lua
LZ_runModule("LAOZHU/OTUtils.lua")   -- → gSDCardDir .. "LAOZHU/OTUtils.lua"
LZ_runModule("TELEMETRY/common/Fields.lua") -- → gSDCardDir .. "SCRIPTS/TELEMETRY/common/Fields.lua"
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

- `test/` 目录下的单元测试使用自定义测试框架；开发机与 CI 上运行 `lua test/test.lua`
- 模拟器或真机（黑白屏）上运行 `SCRIPTS/TELEMETRY/utO.lua` 执行 `emutest/` 中的自动化用例
- 彩屏上安装 `WIDGETS/LzUtO` 后可在主屏/App 中执行同一批 `emutest/` 用例（见上文「彩屏 WIDGET」）
- CI 在 Ubuntu 上使用 Lua 5.2.2 运行测试
- 功能与 UI 仍建议在真实 EdgeTX 硬件或模拟器上手动验证