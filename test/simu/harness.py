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


@contextmanager
def session(screen=False):
    if not SIM.is_file() or not os.access(SIM, os.X_OK):
        raise SimulatorError("simu-cli 不可执行: " + str(SIM))
    tmp = tempfile.mkdtemp(prefix="simu-sd-")
    sim = None
    try:
        shutil.copytree(REPO / "SCRIPTS", Path(tmp) / "SCRIPTS")
        shutil.copytree(REPO / "LAOZHU", Path(tmp) / "LAOZHU")
        sim = _Sim(tmp, screen)
        sim.start()
        yield sim
    finally:
        if sim is not None:
            sim.close()
        shutil.rmtree(tmp, ignore_errors=True)
