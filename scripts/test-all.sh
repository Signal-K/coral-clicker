#!/usr/bin/env bash

set -euo pipefail

mkdir -p generated-config
node scripts/generate-runtime-config.js

bash -n scripts/*.sh

if command -v docker >/dev/null 2>&1; then
  docker compose config >/tmp/coral-compose-config.txt
else
  echo "Warning: docker command not found, skipping docker compose config"
fi

python3 -m venv .venv
. .venv/bin/activate
pip install -q -r tools/sprites/requirements.txt
python3 -m unittest tools/sprites/tests/test_generate_sprites.py

./scripts/test-godot.sh

if [ -f /.dockerenv ]; then
  echo "Detected Docker environment, ensuring yarn dependencies are synced..."
  yarn install
fi

yarn test --runInBand --watchAll=false

echo "All test suites passed."
