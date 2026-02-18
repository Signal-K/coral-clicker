#!/usr/bin/env bash

set -eu

docker compose down

./scripts/supabase-stop-if-managed.sh
