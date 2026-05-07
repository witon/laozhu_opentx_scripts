#!/usr/bin/env bash
set -e

# Repo layout matches SD card: SCRIPTS/*, LAOZHU/* and WIDGETS/* at the same level.
# Copies SCRIPTS/ → SD/SCRIPTS/, LAOZHU/ → SD/LAOZHU/, WIDGETS/ → SD/WIDGETS/.
export COPYFILE_DISABLE=1
export COPY_EXTENDED_ATTRIBUTES_DISABLE=1

ROOT="$(cd "$(dirname "$0")" && pwd)"
SCRIPTS_SRC="$ROOT/SCRIPTS"
LAOZHU_SRC="$ROOT/LAOZHU"
WIDGETS_SRC="$ROOT/WIDGETS"

if [[ ! -d "$SCRIPTS_SRC" ]]; then
  echo "install_mac.sh: missing directory: $SCRIPTS_SRC" >&2
  exit 1
fi

if [[ ! -d "$LAOZHU_SRC" ]]; then
  echo "install_mac.sh: missing directory: $LAOZHU_SRC" >&2
  exit 1
fi

find "$SCRIPTS_SRC" -name '*.luac' -delete
find "$LAOZHU_SRC" -name '*.luac' -delete
if [[ -d "$WIDGETS_SRC" ]]; then
  find "$WIDGETS_SRC" -name '*.luac' -delete
fi

DIRS=(TELEMETRY emutest test)
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
  if [[ ! -d "$SCRIPTS_SRC/$d" ]]; then
    echo "install_mac.sh: missing source dir: $SCRIPTS_SRC/$d" >&2
    exit 1
  fi
  mkdir -p "$TARGET/$d"
  rsync -av --no-specials --no-devices "$SCRIPTS_SRC/$d/" "$TARGET/$d/"
done

mkdir -p "$DEST_ROOT/LAOZHU"
rsync -av --no-specials --no-devices "$LAOZHU_SRC/" "$DEST_ROOT/LAOZHU/"

if [[ -d "$WIDGETS_SRC" ]]; then
  mkdir -p "$DEST_ROOT/WIDGETS"
  rsync -av --no-specials --no-devices "$WIDGETS_SRC/" "$DEST_ROOT/WIDGETS/"
fi

for f in "${FILES[@]}"; do
  cp -vf "$SCRIPTS_SRC/$f" "$TARGET/"
done

printf '%s\n' 'not init' > "$TARGET/lzinstall.flag"
echo "-> $TARGET/lzinstall.flag"

echo "installed SCRIPTS to $TARGET"
echo "installed LAOZHU to $DEST_ROOT/LAOZHU"
[[ -d "$DEST_ROOT/WIDGETS" ]] && echo "installed WIDGETS to $DEST_ROOT/WIDGETS"
