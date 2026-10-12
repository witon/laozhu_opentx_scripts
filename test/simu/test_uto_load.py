"""加载 utO.lua，并等到 run 执行过一次。"""

import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))

import harness

NEED = ("[DBG] begin load", "[DBG] loaded")
BAD = ("-E-", "Error loading script", "Error parsing script", "[ERR]")


def test_uto_load(screen=False):
    with harness.session(screen=screen) as sim:
        sim.show_telemetry("utO", timeout=60000)
        lines = sim.log_since()
    text = "\n".join(lines)
    missing = [mark for mark in NEED if mark not in text]
    bad = [mark for mark in BAD if mark in text]
    if missing or bad:
        raise AssertionError(
            "utO 加载失败 missing=%s bad=%s\n%s" % (missing, bad, text)
        )
