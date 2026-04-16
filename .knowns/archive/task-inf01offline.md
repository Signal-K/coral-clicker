---
id: inf01offline
title: "Offline-first play + Supabase classification sync"
status: in_progress
priority: medium
labels:
  - infra
  - supabase
  - offline
  - citizen-science
createdAt: '2026-03-15T00:00:00Z'
updatedAt: '2026-03-21T00:00:00Z'
---

# Offline-first play + Supabase sync

## Goal

All 10 levels must be fully playable with no internet connection. Citizen science classifications and progress are saved locally and synced automatically when connection is restored.

## What gets stored locally (when offline)

| Data | Local storage | Sync priority |
|---|---|---|
| Level progress (coins, turns) | `user://save.json` | High — sync on reconnect |
| Player classifications | `user://pending_classifications.json` | High — sync on reconnect |
| Species reference data | Bundled in Godot project (`res://data/`) | Never needs sync (read-only) |
| Zooniverse subject images | Downloaded on first play per level, cached | Medium |

## Classification queue

`AppController` already has `_pending_classifications` array. Ensure:
1. On `_on_identify_confirmed()` in level_system.gd: append to queue AND attempt immediate upload
2. If upload fails: leave in queue, no error shown to player
3. On any network reconnect signal (or on app foreground): drain the queue
4. After successful upload: remove from local file

## Progress sync

- On level complete: save progress to local file immediately
- **Coins and rewards are NOT given to the player until Supabase sync succeeds.** If offline, the player sees a "Reward pending sync" state rather than receiving coins immediately.
- On reconnect: drain classification queue AND sync pending rewards. Only then unlock coins.
- `app_controller.gd` `_sync_to_supabase()` called automatically on level end and on reconnect
- Remove the manual "Sync" button from UI (move to Settings → "Sync now" if needed)

## Offline mode visibility

- **No offline indicator is shown to the player.** The game behaves identically whether online or offline.
- The only visible difference: if offline after a level win, a "Reward pending sync" notice appears on the Level End screen instead of the coin total. Once synced, coins animate into the resource bar.

## Pending reward state

Track in `user://save.json`:
```json
{
  "pending_rewards": [
    { "level": 3, "coins": 65, "synced": false }
  ]
}
```
On sync success: mark `synced: true`, add coins to player balance, update UI.

## Subject image caching

- On world map load: for each available (unlocked) level, prefetch the subject image URL
- Store in `user://subject_cache/{subject_id}.jpg`
- Show a small download indicator on locked levels that aren't cached yet
- If image not cached and offline: show placeholder reef silhouette in identify phase

## Supabase schema additions needed

```sql
-- Classifications table (one row per player identification attempt)
create table coral_classifications (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users,
  subject_id text not null,
  selected_species text[] not null,
  level_number int,
  created_at timestamptz default now()
);

-- Level progress (already partially exists, ensure these columns)
alter table level_progress add column if not exists turns_used int;
alter table level_progress add column if not exists coins_earned int;
alter table level_progress add column if not exists classification_id uuid;
```

## Technical notes

- Use Godot's `HTTPRequest` node for Supabase REST calls (already in place)
- `AppController._sync_to_supabase()` — refactor to handle both progress AND classification queue
- All file I/O via `FileAccess` in GDScript; no external dependency
