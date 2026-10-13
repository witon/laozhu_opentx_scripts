"""3ktel 全流程：选 TEST、改目标时间、开轮、飞一圈、翻页、复位。"""

import re
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))

import harness

KEY_UP = "MODEL"
KEY_DOWN = "TELE"
KEY_RIGHT = "PAGEDN"
STEP_MS = 300

SW_LINE = re.compile(r"\[DBG\] sw (sa|sb|sc|sd) (\d+)")
TASKS = ("Train", "LastFl", "AULD", "OtherTask", "TEST")


def _prepare_flag(sim):
    scripts = Path(sim.storage) / "SCRIPTS"
    (scripts / "lzinstall.flag").write_text("inited", encoding="utf-8")
    cfg = scripts / "3k.cfg"
    if cfg.exists():
        cfg.unlink()


def _switch_ids(lines):
    found = {}
    for line in lines:
        match = SW_LINE.search(line)
        if match:
            found[match.group(1)] = int(match.group(2))
    missing = [name for name in ("sa", "sb", "sc", "sd") if name not in found]
    if missing:
        raise AssertionError("缺少开关字段 id %s\n%s" % (missing, "\n".join(lines)))
    return found


def _write_cfg(sim, ids):
    text = (
        "DestTimeStep=15:n\n"
        "task=-:s\n"
        "PrepTime=0:n\n"
        "TestTime=0:n\n"
        "NFlyTime=0:n\n"
        "MuteRndTimer=1:n\n"
        "RdSw=%d:n\n"
        "RdResetSw=%d:n\n" % (ids["sc"], ids["sd"])
    )
    if len(text.encode("utf-8")) > 200:
        raise AssertionError("3k.cfg 超过 200 字节")
    (Path(sim.storage) / "SCRIPTS" / "3k.cfg").write_text(text, encoding="utf-8")


def _pause(sim):
    sim.wait(STEP_MS)


def _click(sim, key, text=None):
    sim.key(key, "click")
    if text is not None:
        harness.expect_log(sim, text)
    _pause(sim)


def _switch(sim, name, state):
    sim.switch(name, state)
    _pause(sim)


def _start_round(sim):
    last = None
    for state in ("down", "up"):
        sim.switch("SC", state)
        try:
            harness.expect_log(sim, "[DBG] round 4", timeout=3)
            return
        except AssertionError as exc:
            last = exc
            message = str(exc)
            if any(mark in message for mark in ("-E-", "Error loading script", "Error parsing script", "[ERR]")):
                raise
    raise AssertionError("轮次没有进入任务窗") from last


def _run_fixture(sim):
    case_path = Path(sim.storage) / "SCRIPTS" / "simu.case"
    case_path.write_text("setupF3kModel.lua\n", encoding="utf-8")
    sim.show_telemetry("simt", timeout=60000)
    lines = sim.log_since()
    text = "\n".join(lines)
    if "[DBG] simu ok" not in text:
        raise AssertionError("模型夹具未完成\n%s" % text)
    if any(mark in text for mark in ("-E-", "Error loading script", "Error parsing script", "[ERR]")):
        raise AssertionError("模型夹具失败\n%s" % text)
    return lines


def test_3ktel_round(screen=False):
    with harness.session(screen=screen) as sim:
        _prepare_flag(sim)
        ids = _switch_ids(_run_fixture(sim))
        _write_cfg(sim, ids)

        sim.show_telemetry("3ktel", timeout=60000)
        opened = sim.log_since()
        text = "\n".join(opened)
        if any(mark in text for mark in ("-E-", "Error loading script", "Error parsing script", "[ERR]")):
            raise AssertionError("打开 3ktel 失败\n%s" % text)
        for mark in ("[DBG] page 3k/FlightPageNew.lua", "[DBG] dest 0", "[DBG] round 1"):
            if mark not in text:
                raise AssertionError("初始状态缺少 %s\n%s" % (mark, text))
        _pause(sim)

        harness.hold_key(sim, KEY_RIGHT)
        _pause(sim)
        harness.expect_log(sim, "[DBG] page 3k/RoundSetupPage.lua")

        _click(sim, KEY_DOWN)
        _click(sim, "ENTER")
        for task in TASKS:
            _click(sim, KEY_UP, "[DBG] task %s" % task)
        _click(sim, "ENTER")

        cfg = (Path(sim.storage) / "SCRIPTS" / "3k.cfg").read_text(encoding="utf-8")
        if "task=TEST" not in cfg:
            raise AssertionError("配置未写成 TEST\n%s" % cfg)

        _click(sim, KEY_RIGHT, "[DBG] page 3k/SetupPage.lua")
        _click(sim, "EXIT", "[DBG] page 3k/FlightPageNew.lua")
        _click(sim, KEY_UP, "[DBG] dest 15")

        _start_round(sim)
        # SA、SD 是两位开关，没有中位；松开用 up。SB 是三位，离开 zoom 也回到 up。
        _switch(sim, "SA", "down")
        _switch(sim, "SA", "up")
        _switch(sim, "SB", "down")
        harness.expect_log(sim, "[DBG] fstate Zoom")
        _switch(sim, "SB", "up")
        harness.expect_log(sim, "[DBG] fstate Flight")
        sim.wait(500)
        _switch(sim, "SA", "down")
        landed = harness.expect_log(sim, "[DBG] flights 1")
        if "[DBG] fstate Landed" not in "\n".join(landed):
            harness.expect_log(sim, "[DBG] fstate Landed")

        _click(sim, KEY_RIGHT, "[DBG] page 3k/SmallFontFlightListPage.lua")
        _click(sim, KEY_RIGHT, "[DBG] page 3k/SensorPage.lua")

        _switch(sim, "SD", "down")
        harness.expect_log(sim, "[DBG] round 1")
