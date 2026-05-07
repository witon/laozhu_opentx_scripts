#!/usr/bin/env bash
set -e

# Mirrors install.bat: copy script/{TELEMETRY,LAOZHU,emutest,test,CompileFiles.lua} to SD/SCRIPTS/
export COPYFILE_DISABLE=1
export COPY_EXTENDED_ATTRIBUTES_DISABLE=1

ROOT="$(cd "$(dirname "$0")" && pwd)"
SCRIPT_SRC="$ROOT/script"

if [[ ! -d "$SCRIPT_SRC" ]]; then
  echo "install_mac.sh: missing directory: $SCRIPT_SRC" >&2
  exit 1
fi

find "$SCRIPT_SRC" -name '*.luac' -delete

DIRS=(TELEMETRY LAOZHU emutest test)
FILES=(CompileFiles.lua)

if [[ -n "${1:-}" ]]; then
  DEST_ROOT="$1"
else
  echo 'input the disk to install, such as "/Volumes/EDGE"'
  read -r DEST_ROOT
fi

DEST_ROOT="${DEST_ROOT%/}"

if [[ -z "$DEST_ROOT" ]]; then
  exit 1
fi

if [[ "$(basename "$DEST_ROOT")" == SCRIPTS ]]; then
  DEST_ROOT="$(dirname "$DEST_ROOT")"
fi

if [[ ! -d "$DEST_ROOT" ]]; then
  echo "install_mac.sh: SD root does not exist: $DEST_ROOT" >&2
  exit 1
fi

TARGET="$DEST_ROOT/SCRIPTS"
mkdir -p "$TARGET"

for d in "${DIRS[@]}"; do
  if [[ ! -d "$SCRIPT_SRC/$d" ]]; then
    echo "install_mac.sh: missing source dir: $SCRIPT_SRC/$d" >&2
    exit 1
  fi
  mkdir -p "$TARGET/$d"
  rsync -av --no-specials --no-devices "$SCRIPT_SRC/$d/" "$TARGET/$d/"
done

for f in "${FILES[@]}"; do
  cp -vf "$SCRIPT_SRC/$f" "$TARGET/"
done

printf '%s\n' 'not init' > "$TARGET/lzinstall.flag"
echo "-> $TARGET/lzinstall.flag"

echo "installed to $TARGET"
