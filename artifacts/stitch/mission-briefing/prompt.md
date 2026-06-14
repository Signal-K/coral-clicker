# Stitch Prompt — Coral Clicker: Mission Briefing Screen

Paste the full block below into Google Stitch as the prompt.
Attach the screenshot at `../reef-catch-level-select/images/puzzle-phase-tactical-console-mobile.html`
(or the mobile puzzle phase screenshot) as visual context.

---

## Prompt

Design two mobile-portrait screens for **Coral Clicker**, a reef restoration puzzle game.
The visual language is a dark tactical console — deep ocean blacks and teals, cyan (#52f2f5) as the
primary accent, amber (#ffe792) for warnings, coral-orange (#fe7e4f) for threats, and a muted
body text on near-black surfaces. Rounded cards, pill badges, thin separator lines.

Both screens are **full-screen modal overlays** that appear before gameplay starts. They sit on top
of the dimmed game viewport (the reef area behind is visible but darkened). The panel itself should
fill most of the screen — not a small floating card. There is a dark semi-transparent scrim behind it.

---

### Screen 1 — Mission Briefing (standard level, e.g. Level 4: The Ledge)

This screen appears when the player taps a level on the world map.
It should feel like a tactical mission briefing — focused, atmospheric, action-oriented.

**Content to show (in order, top to bottom):**

1. **Site label** — small muted caps, e.g. `BAHAMAS · LEVEL 4`
2. **Mission name** — large cyan headline, e.g. `THE LEDGE`
3. Thin horizontal separator line
4. **MISSION GOAL** — section header in muted caps
   - Target species card: species icon placeholder (circular frame) + `Grow 9 Stichopathes`
     in large readable body text. Include a small reef coral silhouette illustration or icon.
5. **YOUR FLEET** — section header in muted caps
   - Horizontal row of small species chips (pill badges) showing each fish the player starts with,
     e.g. `Parrotfish ×2`, `Blue Chromis ×2`. These are the positive fish.
6. **THREATS** — section header in amber/warning caps (only shown if stressors exist)
   - One or two threat chips in error-red, e.g. `✕ Longspine Sea Urchin`. Brief note:
     "Eliminate or contain these — they reduce your coral."
7. **TURN LIMIT** — amber pill badge, e.g. `6 TURNS`
8. **REWARD** — small muted line, e.g. `🪙 40 coins on completion`
9. **BEGIN MISSION** — full-width primary CTA button, cyan fill, dark text, pill shape

The layout should feel information-dense but scannable. Use generous padding.
Scrollable if content overflows. Back arrow in the top-left corner (small).

---

### Screen 2 — Tutorial Briefing (Level 0 only)

This screen replaces the standard briefing for first-time players.
It must do two things: set the scene for the game AND teach the player how to play before they touch anything.

**Content to show (in order, top to bottom):**

1. **Badge** — small pill: `TUTORIAL · THE NURSERY`
2. **Headline** — large cyan: `RESTORE THE REEF`
3. **Tagline** — one sentence in body text:
   "Breed fish, grow coral, and help classify real reef photos for science."
4. Thin separator
5. **YOUR GOAL** — section header
   - `Grow 5 Madracis Sp. coral` in large body text with a coral icon placeholder.
   - Turn limit pill: `10 TURNS — no fail state`
6. Thin separator
7. **HOW TO PLAY** — section header in cyan
   Four steps, each as a small numbered row with an icon placeholder and two lines of text:

   - **1 · Hatch Eggs** — "Eggs appear automatically as your fish breed. Tap an egg to hatch it."
   - **2 · Feed Your Fish** — "Tap a species card, then tap 🍽 FEED to speed up breeding. Costs nutrients."
   - **3 · Manage the Reef** — "Use 🎣 NET to remove harmful species. Use the TEMP and SALIN dials to adjust the environment."
   - **4 · Cycle Turns** — "When you're ready, tap ⏳ CYCLE to advance time. Coral grows each turn if conditions are right."

8. Thin separator
9. **CITIZEN SCIENCE NOTE** — small section, muted, with a small science icon:
   "Your reef photos help real researchers at Zooniverse identify coral species.
   Future levels include a photo identification step before each mission."
10. **BEGIN TUTORIAL** — full-width primary CTA, cyan

---

### Constraints

- Mobile portrait, 390×844px (iPhone 14 baseline).
- No marketing hero image or splash art.
- The game viewport (dark reef) is visible blurred/dimmed behind the panel.
- Use the existing color palette: background `#001016`, surface `#0e1415`, primary cyan `#52f2f5`,
  secondary orange `#fe7e4f`, tertiary amber `#ffe792`, error red `#ffb4ab`,
  body text `#dde4e6`, muted `#7d8890`.
- Rounded panel corners (24px). Pill buttons (999px radius).
- Font: system sans — no custom fonts needed, weight hierarchy through size and opacity.
- Icons: use simple geometric placeholders (circle for species, wave for reef, leaf for nutrients).
  Do not use real photography.

---

### Output requested

- Both screens as separate high-fidelity mobile frames.
- A short DESIGN.md handoff for each: spacing values, colors used, component list, interaction notes.
- One "edge case" variant: what the Mission Briefing looks like with 3+ stressor species.

---

## After Stitch — Implementation Notes

When you have the Stitch output, save screenshots and HTML to:
`Navigation/Coral/artifacts/stitch/mission-briefing/`

Then create a Knowns task in the Coral board scoped to:
- Replace `_show_level_goals()` in `project/level_system.gd` with a new `LevelBriefing.tscn` scene
- Tutorial variant controlled by `is_tutorial: true` in the level definition
- Preserve BEGIN MISSION → `_turn_locked = false` unlock behavior
- Do not change level progression, AppController state, or FishCard layout
