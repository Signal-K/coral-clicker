#!/usr/bin/env bash

set -euo pipefail

if [ ! -d .venv ]; then
  python3 -m venv .venv
fi

. .venv/bin/activate
pip install -q -r tools/sprites/requirements.txt
python3 tools/sprites/generate_sprites.py --out-dir project/assets/sprites --sprite-width 248 --sprite-height 248 --frames 8 --sheet-cols 4
