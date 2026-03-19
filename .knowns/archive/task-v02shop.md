---
id: v02shop
title: "v0.2: Implement In-level Shop"
status: done
priority: high
labels:
  - ui
  - economy
  - shop
createdAt: '2026-03-12T21:22:00Z'
updatedAt: '2026-03-12T21:22:00Z'
timeSpent: 0
---

# Implement In-level Shop

## Description

A shop UI during gameplay where players can spend persistent Coins to buy items (e.g., Fish Eggs).

## Requirements

- Present as a sliding panel or floating button.
- List items like "Rare Fish Egg", "Nutrient Boost", "Stressor Repellent".
- Deduct persistent Coins upon purchase.
- Update current level's materials/nutrients immediately.
- (B) Sketch elements: sidebar or floating button, scrollable item list, coin balance.

## Technical Notes

- Create `scenes/ui/shop_panel.tscn`.
- Call from `level_system.gd` via a new button.
