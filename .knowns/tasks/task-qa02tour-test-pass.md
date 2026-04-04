---
id: qa02-tour-test-pass
title: "Godot tour test pass: full E2E walkthrough with screenshots"
status: todo
priority: high
labels:
  - qa
  - testing
  - tour
createdAt: '2026-04-06T17:03:49Z'
updatedAt: '2026-04-06T17:03:49Z'
---

# Godot tour test pass

## What it is

`project/tests/tour_runner.gd` walks the full game from launch through the tutorial and into level 2 mechanics, capturing screenshots at each step. It runs headlessly via Xvfb inside Docker (`docker/tour.Dockerfile` + `scripts/run-tour.sh`).

Artifacts land in `artifacts/tour/` and a JSON report is written to `artifacts/tour_report.json` (deleted on success).

## How to run

```
docker compose --profile test run --rm tour
```

Or via Make:

```
make test-tour
```

## Acceptance criteria

- All tour steps complete without error
- Screenshots captured for: launch, home, tutorial entry/feed/goal/turn/identify/results/win, home after tutorial, level 2 entry/board/identify/turn/results
- `tour_report.json` is absent on success (deleted by `run-tour.sh`)
- Non-zero exit code on any step failure, with artifacts preserved
