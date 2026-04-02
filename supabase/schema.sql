create table if not exists public.player_progress (
  player_id text primary key,
  current_level integer not null default 1,
  completed_levels integer[] not null default '{}',
  rewards_total integer not null default 0,
  turns_used integer,
  coins_earned integer,
  classification_id uuid,
  metadata jsonb not null default '{}'::jsonb,
  updated_at timestamptz not null default now()
);

alter table public.player_progress enable row level security;

do $$ begin
  if not exists (select 1 from pg_policies where tablename = 'player_progress' and policyname = 'allow anon rw') then
    create policy "allow anon rw" on public.player_progress
      for all
      using (true)
      with check (true);
  end if;
exception
  when duplicate_object then null;
end $$;

-- Classifications table (one row per player identification attempt)
create table if not exists public.coral_classifications (
  id uuid primary key default gen_random_uuid(),
  player_id text,
  subject_id text not null,
  selected_species text[] not null,
  level_number int,
  created_at timestamptz default now()
);

alter table public.coral_classifications enable row level security;

do $$ begin
  if not exists (select 1 from pg_policies where tablename = 'coral_classifications' and policyname = 'allow anon rw') then
    create policy "allow anon rw" on public.coral_classifications
      for all
      using (true)
      with check (true);
  end if;
exception
  when duplicate_object then null;
end $$;
