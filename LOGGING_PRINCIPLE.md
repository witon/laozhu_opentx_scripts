# 遥控器脚本日志原则（必须遵守）

本文约定与实现以 [`LAOZHU/DBGTools/dbg.lua`](LAOZHU/DBGTools/dbg.lua) 为准。新代码、重构与排障输出须按级别选用 API，不得在业务层随意混用无分级 `print`。

---

## 1. 两级语义

| 级别 | API | 典型用途 |
|------|-----|----------|
| **错误** | `DBG_err(...)` | 加载失败、断言失败、异常分支、无法继续或结果明显错误时须让人看见的信息 |
| **调试** | `DBG_dbg(...)` | 按键/trace、用例进度、周期性状态、开发期排查信息 |

- **不要**把「可忽略的流水账」打成错误级；**不要**把真正的失败仅用调试级埋没（尤其在默认关闭 `DEBUG_LOG` 的场景）。

---

## 2. 开关约定（全局表 `DBG`）

- **`ERROR_LOG`**：控制 `DBG_err`。库默认 **`true`**（错误默认可见）。
- **`DEBUG_LOG`**：控制 `DBG_dbg`。库默认 **`false`**（调试默认安静；入口脚本通过 `DBG_init` 按需打开）。
- **`SHOW_LOG_SCREEN`**：为真且调用对应级别的函数未被开关短路时，该行写入环形缓冲 **`DBG.logHistory`**，供 Widget 覆盖层（如 [`DBGWidgetLog.lua`](LAOZHU/DBGTools/DBGWidgetLog.lua)）绘制。
- **`printTag`**：控制台 `print` 的第一个字段，用于区分来源（如 `[utO]`、`[LzUtO]`）。

实现会自动为每条消息加上 **`[ERR]`** / **`[DBG]`** 前缀；**调用处不要再手写这两个前缀**，以免重复。

---

## 3. 初始化顺序（Widget / 已接入 DBG 的遥测脚本）

1. 设置 `gSDCardDir`（若尚未设置）。
2. `LZ_runModule(... "LAOZHU/DBGTools/dbg.lua")`
3. `DBG_init(opts)`：`ERROR_LOG`、`DEBUG_LOG`、`SHOW_LOG_SCREEN`、`LOG_MAX`、`printTag` 等与入口约定一致。
4. 若需在 Widget 上绘制日志：`LZ_runModule(... "LAOZHU/DBGTools/DBGWidgetLog.lua")`。

不要在未加载 `dbg.lua` 之前调用 `DBG_err` / `DBG_dbg`。

---

## 4. 引导失败路径（dbg 尚未加载）

在 **`LoadModule.lua` 成功加载之前**无法使用 `DBG_*`。此处允许使用 **`print`**（例如 `LoadModule FAIL`），**不要**为解决这一条路径而打乱模块加载顺序或虚假的「提前 DBG」。

---

## 5. 调用风格

- **不要在调用点前再判断 `DBG.DEBUG_LOG` / `DBG.ERROR_LOG`**：`DBG_err` / `DBG_dbg` 内部已处理；重复判断增加噪音与分叉。
- 模块加载失败若在 **`DBG_init` 之后**（例如 `LZ_runModule` 返回 `nil`）：应打 **`DBG_err`**，并仍可保留底层 `print`（若已有），但分级信息以 `DBG_err` 为准。
- **`LZ_runModule` / `LZ_loadModule` 内部**仍会 `print(err)`；在未全局接入 `DBG` 前不要随意改为 `DBG_err`，除非已保证所有调用方都已初始化 DBG（见仓库历史决策：LoadModule 保持 `print`）。

---

## 6. 遥测与单元测试

- **黑白屏**：[`DBGTelemetryLog.lua`](LAOZHU/DBGTools/DBGTelemetryLog.lua) 为占位；写入规则与 Widget 侧一致（读 `DBG.logHistory`，行内混排 `[ERR]`/`[DBG]`）。
- **开发机 / `test/test.lua`**：`DBG_err` / `DBG_dbg` 本身只用到标准 Lua 的 `print`，在 PC 上**可以**正常运行；若在测试前先 `require`/加载 [`dbg.lua`](LAOZHU/DBGTools/dbg.lua) 并视需要 `DBG_init`，在生产代码路径里照常写 `DBG_*` 没有问题。
- **不要误解为「单元测试禁止使用 `DBG_*`」**。本条强调的是两件事：
  1. **可运行性**：被测模块若调用了 `DBG_*`，测试夹具要么加载 `dbg.lua`（或与之一致的桩），要么通过桩/mock 提供同名全局函数；**不要假定**不写任何初始化也能在孤立跑单测时永远不踩到未定义的 `DBG_err`/`DBG_dbg`。
  2. **契约**：单元测试应以返回值、状态和纯函数行为为断言依据，**不要**把「是否打出某条日志」「控制台是否含某字符串」当作主要通过条件；核心业务里也不要把 `print`/`DBG_*` 当作唯一可见的「契约」而放弃可测的状态或错误码。

---

## 7. 自检清单（提交前）

- [ ] 失败/异常路径是否使用 `DBG_err`？
- [ ] 排查用流水是否使用 `DBG_dbg`，且不会在默认 `DEBUG_LOG=false` 时误报为错误？
- [ ] 是否避免在消息字符串中重复 `[ERR]`/`[DBG]`？
- [ ] Widget/入口是否已 `DBG_init`，且 `printTag` 便于在控制台区分来源？
