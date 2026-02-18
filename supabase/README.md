Local Supabase wiring for Coral:

1. Start services:
   - `supabase start`
2. Apply schema:
   - `./scripts/apply-supabase-schema.sh`
3. Verify:
   - `psql "postgresql://postgres:postgres@127.0.0.1:54322/postgres" -c "select * from public.player_progress;"`

Endpoints used by hosts:
- API: `http://127.0.0.1:54321`
- REST: `http://127.0.0.1:54321/rest/v1`
- Studio: `http://127.0.0.1:54323`
