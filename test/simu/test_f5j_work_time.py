"""从 5jtel 进设置页，把工作时间从 10 分钟改成 11 分钟，飞行页 WT 变为 660 秒。"""

import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))

import harness

KEY_UP = "MODEL"
KEY_DOWN = "TELE"
STEP_MS = 1000


def _prepare(sim):
    scripts = Path(sim.storage) / "SCRIPTS"
    (scripts / "lzinstall.flag").write_text("inited", encoding="utf-8")
    cfg = scripts / "5j.cfg"
    if cfg.exists():
        cfg.unlink()


def _last_wt(lines):
    found = None
    for line in lines:
        mark = "[DBG] wt "
        i = line.find(mark)
        if i >= 0:
            found = int(line[i + len(mark):].split()[0])
    return found


def _pause(sim):
    sim.wait(STEP_MS)


def _click(sim, key):
    sim.key(key, "click")
    _pause(sim)


def _assert_clean(lines, label):
    text = "\n".join(lines)
    if any(mark in text for mark in ("-E-", "Error loading script", "Error parsing script", "[ERR]")):
        raise AssertionError("%s 失败\n%s" % (label, text))


def test_f5j_work_time(screen=False):
    with harness.session(screen=screen) as sim:
        _prepare(sim)
        sim.show_telemetry("5jtel", timeout=60000)
        opened = sim.log_since()
        _assert_clean(opened, "打开 5jtel")
        if _last_wt(opened) != 600:
            raise AssertionError("初始工作时间不对\n%s" % "\n".join(opened))
        _pause(sim)

        harness.hold_key(sim, "PAGEDN")
        _pause(sim)
        entered = sim.log_since()
        _assert_clean(entered, "进入设置")

        for _ in range(6):
            _click(sim, KEY_DOWN)
        _click(sim, "ENTER")
        _click(sim, KEY_UP)
        _click(sim, "ENTER")

        cfg = (Path(sim.storage) / "SCRIPTS" / "5j.cfg").read_text(encoding="utf-8")
        if "WorkTime=11" not in cfg:
            raise AssertionError("配置未写成 11 分钟\n%s" % cfg)

        _click(sim, "EXIT")
        lines = sim.log_since()
        _assert_clean(lines, "回到飞行页")
        if _last_wt(lines) != 660:
            raise AssertionError("飞行页 WT 不是 660 秒\n%s" % "\n".join(lines))
