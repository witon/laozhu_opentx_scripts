"""从 3ktel 进主界面，上下键和滚轮不按 Enter 就能改目标飞行时间。"""

import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))

import harness

KEY_UP = "MODEL"
KEY_DOWN = "TELE"
KEY_LEFT = "PAGEUP"
STEP_MS = 1000


def _prepare(sim):
    scripts = Path(sim.storage) / "SCRIPTS"
    (scripts / "lzinstall.flag").write_text("inited", encoding="utf-8")
    (scripts / "3k.cfg").write_text(
        "DestTimeStep=15:n\ntask=-:s\nPrepTime=0:n\nTestTime=0:n\nNFlyTime=0:n\n",
        encoding="utf-8",
    )


def _last_dest(lines):
    found = None
    for line in lines:
        mark = "[DBG] dest "
        i = line.find(mark)
        if i >= 0:
            found = int(line[i + len(mark):].split()[0])
    return found


def _pause(sim):
    sim.wait(STEP_MS)


def _click(sim, key, text):
    sim.key(key, "click")
    harness.expect_log(sim, text)
    _pause(sim)


def _encoder(sim, steps, text):
    sim.encoder(steps)
    harness.expect_log(sim, text)
    _pause(sim)


def _assert_dest_unchanged(sim, label):
    _pause(sim)
    idle = sim.log_since()
    text = "\n".join(idle)
    if any(mark in text for mark in ("-E-", "Error loading script", "Error parsing script", "[ERR]")):
        raise AssertionError("%s 失败\n%s" % (label, text))
    if _last_dest(idle) is not None:
        raise AssertionError("%s 改了目标时间\n%s" % (label, text))


def test_dest_time(screen=False):
    with harness.session(screen=screen) as sim:
        _prepare(sim)
        sim.show_telemetry("3ktel", timeout=60000)
        opened = sim.log_since()
        if _last_dest(opened) != 0:
            raise AssertionError("初始目标时间不对\n%s" % "\n".join(opened))
        _pause(sim)

        _click(sim, KEY_UP, "[DBG] dest 15")
        _click(sim, KEY_DOWN, "[DBG] dest 0")
        _encoder(sim, -1, "[DBG] dest 15")
        _encoder(sim, 1, "[DBG] dest 0")
        _click(sim, KEY_UP, "[DBG] dest 15")
        sim.key("ENTER", "click")
        _assert_dest_unchanged(sim, "Enter")

        harness.hold_key(sim, KEY_DOWN)
        _pause(sim)
        lines = sim.log_since()
        text = "\n".join(lines)
        if any(mark in text for mark in ("-E-", "Error loading script", "Error parsing script", "[ERR]")):
            raise AssertionError("长按下失败\n%s" % text)
        dest = _last_dest(lines)
        if dest != 0:
            raise AssertionError("长按下应只在松手时减一步，得到 dest=%s\n%s" % (dest, text))

        sim.key(KEY_LEFT, "click")
        _assert_dest_unchanged(sim, "左键翻页")
        sim.key(KEY_UP, "click")
        _assert_dest_unchanged(sim, "离开主界面后上键")
