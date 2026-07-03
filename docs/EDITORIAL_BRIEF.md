# EDITORIAL BRIEF
## Working title: "Five Things That Make a Fair Lottery Look Fake"
## (or: "What Randomness Actually Looks Like")

Dataset: NY State Gaming Commission, Powerball Winning Numbers, 2010-present
Status: Diagnostic phase closed. Ready for design.

---

## START HERE (cold-start / fresh chat)

Project structure:
```
scr/
├── 01_frequency.R        <- run first. Builds df, numbers_long, era/white_max/
│                              pb_max columns, expected_counts. Diagnostic 01.
├── 02_droughts.R
├── 03_streaks.R           (superseded by 08 -- kept for reference only)
├── 04_consecutive.R       <- CORE PANEL. Contains Feb 2019 verified example.
├── 05_sums.R               (QC only -- not usable editorially)
├── 06_cumulative.R
├── 07_drought_evolution.R
└── 08_overlap.R           <- SUPPORTING PANEL

data/Lottery_Powerball_Winning_Numbers__Beginning_2010.csv  <- raw source
```

To pick this project back up in a new chat: source `01_frequency.R` first
(builds the core objects everything else depends on), then reference this
brief for what's already decided. No need to re-run 02/03/05/06/07 unless
revisiting those specific findings -- 04 and 08 are the two scripts whose
output actually feeds the final piece.

---

## PIPELINE (processed data + frozen findings)

The diagnostic phase is closed. Design work should read from these
processed files, NOT re-run the diagnostic notebook scripts:

```
scripts/
├── 00_build_processed_powerball.R   <- raw CSV -> clean df + numbers_long
└── 01_freeze_panel_findings.R       <- locks the specific numbers each
                                          surviving panel cites

data/processed/
├── powerball_clean.rds              <- tidied df (era, white_max, pb_max)
├── powerball_numbers_long.rds       <- long-format white balls
└── panel_findings.rds               <- frozen panel-specific stats,
                                          list(panel_1_consecutive,
                                               panel_2_overlap,
                                               panel_3_droughts)
```

Design script pattern:
```r
df <- read_rds(here("data/processed/powerball_clean.rds"))
panel_findings <- read_rds(here("data/processed/panel_findings.rds"))
```

Verified 2026-07-01 (clean R session, both scripts run start to finish):
1,960 draws / 9,800 number rows. `panel_findings$frozen_at` timestamp
confirms freshness -- re-run 01_ only if a panel's underlying logic
actually changes, not for routine iteration.

---



## THE CENTRAL CLAIM

This is not a piece about Powerball. Powerball is the evidence.

The piece is about how humans misjudge randomness -- specifically, that the
patterns people instinctively treat as evidence of rigging (consecutive
numbers, repeats between draws, "overdue" numbers, "hot" numbers) are not
just possible under a fair random process, they're *expected*, and occur
at predictable, quantifiable rates.

Working structure: reader is shown a real, specific, checkable pattern from
actual NY Lottery draws, asked whether it looks suspicious, then shown that
it's exactly what probability predicts.

---

## THE NOTEBOOK: WHAT WAS TESTED, WHAT SURVIVED

Eight diagnostics were run. Every one confirmed the data is statistically
consistent with a fair random process -- no diagnostic found evidence of
bias, drift, or anomaly. That consistent null result, replicated across
independent tests, IS the finding. The question that remained wasn't
"is there an anomaly" but "which of these confirmations is narratively
distinctive enough to carry a panel."

| # | Diagnostic                | Statistical result                          | Editorial verdict |
|---|----------------------------|----------------------------------------------|--------------------|
| 01| Frequency (hot/cold)      | chi-sq p=0.48, no deviation from chance      | QC / appendix |
| 02| Drought magnitude         | Max gap (140) is the *expected* extreme across 69 numbers, not an outlier | Background / myth support |
| 03| Immediate repeats (gap=1) | 750 observed vs. ~710 expected (Bernoulli approx) | Superseded by 08 |
| 04| Consecutive numbers       | 26.4% observed vs. 26.3% simulated (era-matched); includes a real 4-in-a-row draw | **CORE PANEL** |
| 05| Sum of 5 white balls      | Matches theoretical mean almost exactly (152 vs 150, 177 vs 175) -- but entirely explained by the known 2015 rule change | QC only, not usable |
| 06| Cumulative convergence    | CV of observed/expected shrinks from ~1.6 to ~0.15 over the dataset's history; one measurement artifact at the 2015 era boundary | Background / mechanism, not a standalone panel |
| 07| Drought evolution (live)  | Current active drought tracks inside a 200-sim resampling band throughout | Background / myth support (folds into 02) |
| 08| Consecutive-draw overlap  | Current era: 32.0% observed vs. 32.2% hypergeometric expected, chi-sq p=0.79 on collapsed bins (earlier uncollapsed run gave p=0.95 but violated minimum-expected-count assumption); all-eras figure (34.3%) mixes pool sizes and is diagnostic context only, not the published number | **SUPPORTING PANEL** |

---

## THE SURVIVING PANELS

### Panel 1 (core): Consecutive numbers
**The hook:** On February 20, 2019, a real $280M Powerball drawing produced
27-49-50-51-52 -- four numbers in a row. Verified against multiple
independent sources.
**The reveal:** About one in four Powerball drawings contains at least one
consecutive pair (26.4% observed vs. 26.3% theoretical, era-matched).
**Backup evidence (not shown, held in reserve):** 26 separate drawings
contain a run of three consecutive numbers, in case the Feb 2019 draw is
challenged as a one-off.
**Framing question:** "Would these numbers look random to you?"

### Panel 2 (supporting): Shared numbers between consecutive draws
**The hook:** About one in three drawings shares at least one white ball
with the previous drawing -- 32.0% observed, current era (2015-present,
n=1,369). Era-matched to Panel 1's own observed/expected convention;
supersedes the earlier 34.3% all-eras figure, which mixed pre- and
post-2015 pool sizes and is no longer the headline (see note below).
**The reveal:** Matches the hypergeometric distribution almost exactly --
32.2% expected, chi-square p=0.79, collapsed bins, current era. (An
earlier uncollapsed run gave p=0.95 but violated the minimum-expected-
count assumption; superseded by the collapsed-bin version above.)
**Framing question:** "The next drawing shared two numbers with the last
one. Suspicious?" (revised from "Today's ... yesterday's" -- the hero
pair is Feb 9/11, not literally consecutive calendar days, so
today/yesterday overstates the framing.)

> **Note on the 34.3% figure:** `panel_findings.rds$panel_2_overlap`
> still stores `pct_at_least_one_shared_all_eras` (34.3%) as a frozen
> field, but it is no longer the published number. It mixed eras with
> different white-ball pool sizes (pre-2015 vs. 2015-present) against a
> current-era-only hypergeometric expectation, which is an apples-to-
> oranges comparison and breaks the era-matching standard Panel 1 set.
> Treat 34.3% as historical/diagnostic context only, not evidence -- the
> published observed/expected pair is 32.0%/32.2%, both current era.

### Panel 3 (myth support): Long droughts
**The hook:** A given number can go 100+ draws without appearing.
**The reveal:** That's not just possible, it's the *expected* extreme once
you're watching 69 numbers for thousands of draws -- confirmed both by a
one-shot max-gap analysis (02) and a live simulation-band comparison (07).
**Framing question:** "Number 23 hasn't hit in 48 drawings. Overdue?"

### Panel 4 (background, likely text/caption rather than a chart):
Frequency variation and convergence
**The material:** No number's frequency deviates from chance (01); early
volatility in any number's observed/expected ratio is 15-300x larger than
its long-run volatility, shrinking toward stability over time (06).
**Role:** Explains *why* the other three panels work -- small samples
produce apparent patterns, which wash out over the full dataset. This is
mechanism, not a standalone "gotcha," so it likely lives as supporting
text/appendix rather than a fourth panel with its own reveal.

---

## WHAT WAS CUT AND WHY

- **03 (immediate repeats):** Same underlying finding as 08, but 08's
  framing (shared-number-count distribution vs. hypergeometric) is more
  intuitive and has a cleaner theoretical benchmark. Kept in notebook,
  not in final piece.
- **05 (sums):** The observed pattern is entirely explained by the known
  2015 pool-size rule change (5x(N+1)/2 going from 150 to 175). No
  editorial content -- administrative history, not a property of
  randomness. Kept as QC confirmation only.
- **07 (running-max drought):** Original version (running max of completed
  droughts) was killed for plateauing mechanically, same failure mode as
  "tallest person ever." Rebuilt as live current-drought tracking; the
  rebuilt version supports panel 3 but doesn't need its own separate slot.

---

## OPEN DESIGN QUESTIONS FOR NEXT PHASE

1. Format: static multi-panel explainer (primary) vs. interactive
   companion (e.g. "spot the real lottery" or "which looks least random"
   Shiny widget) -- prior discussion favors static as primary, interactive
   as a secondary companion piece, consistent with existing portfolio
   strength (one idea, one image).
2. Panel count: 3 core/supporting panels (04, 08, 02+07) plus background
   text (01+06), or does background material need its own visual treatment?
3. Whether the Feb 20, 2019 draw needs any additional verification/sourcing
   note in the final caption, given it's the piece's central evidentiary
   anchor.
4. Deferred QC items (still open, publication-stage only): multiplier
   missingness investigation, Double Play launch-date confirmation.

---

## DEFERRED (not yet actioned)
- [ ] Investigate 210 missing multiplier values
- [ ] Confirm double_play_winning_numbers first non-NA row aligns with
      Aug 2021 Double Play launch date
