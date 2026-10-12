"""执行 test/simu/test_*.py 中的 test_* 函数。"""

import argparse
import importlib.util
import sys
import traceback
from pathlib import Path


def _load(path):
    spec = importlib.util.spec_from_file_location(path.stem, path)
    mod = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(mod)
    return mod


def main(argv=None):
    parser = argparse.ArgumentParser()
    parser.add_argument("--screen", action="store_true", help="打开 simu-cli 的 LCD 窗口")
    args = parser.parse_args(argv)
    here = Path(__file__).resolve().parent
    ran = 0
    failed = 0
    for path in sorted(here.glob("test_*.py")):
        mod = _load(path)
        names = sorted(
            name
            for name in dir(mod)
            if name.startswith("test_") and callable(getattr(mod, name))
        )
        for name in names:
            ran += 1
            try:
                getattr(mod, name)(screen=args.screen)
            except Exception:
                failed += 1
                traceback.print_exc()
            else:
                print("ok %s %s" % (path.name, name))
    if ran == 0:
        print("no tests", file=sys.stderr)
        return 1
    return 1 if failed else 0


if __name__ == "__main__":
    sys.exit(main())
