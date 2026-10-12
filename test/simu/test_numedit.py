"""用 zorro-simu 的按键操作 NumEdit。"""

import re
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))

import harness

NUM_LINE = re.compile(r"\[DBG\] num (-?\d+) chg (\d+)")


def _last_num(lines):
    found = None
    for line in lines:
        match = NUM_LINE.search(line)
        if match:
            found = (int(match.group(1)), int(match.group(2)))
    return found

# zorro-simu 3.0 单击松手后的事件，再经 SCRIPTS/keymap.cfg：
# ENTER -> 进入编辑；MODEL -> 上，加一步；TELE -> 下，减一步；
# PAGEUP -> 左，减一步；PAGEDN -> 右，加一步。
# 滚轮 -1 是上，+1 是下。长按 TELE / PAGEDN 会先走十步，松手再走一步。
KEY_ENTER = "ENTER"
KEY_UP = "MODEL"
KEY_DOWN = "TELE"
KEY_LEFT = "PAGEUP"
KEY_RIGHT = "PAGEDN"


def _click(sim, key, text):
    sim.key(key, "click")
    harness.expect_log(sim, text)
    sim.wait(80)


def _encoder(sim, steps, text):
    sim.wait(80)
    sim.encoder(steps)
    harness.expect_log(sim, text)
    sim.wait(80)


def _hold_last(sim, key):
    harness.hold_key(sim, key)
    sim.wait(250)
    lines = sim.log_since()
    text = "\n".join(lines)
    if any(mark in text for mark in ("-E-", "Error loading script", "Error parsing script", "[ERR]")):
        raise AssertionError("长按 %s 失败\n%s" % (key, text))
    state = _last_num(lines)
    if state is None:
        raise AssertionError("长按 %s 没有数值日志\n%s" % (key, text))
    return state


def test_numedit(screen=False):
    with harness.session(screen=screen) as sim:
        opened = harness.open_case(sim, "testNumEditO.lua")
        if _last_num(opened) != (5, 0):
            raise AssertionError("初始数值不对\n%s" % "\n".join(opened))

        sim.key(KEY_UP, "click")
        sim.wait(150)
        idle = sim.log_since()
        if _last_num(idle) is not None:
            raise AssertionError("未进入编辑时上键改了数值\n%s" % "\n".join(idle))

        _click(sim, KEY_ENTER, "[DBG] editing")
        _click(sim, KEY_UP, "[DBG] num 6 chg 1")
        _click(sim, KEY_DOWN, "[DBG] num 5 chg 2")
        _click(sim, KEY_LEFT, "[DBG] num 4 chg 3")
        _click(sim, KEY_RIGHT, "[DBG] num 5 chg 4")
        _encoder(sim, -1, "[DBG] num 6 chg 5")
        _encoder(sim, 1, "[DBG] num 5 chg 6")

        num, chg = _hold_last(sim, KEY_DOWN)
        if num != 1 or chg <= 6:
            raise AssertionError("长按下应钳到最小值，得到 num=%s chg=%s" % (num, chg))

        _click(sim, KEY_DOWN, "[DBG] num 1 chg %d" % (chg + 1))
        num, chg = _hold_last(sim, KEY_RIGHT)
        if num != 10 or chg <= 7:
            raise AssertionError("长按右应钳到最大值，得到 num=%s chg=%s" % (num, chg))

        _click(sim, KEY_UP, "[DBG] num 10 chg %d" % (chg + 1))
