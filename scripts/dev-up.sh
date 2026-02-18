#!/usr/bin/env bash

set -eu

./scripts/supabase-ensure-running.sh

docker compose up -d

echo "Dev stack started: web(3000), bridge(8787), metro(8081), supabase(54321+)"
