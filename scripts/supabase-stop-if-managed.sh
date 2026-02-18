#!/usr/bin/env bash

set -eu

MARKER_FILE=".supabase.started-by-coral"

if [ ! -x "$(command -v supabase)" ]; then
  echo "supabase CLI not found; skipping Supabase stop"
  exit 0
fi

if [ -f "$MARKER_FILE" ]; then
  echo "Stopping Supabase started by Coral..."
  supabase stop
  rm -f "$MARKER_FILE"
else
  echo "Supabase was not started by Coral; leaving it running"
fi
