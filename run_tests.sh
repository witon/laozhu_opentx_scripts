#!/usr/bin/env bash
set -euo pipefail
REPO_ROOT="$(cd "$(dirname "$0")" && pwd)"
cd "$REPO_ROOT"

if [[ "$(uname -s)" != "Darwin" ]]; then
  echo "run_tests.sh: 当前仅支持 macOS。其他系统请使用本机 Lua 5.2：lua test/test.lua" >&2
  exit 1
fi

arch_name="$(uname -m)"
case "$arch_name" in
  arm64)  LUA_BIN="$REPO_ROOT/tools/lua/5.2.2/darwin-arm64/lua" ;;
  x86_64) LUA_BIN="$REPO_ROOT/tools/lua/5.2.2/darwin-x86_64/lua" ;;
  *)
    echo "run_tests.sh: 不支持的架构: $arch_name" >&2
    exit 1
    ;;
esac

if [[ ! -x "$LUA_BIN" ]]; then
  echo "run_tests.sh: 未找到可执行文件: $LUA_BIN" >&2
  exit 1
fi

# 注入 LuaRocks 的模块搜索路径，使 require("luaunit") / require("test.mock.*") 无需事先手动 eval。
# 优先 5.2 树（与捆绑解释器一致），再并入 luarocks 默认输出（例如本机仅装了 Lua 5.5 的 rocks 时，纯 Lua 包仍常被 5.2 加载）。
if command -v luarocks >/dev/null 2>&1; then
  LUA_PATH_52=""
  LUA_CPATH_52=""
  eval "$(luarocks path --lua-version=5.2 2>/dev/null || true)"
  LUA_PATH_52="${LUA_PATH-}"
  LUA_CPATH_52="${LUA_CPATH-}"
  eval "$(luarocks path 2>/dev/null || true)"
  export LUA_PATH="${LUA_PATH_52:+${LUA_PATH_52};}${LUA_PATH-}"
  export LUA_CPATH="${LUA_CPATH_52:+${LUA_CPATH_52};}${LUA_CPATH-}"
else
  echo "run_tests.sh: 未在 PATH 中找到 luarocks；请先安装 LuaRocks，或自行设置 LUA_PATH/LUA_CPATH 后重试。" >&2
  exit 1
fi

exec "$LUA_BIN" "$REPO_ROOT/test/test.lua" "$@"
