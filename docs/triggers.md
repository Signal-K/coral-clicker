# Trigger System

## Current game rule

- Each turn starts with 2 actions.
- Netting costs 1 action.
- Each salinity or temperature notch costs 1 action and 5 coins.
- Fast clears bank +1 carryover action for a later mission.

## Ecological feedback loops to represent

### 1. Warm water -> coral stress -> algal takeover

Caribbean corals under sustained heat bleach, lose energy, and become easier for algae to overgrow. In game terms, a warm setting should make target coral growth less efficient unless herbivore pressure is strong.

Suggested modifier:
- `temperature = warm` -> `target_coral_growth -1`
- If herbivore helper fish are present at healthy population -> cancel half the penalty

### 2. Cold snap -> slower metabolism -> weaker fish support

Cooler-than-preferred water reduces feeding and growth rates for many tropical reef fish. This is less catastrophic than heat stress, but it should reduce the payoff from adding the wrong warm-water helper fish.

Suggested modifier:
- `temperature = cold` and helper fish prefer warm water -> helper support contribution `-1`

### 3. Low salinity -> coral stress after runoff

Heavy rainfall and runoff lower coastal salinity and can stress corals, especially in shallow reefs. Some hardy or sheltered species cope better, but many branching corals lose performance quickly.

Suggested modifier:
- `salinity = low` -> branching coral target gets `-1 growth`
- Stressor levels get `+1 pressure` in runoff-themed missions

### 4. Balanced herbivores -> algae suppression -> stronger coral recovery

Parrotfish and similar grazers suppress algae that otherwise compete with coral recruits. This is one of the clearest positive loops to surface in a reef-restoration game.

Suggested modifier:
- If a positive herbivore species is present and water is within one step of preferred conditions -> `target_coral_growth +1`

### 5. Predator return -> urchin control -> coral protection

Urchin outbreaks can strip or damage reef structure, while predators that keep grazers or destructive invertebrates in check can stabilize the system. The game already hints at this with Creole Wrasse vs urchins.

Suggested modifier:
- Active urchin stressor present -> `target_coral_growth -1`
- If predator counter-species is present -> remove that penalty and grant `stability +1`

## Recommended implementation order

1. Apply one simple heat penalty and one herbivore bonus first.
2. Add low-salinity runoff penalties only on levels that explicitly teach stressors.
3. Gate more complex cascades behind later content once tutorial readability is stable.
