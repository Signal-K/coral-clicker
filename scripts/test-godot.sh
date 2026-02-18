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
  echo "Godot binary not found; skipping Godot headless tests"
  exit 0
fi

mkdir -p /tmp/godot /tmp/godot-home /tmp/godot-home/Library/Application\ Support/Godot
HOME=/tmp/godot-home GODOT_USER_DIR=/tmp/godot "$GODOT_BIN" --headless --path project --script res://tests/run_content_tests.gd
