---
id: qa03-make-test-tour
title: "`make test` runs tour + unit/content/e2e passes"
status: done
priority: high
labels:
  - qa
  - tooling
  - tour
createdAt: '2026-04-06T17:03:49Z'
updatedAt: '2026-04-06T17:03:49Z'
---

# `make test` runs all test passes

## What changed

`make test` now runs both the existing `test-suite` (unit + content + e2e) and the new `tour` pass in sequence.

A dedicated `make test-tour` target also exists for running the tour in isolation.

The `tour` service was added to `docker-compose.yml` under the `test` profile, using `docker/tour.Dockerfile` and `scripts/run-tour.sh`.

## Targets

| Target | What it runs |
|---|---|
| `make test` | `test-suite` then `tour` |
| `make test-tour` | `tour` only |
| `make test-godot` | `godot-test` (e2e_runner) only |

## Acceptance criteria

- `make test` exits non-zero if either pass fails
- Tour artifacts preserved in `artifacts/tour/` on failure
- No regression to existing `test-suite` behaviour
