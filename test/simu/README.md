# simu-cli 测试

在仓库根的 `simu-cli`（Zorro）里跑 Lua。所有用例共用遥测脚本 [SCRIPTS/TELEMETRY/simt.lua](../../SCRIPTS/TELEMETRY/simt.lua)，不要再为每个测试加一个遥测脚本。

界面操作要走模拟器按键，不要在 Lua 里直接调用 `doKey`。参照 [test_numedit.py](test_numedit.py) 和 [cases/testNumEditO.lua](cases/testNumEditO.lua)。

`SCRIPTS/TELEMETRY/utO.lua` 仍是遥控器上的 `emutest/` 批跑，不走这条入口。

## 运行

在仓库根目录：

```bash
python3 test/simu/run.py
python3 test/simu/run.py --screen
```

`--screen` 打开 LCD 窗口，测试结束窗口会关。`run.py` 会执行 `test/simu/test_*.py` 里所有 `test_*` 函数，并传入 `screen=`。函数必须接受这个参数。

日志里出现 `-E-`、`Error loading script`、`Error parsing script` 或 `[ERR]` 即失败。

需要本机有可执行的 `./simu-cli`。`--screen` 还需要 SDL2。取得程序的方式见 [edgetx/docs/simu-cli.md](../../edgetx/docs/simu-cli.md)。

## 一次会话里发生什么

[harness.py](harness.py) 的 `session()` 启动模拟器，SD 是临时目录：

- 拷入 `SCRIPTS/`、`LAOZHU/`
- 把 `test/simu/cases/` 拷到临时 SD 的 `SCRIPTS/simu/`

`test/simu/` 不会被安装脚本拷到遥控器。`simt.lua` 在 `SCRIPTS/TELEMETRY/` 里，安装后遥测列表能看到它；没有 `simu.case` 时打开会报错，这是给模拟器准备的入口。

Python 把用例文件名写进 `SCRIPTS/simu.case`（一行，不超过 200 字节），再 `show_telemetry("simt")`。`simt` 加载 `SCRIPTS/simu/<文件名>`。`gSDCardDir` 为 `"/"`，`DBG` 已初始化且 `DEBUG_LOG` 打开，用例里可以直接 `DBG_dbg` / `DBG_err`，也可以 `LZ_runModule`。

断言用 `assert` 或 `error`。`simt` 会先 `DBG_err`（日志里带 `[ERR]`）再把错误抛出去。

## 两种用例

### 批量：init 里跑完

不需要按键时用。Lua `return` 一个函数，或非空函数列表。`simt` 在 `init` 里依次调用，成功后打印 `[DBG] simu ok`。

```lua
local function testSomething()
	LZ_runModule(gSDCardDir .. "LAOZHU/....lua")
	assert(1 + 1 == 2, "add")
end

return {testSomething}
```

```python
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))

import harness


def test_something(screen=False):
    with harness.session(screen=screen) as sim:
        harness.run_case(sim, "testSomething.lua")
```

### 按键：run(event) 接收固件事件

要模拟遥控器操作时用。Lua `return { init = ..., run = ... }`。`init` 搭好页面，`run` 收到的是固件原始事件。成功打开后日志里有 `[DBG] simu ready`，没有自动的 `simu ok`，结果由 Python 看后续日志。

页面侧和真机一样：先用 [LAOZHU/uilib/keyMap.lua](../../LAOZHU/uilib/keyMap.lua) 把原始事件映成目标事件，再交给 `ViewMatrix`。`SCRIPTS/keymap.cfg` 存在时只用这份配置，不走 `keyMap.lua` 里的内置表。

```lua
local function init()
	LZ_runModule(gSDCardDir .. "LAOZHU/CfgO.lua")
	LZ_runModule(gSDCardDir .. "LAOZHU/uilib/keyMap.lua")
	keyMap = KMgetKeyMap()
	KMunload()
	-- 搭页面，必要时 DBG_dbg 打出初始状态
end

local function run(event)
	if event ~= nil and event ~= 0 then
		local mapped = keyMap[event] or event
		-- 把 mapped 交给页面
	end
end

return {init = init, run = run}
```

```python
def test_page(screen=False):
    with harness.session(screen=screen) as sim:
        harness.open_case(sim, "testPage.lua")
        sim.key("ENTER", "click")
        harness.expect_log(sim, "[DBG] editing")
        sim.wait(80)
```

`key()` 返回时，对应的 `DBG_dbg` 可能还没进日志。用 `harness.expect_log(sim, text)` 等，不要认为 `log_since()` 立刻就能看到。按键之间加 `sim.wait(80)`：模拟器时间只在 `wait` 这类命令里往前走，两条滚轮指令贴得太近时第二条会丢。

`harness.hold_key(sim, name)` 是按下、`wait(800)`、再松开，用来产生长按。长按期间会有多条事件，松手后还会再来一次单击。等它停稳再用 `sim.wait` 后 `log_since()`，看最后一条状态，不要只等第一条匹配。

长按 `SYS`、`MODEL`、`PAGE` 会离开遥测脚本，后面的按键不再进用例。

## 当前 Zorro 模拟器的按键

测到的固件是 `getVersion()` 为 `3.0.0` / `zorro-simu`。`help` 里的键名是 `EXIT`、`ENTER`、`PAGEUP`、`PAGEDN`、`PAGE`、`MODEL`、`TELE`、`SYS`，没有名叫 `UP` 的键。下表是单击松手时、经当前 [SCRIPTS/keymap.cfg](../../SCRIPTS/keymap.cfg) 之后的结果。固件或这份 cfg 改了就要重测，不能沿用旧表。

| 操作 | 松手后的原始事件 | 映射后 | 在编辑中的 NumEdit 上 |
| --- | --- | --- | --- |
| `ENTER` 单击 | 34（`EVT_ENTER_BREAK`） | 34 | 进入或退出编辑 |
| `MODEL` 单击 | 43 | 36 | 加一步 |
| `TELE` 单击 | 44 | 35 | 减一步 |
| `PAGEUP` 单击 | 35 | 38 | 减一步 |
| `PAGEDN` 单击 | 36 | 37 | 加一步 |
| `PAGE` 单击 | 36 | 37 | 与 `PAGEDN` 相同 |
| `encoder(-1)` | 4099 | 36 | 加一步 |
| `encoder(1)` | 4100 | 35 | 减一步 |
| `EXIT` 单击 | 33（`EVT_EXIT_BREAK`） | 33 | 退出编辑 |
| 长按 `TELE` | 76，随后松手还有 44 | 67，然后 35 | 减十步，松手再减一步 |
| 长按 `PAGEDN` | 68（cfg 未映射，原值进入控件），随后松手还有 36 | 68，然后 37 | 加十步，松手再加一步 |

单击时往往先来一个未映射的按下事件（例如 `MODEL` 的 107），控件会忽略，真正起作用的是上表里的松手事件。

`ViewMatrix` 没进入编辑时，方向键用来移动焦点，不会改 `NumEdit`。进入编辑后这些键才交给 `NumEdit`。`NumEdit` 的上下限判断是 `if self.min and ...`，`min` 或 `max` 为 0 时不会钳位。

## 新增一个测试

1. 在 `test/simu/cases/` 加 Lua。需要按键就用 `init`/`run`，否则 `return {测试函数}`。
2. 在 `test/simu/test_<名字>.py` 加 `test_<名字>(screen=False)`，里面 `harness.session` 后调用 `run_case` 或 `open_case`。
3. 在仓库根执行 `python3 test/simu/run.py`。要看画面就加 `--screen`。
