#!/usr/bin/env bash

set -eu

psql "postgresql://postgres:postgres@127.0.0.1:54322/postgres" -f supabase/schema.sql
