# LAOZHU/uilib UI 使用约定（调用侧）

写给**页面与功能编排代码**的作者：`LAOZHU/uilib` 里的控件如何通过 `LZ_runModule` 接入，以及离开时如何对称释放。**不要**在未加载对应模块时使用其全局符号；**不要**在本页已不再需要时把导出长期留在 `_G`。

更细的语义与实现要求（`*O.lua`、两字母前缀、`XXunload` 怎么写）见 **[UI_COMPONENT_IMPLEMENTATION.md](UI_COMPONENT_IMPLEMENTATION.md)**。

## 原则

1. **只加载当前页或当前子场景需要的模块**——在页面顶层或与该场景绑定的局部 `loadModule` 里调用 `LZ_runModule(gSDCardDir .. "LAOZHU/uilib/....lua")`（路径以仓库内实际为准），勿预加载本页不用的控件。
2. **离开时必须对称卸载**：谁加载了、谁就要在离开时释放挂到 `_G` 的那部分。**函数式**组件在页面的 `destroy`（或等价卸载钩子）里调用各 **`XXunload()``**；加载了 **`O` 变体**的模块时，在同一个 `destroy` 里把对应的**全局类表**逐项置 `nil`（与本页 `LZ_runModule` 过哪些文件一致）。
3. **服从入口生命周期**：典型遥测入口在换页前会调用 `curPage.destroy`（若存在），再 `LZ_clearTable(curPage)`、`collectgarbage()`（例如 `3ktel.lua`）。页面侧的 `destroy` 必须在此前把 uilib 导出清干净。

```mermaid
flowchart LR
  telEntry[tel入口如3ktel]
  page[页面lua]
  common[uilib组件lua]
  telEntry -->|loadPage LZ_runModule| page
  page -->|按需 LZ_runModule| common
  telEntry -->|unloadCurPage| destroy[destroy可选]
  destroy -->|函数式 XXunload 或 OO 类表=nil| gc[LZ_clearTable collectgarbage]
```

## 载入与离开时要做什么（速查）

| 你使用的形态 | 载入后如何使用 | 在页面 `destroy`（或局部 `unload`）里 |
|----|----|----|
| 函数式 uilib（如 `Button.lua`） | `LZ_runModule` 后用 `BTnewButton` 等与该模块一致的 API | 依次调用 **`XXunload()`**（与本页加载的模块列表一致）；注意依赖顺序，必要时与加载顺序对称 |
| `O` 变体（如 `ButtonO.lua`） | `LZ_runModule` 后用 `Button:new()` 等全局类 API | 将本页引入的**全局类名**逐项 **`= nil`**（与 `LZ_runModule` 的 OO 模块一致）；**勿依赖**单独的 `FooOunload`——通常不存在 |

`*O.lua` **不是「彩屏专版」**，只是面向对象实现；与同基名的无 `O` 模块应逻辑对齐。选用哪套由存量页面与约定决定。

## `Fields.lua`（调用侧）

若本页 **`LZ_runModule` 了 Fields** 并调用了 **`initFieldsInfo()`**，在 **`destroy` 里必须调用 `FieldsUnload()`**。参考 `3k/SetupPage.lua`。

## `keyMap.lua`（调用侧）

载入后 **`KMgetKeyMap()`** 取得映射表即可，随后立即 **`KMunload()`**，避免把按键模块的导出长期留在 `_G`。

## `UiParams.lua` — 全局 `LZ_ui`

统一 **`font`**、**`fontSmall`**、**`rowStep`**、**`headerFont`**、彩屏 **`themeText`**（与 `LEFT`/`RIGHT`/`INVERS` 等相加；用法同原先的 `SMLSIZE + LEFT`）。

| 载入侧 | 说明 |
|--------|------|
| 初始化 | 由 **[LoadModule.lua](LoadModule.lua)** 在末尾加载 `UiParams` 并 **`LZ_uiInit(LZ_uiInitMode)`**。预设 **`mode`** 为字符串（可并列扩展）：**`"bw"`** 黑白套；**`"color1"`** 彩屏第一套。**在 **`loadScript(LoadModule)`** 之前可设 **`LZ_uiInitMode = "bw"`** 或 **`"color1"`**；若为 **`nil`** 或未识别字符串，则按是否存在 **`lcd.sizeText`** 自动选 **`"color1"`** 或 **`"bw"`**。亦可事后 **`LZ_uiInit(...)`** 覆盖。**页面与各 UI 控件不要**单独 `LZ_runModule UiParams`。 |
| 使用 | 绘制处直接使用 **`LZ_ui.font`**、**`LZ_ui.rowStep`** 等。 |
| 离开 | 按需 **`LZ_uiUnload()`**（一般会话级常驻即可）。 |

若 `UiParams` 未执行（极少数未走 LoadModule 的宿主），`LZ_ui` 可能未定义；正常运行路径均会先执行 LoadModule。

## 子场景内多次进入/退出

同一功能里若有一组 uilib 只在某子界面需要，可用局部 **`loadModule` / `unloadModule`**：`unload` 里集中调用若干个 **`XXunload()`**（及必要的类表清空）。示例：`adjust/output.lua`。

## 页面作者自检

- [ ] `LZ_runModule` 列表仅包含本页/本子场景需要的 uilib。
- [ ] **`destroy`**（或等价钩子）中与载入对称：**`XXunload`**、`FieldsUnload`（若用过 Fields）、`**O`** 相关的全局类 **`= nil`**。
- [ ] 确认所属遥测入口在换页时会调 **`destroy`** 并 **`LZ_clearTable` + `collectgarbage`**（按该入口惯例）。
