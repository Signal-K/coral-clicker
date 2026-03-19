---
id: v01idmakeup
title: "v0.1: Implement Identify Reef Makeup phase"
status: done
priority: high
labels:
  - puzzle
  - level-start
  - classification
createdAt: '2026-03-12T21:17:00Z'
updatedAt: '2026-03-12T21:17:00Z'
timeSpent: 0
---

# Implement Identify Reef Makeup phase

## Description

At the start of each level, the player should be presented with a Zooniverse subject image. They must identify the makeup of the reef (e.g., which coral species are present).

## Requirements

- Before the gameplay loop starts, show a full-screen or large modal with the Zooniverse image.
- Let the player "tag" or select which species they see from a predefined list.
- The identified species will determine the "Starting Materials" (fish/coral) available for the level.
- This phase serves as the "Citizen Science" component and sets the puzzle goal.
- Add a "Skip" or "Help" option for a relaxed experience.
- **Offline Support:** Classifications made while offline are saved locally and synced to Supabase when a connection is established.

## Technical Notes

- Use data from `project/data/click_a_coral_subjects.json`.
- Integrate into `level_system.gd` as a new state `PHASE_IDENTIFY`.
- Use `AppController` for queueing offline classifications for sync.
