#!/usr/bin/env bash

set -eu

MARKER_FILE=".supabase.started-by-coral"

if [ ! -x "$(command -v supabase)" ]; then
  echo "supabase CLI not found; skipping Supabase start"
  exit 0
fi

if supabase status >/tmp/coral-supabase-status.txt 2>&1; then
  if grep -Eq "API URL|Project URL" /tmp/coral-supabase-status.txt; then
    echo "Supabase already running; skipping start"
    rm -f "$MARKER_FILE"
    exit 0
  fi
fi

echo "Starting Supabase..."
supabase start

touch "$MARKER_FILE"
