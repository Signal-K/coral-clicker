---
id: qa01-headless-onboarding-audit
title: "Headless onboarding audit must not hijack user desktop"
status: done
priority: urgent
labels:
  - qa
  - tooling
  - onboarding
createdAt: '2026-03-20T00:00:00Z'
updatedAt: '2026-03-20T08:30:00Z'
---

# Headless onboarding audit must not hijack user desktop

## Problem

The recent visual/onboarding audit used a live Godot window in a way that interfered with the user's computer.

Observed issues:
- foreground window appeared on desktop
- user could not freely minimise or close it without breaking the flow
- audit path advanced unrealistically fast

## Required outcome

- Onboarding/visual audits must run headlessly or otherwise remain fully background-only
- They must not require window focus or block user interaction with their machine
- Audit pacing should include realistic dwell time so captured output resembles actual play, not instant scene skipping

## Acceptance notes

- Audit can run while user continues using the computer
- No foreground Godot/editor window is required
- Capture set reflects a plausible first-play pace
