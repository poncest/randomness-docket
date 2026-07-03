# BRAND GUIDE v2 — "Five Things That Make a Fair Lottery Look Fake"
Working name: **The Randomness Docket**
Status: v2 — sampler-approved directions folded in. Supersedes draft v1.
Implementation files: `quarto/powerball-docket.scss` · `quarto/theme-docket.R`

────────────────────────────────────────────────────────────
## CONCEPT
────────────────────────────────────────────────────────────
Not "Pacific Currents" (PDC's dark/ocean/urgent register). This piece is
calmer and more procedural — the visual language of **evidence being
weighed**, not a crisis being reported. Light, paper-toned, restrained.
The reader is a juror looking at exhibits, not an audience being warned.

This also functions as the tonal opposite of PDC on the portfolio:
dark/urgent/climate vs. light/procedural/statistics. Deliberate variation,
not inconsistency — worth noting given the W25 portfolio-variation
watchlist flag (burgundy/gray/cream + dashed-reference-line repetition
across pieces). This piece does NOT reuse PDC's teal/navy-dark system,
and does NOT reuse the burgundy/gray/cream system — a third, distinct
register.

**v2 principle:** the concept was always distinctive; the v1 *execution*
defaulted (Inter, the standing MetBrewer subset, flat navy balls) and
quietly undercut it. v2 aligns every execution choice to the docket idea.

────────────────────────────────────────────────────────────
## COLOR — graphite structure, two chromatic signals only
────────────────────────────────────────────────────────────
Retired the `met.brewer("Ingres")[c(2,4,7)]` standing default. Navy is
gone as a structural color — it sat one step from "expected" blue and
diluted the piece's one recurring signal. New rule: **structure is warm
graphite, and blue + gold are the ONLY two chromatic colors.** Every time
color appears, it means something.

| Role                      | Hex       | Usage                                     |
|----------------------------|-----------|-------------------------------------------|
| **Graphite** (structure)   | `#24211c` | Headings, ball rings, axes, anchors, rules|
| **Blue** (expected/model)  | `#2e6f9e` | EXPECTED / simulated / theoretical values |
| **Gold** (observed/reality)| `#a06e2a` | OBSERVED / real-world values, the Powerball|
| Paper (background)         | `#f5f1e8` | Page + panel background — warm ivory       |
| Body text                  | `#4a463d` | Secondary body copy                        |
| Muted (secondary text)     | `#8a8272` | Captions, eyebrows, source lines           |
| Rule (hairlines)           | `#ddd6c6` | Dividers, gridlines                        |

Changes from v1: navy `#06314e` retired as structure → graphite `#24211c`;
blue `#2e77ab` → `#2e6f9e`; gold warmed from muddy `#7e5522` → ochre
`#a06e2a` (reads as reality, not sediment); paper warmed `#faf9f6` →
`#f5f1e8` (case-file/manila tone reinforces the docket).

Rule, unchanged and load-bearing: **gold = what actually happened,
blue = what the model predicts.** Hold this mapping constant across all
four panels — it's the piece's one recurring visual grammar, doing the
job PDC's teal-trigger did. The SCSS and R palettes are byte-identical so
prose balls and chart lines read as one system.

────────────────────────────────────────────────────────────
## TYPOGRAPHY — all free Google Fonts (no Adobe)
────────────────────────────────────────────────────────────
Inter retired. It was reached by subtraction ("not mono, not technical")
and landed on the blandest grotesque available — and reads as app UI, not
testimony. v2 uses a Caslon-lineage serif to carry the first-person juror
voice, with a grotesque only for labels.

- **Display / headlines:** Libre Caslon Display (400) — high-contrast,
  legal/archival heritage.
- **Body / voice:** Libre Caslon Text (400/700 + italic) — the juror prose.
- **Labels / eyebrows / captions:** Archivo (500/600/700).
- No monospace — this isn't a data-source-heavy technical piece like PDC;
  a mono would read as borrowed, not intentional.
- Eyebrow convention (carried from PDC): small caps, letter-spacing
  ~0.18–0.22em, Archivo, muted or gold — e.g. "ACTUAL POWERBALL DRAWING".

All three families are free on Google Fonts and imported by the SCSS; the
R side registers the identical families via `sysfonts::font_add_google()`
so figures match. (Offline/CI render: download the three `.ttf`s once and
swap to `font_add()` with local paths.)

────────────────────────────────────────────────────────────
## THE POWERBALL AS EXHIBIT
────────────────────────────────────────────────────────────
The Powerball is the strongest object in the piece — do not flatten it to
a navy dot. Render the five white balls as **physical exhibits**: paper-
white radial fill, 1.5px graphite ring, inked number, soft drop shadow —
evidence a juror could pick up. The single Powerball takes the **observed
gold** accent, NOT lottery-red: restraint, and it keeps the branding risk
low. See `.pb` / `.pb--power` in the SCSS.

────────────────────────────────────────────────────────────
## VOICE
────────────────────────────────────────────────────────────
- First-person observational, never third-person unverified claims.
  ("That doesn't look random." not "Most people say no.") — standing rule.
- Question → pause → reveal → evidence, per panel. Every panel should be
  answerable in the reader's head before the stat appears.
- No causal language beyond what's tested. This piece is entirely
  "consistent with a fair random process" — never drift into implying the
  lottery IS random (unfalsifiable) vs. IS CONSISTENT WITH random (what
  the diagnostics actually show).
- Observed / Expected as primary labels (matches diagnostic vocabulary and
  frozen data field names) — plain-language subcaption underneath for
  accessibility, not a label swap.

────────────────────────────────────────────────────────────
## LAYOUT PATTERN (closeread)
────────────────────────────────────────────────────────────
Reuse PDC's structural skeleton, retheme only:
- `header-row` (eyebrow + optional mark)
- `standfirst` intro block
- `cr-section` per panel, sticky figure + narrative steps referencing
  `@cr-id` anchors
- `methodology` block for Panel 4 (mechanism) — text/appendix, not its own
  cr-section, per the brief's editorial verdict
- `data-sources`, `tools-block`, `licence-block`, `footer-line` — same
  components, retheme colors only
- **Carry forward the manual scroll-listener JS verbatim.** Same
  Closeread v1.0.1 + Scrollama bug applies regardless of theme.

────────────────────────────────────────────────────────────
## IMPLEMENTATION (R / Quarto)
────────────────────────────────────────────────────────────
- **HTML theme:** `_quarto.yml` →
  `format: { closeread-html: { theme: powerball-docket.scss } }`
- **Figures:** `source("theme-docket.R")` in the setup chunk. Every plot
  inherits `theme_docket()`; use `scale_colour_manual(values = pb_pal)` to
  lock gold = observed / blue = expected.
- **Sync:** SCSS and R carry the identical hex palette — change a color in
  one, mirror it in the other.
- **Gotcha:** `showtext_opts(dpi = 300)` must match knitr `fig-dpi: 300`,
  or Caslon renders too small in the PNGs.

────────────────────────────────────────────────────────────
## WHAT NOT TO CARRY FROM PDC
────────────────────────────────────────────────────────────
- No dark background, no teal accent, no Big Shoulders Display
- No JetBrains Mono (no technical/coordinate data being displayed)
- No "not an official X" disclaimer eyebrow — different risk profile (this
  isn't a forecast mistaken for authoritative; the risk is the OPPOSITE —
  readers assuming a fair process is rigged)

────────────────────────────────────────────────────────────
## CHANGELOG v1 → v2
────────────────────────────────────────────────────────────
- Navy retired as structure → warm graphite `#24211c`
- Palette reduced to two chromatic signals (blue + gold only)
- Gold warmed `#7e5522` → `#a06e2a`; blue `#2e77ab` → `#2e6f9e`;
  paper warmed `#faf9f6` → `#f5f1e8`
- Inter retired → Libre Caslon Display + Text (voice), Archivo (labels)
- Powerballs rendered as physical exhibits; single ball takes gold accent
- Added R/Quarto implementation files as the canonical source of truth
