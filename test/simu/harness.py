"""用仓库根目录的 simu-cli 打开一份临时 SD。"""

import json
import os
import shutil
import subprocess
import sys
import tempfile
import threading
import time
from contextlib import contextmanager
from pathlib import Path

REPO = Path(__file__).resolve().parents[2]
SIM = REPO / "simu-cli"
TOOLS = REPO / "edgetx" / "tools"

if str(TOOLS) not in sys.path:
    sys.path.insert(0, str(TOOLS))

from simctl.client import Simulator, SimulatorError


class _Sim(Simulator):
    def __init__(self, storage, screen):
        super().__init__(sim=str(SIM), storage=storage)
        self._screen = screen

    def start(self):
        cmd = [self.sim, "--control", "stdio"]
        if self._screen:
            cmd.append("--screen")
        if self.storage:
            cmd.extend(["--storage", self.storage])
        if self.settings:
            cmd.extend(["--settings", self.settings])
        self._proc = subprocess.Popen(
            cmd,
            stdin=subprocess.PIPE,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            bufsize=0,
        )
        threading.Thread(target=self._drain_stderr, daemon=True).start()
        ready = self._readline_proc()
        if not ready:
            try:
                self._proc.wait(timeout=2)
            except Exception:
                pass
            time.sleep(0.05)
            err = "".join(self._stderr)
            raise SimulatorError("simulator exited before ready: " + err)
        message = json.loads(ready)
        if message.get("event") != "ready":
            raise SimulatorError("unexpected simulator greeting", message)
        self._sync_log_cursor()
        return self


_CASE_NEED = ("[DBG] simu ok",)
_CASE_BAD = ("-E-", "Error loading script", "Error parsing script", "[ERR]")


def _write_case(sim, name):
    case_path = Path(sim.storage) / "SCRIPTS" / "simu.case"
    case_path.write_text(name.strip() + "\n", encoding="utf-8")


def _raise_if_bad(label, lines):
    text = "\n".join(lines)
    bad = [mark for mark in _CASE_BAD if mark in text]
    if bad:
        raise AssertionError("simt %s 失败 bad=%s\n%s" % (label, bad, text))


def run_case(sim, name, timeout=60000):
    """让遥测入口 simt 在 init 里跑完一个批量用例。"""
    _write_case(sim, name)
    sim.show_telemetry("simt", timeout=int(timeout))
    lines = sim.log_since()
    text = "\n".join(lines)
    missing = [mark for mark in _CASE_NEED if mark not in text]
    bad = [mark for mark in _CASE_BAD if mark in text]
    if missing or bad:
        raise AssertionError(
            "simt %s 失败 missing=%s bad=%s\n%s" % (name, missing, bad, text)
        )


def open_case(sim, name, timeout=60000):
    """打开按键用例，等到脚本可以接收遥控器事件。"""
    _write_case(sim, name)
    sim.show_telemetry("simt", timeout=int(timeout))
    try:
        lines = sim.wait_log("[DBG] simu ready", timeout=max(5, timeout / 1000))
    except SimulatorError as exc:
        lines = (exc.response or {}).get("lines") or []
        raise AssertionError(
            "simt %s 未就绪\n%s" % (name, "\n".join(lines))
        ) from exc
    _raise_if_bad(name, lines)
    return lines


def expect_log(sim, text, timeout=5):
    try:
        lines = sim.wait_log(text, timeout=timeout)
    except SimulatorError as exc:
        lines = (exc.response or {}).get("lines") or []
        raise AssertionError("等待 %s 超时\n%s" % (text, "\n".join(lines))) from exc
    _raise_if_bad(text, lines)
    return lines


def hold_key(sim, name, ms=800):
    """按住再松开，让固件发出长按事件。"""
    sim.key(name, "down")
    sim.wait(int(ms))
    sim.key(name, "up")


@contextmanager
def session(screen=False):
    if not SIM.is_file() or not os.access(SIM, os.X_OK):
        raise SimulatorError("simu-cli 不可执行: " + str(SIM))
    tmp = tempfile.mkdtemp(prefix="simu-sd-")
    sim = None
    try:
        shutil.copytree(REPO / "SCRIPTS", Path(tmp) / "SCRIPTS")
        shutil.copytree(REPO / "LAOZHU", Path(tmp) / "LAOZHU")
        shutil.copytree(REPO / "test" / "simu" / "cases", Path(tmp) / "SCRIPTS" / "simu")
        sim = _Sim(tmp, screen)
        sim.start()
        yield sim
    finally:
        if sim is not None:
            sim.close()
        shutil.rmtree(tmp, ignore_errors=True)
