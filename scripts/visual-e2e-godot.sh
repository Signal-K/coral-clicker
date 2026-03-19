#!/usr/bin/env bash

set -euo pipefail

GODOT_BIN="${GODOT_EDITOR:-}"
if [ -z "$GODOT_BIN" ]; then
  for candidate in \
    "/Applications/Godot4.5.app/Contents/MacOS/Godot" \
    "/Applications/Godot.app/Contents/MacOS/Godot"; do
    if [ -x "$candidate" ]; then
      GODOT_BIN="$candidate"
      break
    fi
  done
fi

if [ -z "$GODOT_BIN" ] || [ ! -x "$GODOT_BIN" ]; then
  echo "Godot binary not found; cannot run visual e2e"
  exit 1
fi

SCREENSHOT_DIR="${SCREENSHOT_DIR:-$PWD/artifacts/godot-visual-e2e}"
mkdir -p "$SCREENSHOT_DIR" /tmp/godot-visual /tmp/godot-visual-home /tmp/godot-visual-home/Library/Application\ Support/Godot

CMD=(env HOME=/tmp/godot-visual-home GODOT_USER_DIR=/tmp/godot-visual SCREENSHOT_DIR="$SCREENSHOT_DIR" "$GODOT_BIN" --path project res://tests/visual_e2e.tscn)

if command -v xvfb-run >/dev/null 2>&1; then
  xvfb-run -a "${CMD[@]}"
else
  "${CMD[@]}"
fi
