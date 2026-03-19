---
name: Coral Clicker project vision & core design decisions
description: Settled design decisions for Coral Clicker — game loop, core mechanic, currencies, platform
type: project
---

Coral Clicker is a relaxed puzzle game with embedded citizen science. It is part of the Star Sailors ecosystem (starsailors.space).

**The identify phase IS the level config** — not a dialog, not optional. Player sees a real Zooniverse reef photo, tags species, that drives the puzzle goal (replicate that reef). Their classification is saved to Supabase for future Zooniverse submission. This is the single most important thing to get right.

**Why:** User was very clear ("YOU'RE MISSING THE POINT") that the classification drives the content.

**How to apply:** Never treat the identify phase as a skip-able tutorial. It must be a full-screen experience and the gateway to every level.

---

**Breeding is automatic** — 30-45s real-time timed event, NEVER paused. No Breed button. Eggs appear in reef viewport. Player TAPS egg to hatch, then DRAGS hatched fish to a zone. A flashing warning precedes each egg appearance. Population cap exceeded = eggs still hatch but fish starve (no hard block). Players influence breeding via environment and bought fish eggs (coins).

**Why:** Removes busywork button; makes the reef feel alive.

---

**Currencies:** Nutrients (level-local, spent on fish feeding) + Coins (global, earned on level completion, speed bonus for fewer turns). Stars/Crystals hidden until v0.3.

**IMPORTANT — environment dials do NOT cost nutrients.** They cost COINS. Salinity/temperature are physical conditions unrelated to food supply. Each dial notch costs ~5 coins. This is a settled design decision as of 2026-03-16.

---

**Target:** Mobile-first PWA (Godot → React Native / Next.js). All 3 platforms. Portrait primary.

**Sprites:** 248×248px. Need to regenerate from tools/sprites/generate_sprites.py.

**Sound sprint:** Starting 2026-03-22.

**First release:** 10 levels, full game. Sequential unlock. World map nav.

**Fail state:** Restart the level (no soft fail / partial coins).

**Offline rewards:** Coins are HELD until Supabase sync — not given immediately. No offline indicator shown to player (identical behaviour). A "Reward pending sync" notice appears on Level End screen if offline.

**Eggs / net:** Feed/Net actions appear as overlay icons on the reef viewport (NOT inside the fish card). Net removes fish from reef entirely (no Tank transfer). Net is limited to 2 uses per turn. Species at population 0 = EXTINCT — no revive.

**Turn end:** Triggers when nutrients hit 0 OR player manually presses End Turn.

**Identify phase:** Shows ALL species chips (not filtered). "I'm not sure" skips the WHOLE phase. Zoom/pan enabled on image. Min 1 species to confirm.

**World map:** The Tank is at position 0, always unlocked. Linear unlock (N→N+1). Completed levels show gallery of all images seen when replayed. Sites are geographically themed (Caribbean/W. Atlantic journey). See reef-sites-geography.md.

**Level 0:** Tutorial mission — scripted, no Zooniverse image, no fail state, no stressors. Teaches full loop with overlays. See task-tutorial-level0.md.

**Sound:** Ambient audio switches per phase (identify / puzzle / level end). Backing music deferred to v0.2. Sound settings only in main Settings screen.

**Directional sprites:** Use Godot AnimationPlayer for left/right fish facing — not GDScript flip.

**Star Sailors integration v0.1:** Just save user annotations + progress to shared Supabase. No cross-game economy yet.
