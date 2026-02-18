#!/usr/bin/env bash

set -euo pipefail

node scripts/generate-runtime-config.js

bash -n scripts/*.sh

docker compose config >/tmp/coral-compose-config.txt

python3 -m venv .venv
. .venv/bin/activate
pip install -q -r tools/sprites/requirements.txt
python3 -m unittest tools/sprites/tests/test_generate_sprites.py

./scripts/test-godot.sh

npm test -- --runInBand --watchAll=false

echo "All test suites passed."
