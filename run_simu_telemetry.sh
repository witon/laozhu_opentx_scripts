#!/usr/bin/env bash
# 用 Zorro 的 simu-cli 跑遥测脚本 utO 的 emutest。
# 必填：SIMU_CLI 指向 simu-cli。
# 可选：EDGETX_TOOLS 指向 EdgeTX 的 tools 目录；未设置时依次尝试子模块 edgetx/tools、../edgetx/tools 与 ~/code/edgetx/tools。
set -euo pipefail
REPO_ROOT="$(cd "$(dirname "$0")" && pwd)"
cd "$REPO_ROOT"

if [[ -z "${SIMU_CLI:-}" ]]; then
  echo "run_simu_telemetry.sh: 请设置环境变量 SIMU_CLI，指向 Zorro 的 simu-cli" >&2
  exit 1
fi
if [[ ! -f "$SIMU_CLI" || ! -x "$SIMU_CLI" ]]; then
  echo "run_simu_telemetry.sh: SIMU_CLI 不是可执行文件: $SIMU_CLI" >&2
  exit 1
fi

if [[ -n "${EDGETX_TOOLS:-}" ]]; then
  if [[ ! -d "$EDGETX_TOOLS" ]]; then
    echo "run_simu_telemetry.sh: EDGETX_TOOLS 不是目录: $EDGETX_TOOLS" >&2
    exit 1
  fi
else
  cand_sub="$REPO_ROOT/edgetx/tools"
  cand_repo="$REPO_ROOT/../edgetx/tools"
  cand_home="$HOME/code/edgetx/tools"
  if [[ -d "$cand_sub" ]]; then
    EDGETX_TOOLS="$cand_sub"
  elif [[ -d "$cand_repo" ]]; then
    EDGETX_TOOLS="$cand_repo"
  elif [[ -d "$cand_home" ]]; then
    EDGETX_TOOLS="$cand_home"
  else
    echo "run_simu_telemetry.sh: 未设置 EDGETX_TOOLS，且未找到 $cand_sub、$cand_repo 或 $cand_home" >&2
    exit 1
  fi
fi
EDGETX_TOOLS="$(cd "$EDGETX_TOOLS" && pwd)"
export EDGETX_TOOLS
export PYTHONPATH="${EDGETX_TOOLS}${PYTHONPATH:+:$PYTHONPATH}"

tmp="$(mktemp -d)"
log_file="$(mktemp)"
trap 'rm -rf "$tmp"; rm -f "$log_file"' EXIT
cp -a SCRIPTS LAOZHU WIDGETS "$tmp/"

set +e
python -m simctl test \
  --kind telemetry \
  --sim "$SIMU_CLI" \
  --storage "$tmp" \
  --script utO \
  --expect "emutest done" \
  --timeout 60 \
  2>&1 | tee "$log_file"
status=${PIPESTATUS[0]}
set -e

if grep -F -q -e '-E-' -e 'Error loading script' -e 'Error parsing script' -e '[ERR]' "$log_file"; then
  echo "run_simu_telemetry.sh: 日志含 -E-、Error loading script、Error parsing script 或 [ERR]" >&2
  exit 1
fi

exit "$status"
