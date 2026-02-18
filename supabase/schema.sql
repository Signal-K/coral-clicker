create table if not exists public.player_progress (
  player_id text primary key,
  current_level integer not null default 1,
  completed_levels integer[] not null default '{}',
  rewards_total integer not null default 0,
  metadata jsonb not null default '{}'::jsonb,
  updated_at timestamptz not null default now()
);

alter table public.player_progress enable row level security;

do $$ begin
  create policy "allow anon rw" on public.player_progress
    for all
    using (true)
    with check (true);
exception
  when duplicate_object then null;
end $$;
