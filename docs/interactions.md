# Reef Interaction Notes

## Simple ecology rules worth exposing in v0.1-v0.2

- Helpful fish should not only say they "help" a coral. They should imply why: grazing algae, cleaning surfaces, or protecting the reef from a threat.
- Harmful fish should feel like pressure, not randomness. Their cards and result text should point at the mechanism.
- Water settings should amplify or soften those fish effects instead of replacing them.

## Trigger-linked interaction patterns

### Heat pressure

- Warm water increases coral stress.
- Helpful fish still matter, but the same fish mix produces weaker results.
- Result copy should mention that the reef was fighting heat, not just "missing target."

### Runoff / salinity dip

- Low salinity can stand in for stormwater or freshwater runoff.
- Use it to make shallow branching targets more fragile for one or two missions.
- This creates a reason to spend coins on water tuning instead of only eggs.

### Grazer protection

- Herbivore fish reduce algae pressure and make coral gains more reliable.
- In UI terms, these species should be tagged as stabilizers or helpers.

### Predator control

- A predator that suppresses an active stressor should feel like a tactical answer.
- This is best used when the game introduces a new stressor and wants a clear counterplay lesson.

## Engine-facing translation

- Keep each loop to a small integer modifier so the board stays legible.
- Prefer `-1`, `0`, `+1` adjustments on coral growth or species support.
- Only stack two ecology modifiers in the same turn unless a late-game level is built to teach compounding effects.
