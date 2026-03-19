#!/usr/bin/env bash

set -eu

# Use provided SUPABASE_DB_URL or default to local Supabase CLI default
DB_URL="${SUPABASE_DB_URL:-postgresql://postgres:postgres@127.0.0.1:54322/postgres}"

echo "Applying schema to $DB_URL..."
psql "$DB_URL" -f supabase/schema.sql
