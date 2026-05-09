# TELEMETRY common UI 实现约定（组件作者）

写给**新增或修改** `SCRIPTS/TELEMETRY/common` 下控件（及功能目录内同源控件，如部分 `TaskSelector`）的实现者：**如何把模块挂到 `_G`、如何保证可被干净卸掉**。页面如何装载与调用见 **[UI_COMPONENT_USAGE.md](UI_COMPONENT_USAGE.md)**。

## 命名与语义：`O` 后缀

- 文件名以 **`O` 结尾**（如 `ButtonO.lua`）表示**该控件的面向对象实现变体**。
- 与同基名、无 `O` 的模块（如 `Button.lua`）在**业务逻辑上应对齐**；差别主要在 **API 形态**（全局函数 + 工厂 vs 全局类表 + `:new()`）以及**调用方在 `destroy` 里的释放方式**（`XXunload` vs 全局类 **`= nil`**）。
- **`O` 不是彩屏专版**；不与显示类型绑定。

若**同时维护**函数式与 `O` 两版，功能或交互变更应 **两处同步或对齐**，避免行为分叉。

## 函数式模块（无前缀文件名如 `Button.lua`）

### 全局命名

- 对外 API 建议使用统一 **两字母前缀**，与现有模块一致：`BT`、`VM`、`TE`、`IV`、`NE`…

### `XXunload()`

- 每个函数式控件模块须提供 **`XXunload()`**。
- 在 `XXunload` 中将本文件置入 **`_G` 的全部相关符号**置 **`nil`**，包括：`doKey`/`draw`、`XXnew*`、辅助全局函数以及 **`XXunload` 自身**，避免卸载后仍可被误调用。

调用方对称性由 **[UI_COMPONENT_USAGE.md](UI_COMPONENT_USAGE.md)** 约束；组件侧必须保证 `unload` 完整、可重复加载。

### `local` 与闭包（简要）

- `unload` 的首要目标是摘掉 **`_G` 导出**。若仍存在由全局函数引用的 **`local`** 大块闭包，应通过先清空仍引用它们的**全局入口**，再配合 GC（不在此展开 Lua 细节）。

### 自检思路

- 可参考 `TELEMETRY/ut.lua` 中 **`testLoadAndUnload`**：单次流程内 **载入 → `XXunload` → 再载入**，用于发现残留全局或未清符号。

## `O` 变体模块（`*O.lua`）

- 类型一般挂在 **`_G`**（如全局 `InputView`、`Button`），并可能通过 `setmetatable` 继承。
- **加载顺序**：先基类后子类（与现有页面的 `LZ_runModule` 顺序一致）。
- **卸载**：通常 **不**在本文件内实现 `FooOunload`；由**页面 `destroy`** 按实际加载过的类 **`类名 = nil`**。参见 `RoundSetupPage.lua`、`FlightPageNew.lua` 等。
- 若新增 `O` 变体页面，须在 `destroy` 中列入**每一个**本会加载到的全局类，避免残留在 `_G`。

## Fields、keyMap 等与「控件」同属一类目标

实现或扩展类似 **`Fields`**（`initFieldsInfo` / `FieldsUnload`）、**`keyMap`**（`KMgetKeyMap` / `KMunload`）的通用模块时，同样遵循：**成对暴露初始化与卸载**，并让调用文档化在 **USAGE** 一侧。
