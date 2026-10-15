"""油门微调写入：枚举常量与模拟器模型回读。"""

import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))

import harness


def test_thr_trim_roundtrip(screen=False):
    with harness.session(screen=screen) as sim:
        harness.run_case(sim, "testThrTrimPlan.lua")
