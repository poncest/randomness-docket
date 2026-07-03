## ============================================================
## DIAGNOSTIC 02: DROUGHTS
## How long does each number go between appearances?
## Tests the "overdue number" intuition against actual gap distributions.
## Depends on: 01_tidy_data.R (df, numbers_long)
## ============================================================

pacman::p_load(tidyverse, here)

# 1. Build per-number draw-index sequences ----
# draw_index = sequential position of each draw (1 = earliest), so gaps
# are measured in "number of draws" not calendar time -- avoids conflating
# the drought with the 2021 schedule change (2x/week -> 3x/week).

draw_index_lookup <- df |>
  distinct(draw_date) |>
  arrange(draw_date) |>
  mutate(draw_index = row_number())

appearances <- numbers_long |>
  distinct(draw_date, number) |>
  left_join(draw_index_lookup, by = "draw_date") |>
  arrange(number, draw_index)

# 2. Compute gaps between consecutive appearances per number ----
gaps <- appearances |>
  group_by(number) |>
  mutate(gap = draw_index - lag(draw_index)) |>
  filter(!is.na(gap)) |>
  ungroup()

# 3. Longest drought per number ----
longest_droughts <- gaps |>
  group_by(number) |>
  summarise(
    max_gap = max(gap),
    mean_gap = mean(gap),
    n_appearances = n() + 1,
    .groups = "drop"
  ) |>
  arrange(desc(max_gap))

longest_droughts

# 4. Current drought (as of most recent draw) ----
last_draw_index <- max(draw_index_lookup$draw_index)

current_droughts <- appearances |>
  group_by(number) |>
  summarise(last_seen = max(draw_index), .groups = "drop") |>
  mutate(current_drought = last_draw_index - last_seen) |>
  arrange(desc(current_drought))

current_droughts

# 5. Quick distribution check ----
# Under random draws, gap length should follow roughly a geometric
# distribution. Eyeball whether the observed max droughts look like
# plausible tail events or actual outliers.
hist(gaps$gap, breaks = 40, main = "Distribution of gaps between appearances (all numbers)")

summary(gaps$gap)

# 6. Expected max drought under randomness (rough benchmark) ----
# For a fair process with per-draw probability p = 5/69 (current era),
# expected longest gap over ~1960 draws gives a rough sense of what
# "normal" looks like -- compare against observed max_gap values above.
p_current_era <- 5 / 69
n_draws <- nrow(draw_index_lookup)
# Geometric distribution: P(gap > g) = (1-p)^g -- solve for g at small tail prob
expected_max_gap <- log(0.01) / log(1 - p_current_era)
expected_max_gap

## NOTE ON THE BENCHMARK ABOVE (superseded):
## log(0.01)/log(1-p) answers "what gap has a 1% chance on a SINGLE
## opportunity" -- not "what's the expected max across ~140 opportunities
## per number, then across 69 numbers." That's two layers of extreme-value
## inflation the naive formula doesn't capture. Simulation gives a much
## better benchmark: per-number max gap (n~140, p=5/69) has mean ~74,
## p95 ~106; the max ACROSS all 69 numbers has mean ~130, p95 ~162.
## Observed max (140, number 1) sits almost exactly at that second
## benchmark's median -- i.e. not an outlier, but the expected extreme
## of watching 69 processes run for ~140 draws each.

## 7. TYPICAL vs. WORST drought per number (psychologically the sharper contrast) ----
drought_contrast <- gaps |>
  group_by(number) |>
  summarise(
    mean_gap = mean(gap),
    p95_gap = quantile(gap, 0.95),
    max_gap = max(gap),
    .groups = "drop"
  ) |>
  arrange(desc(max_gap))

drought_contrast

## 8. ERA-SPLIT gaps -- p changed at 2015-10-07 (5/59 -> 5/69), so mixing
## eras inflates apparent variability. Recompute gaps within each era only.
appearances_era <- numbers_long |>
  distinct(draw_date, number) |>
  left_join(draw_index_lookup, by = "draw_date") |>
  left_join(df |> distinct(draw_date, era), by = "draw_date") |>
  arrange(number, era, draw_index)

gaps_by_era <- appearances_era |>
  group_by(number, era) |>
  mutate(gap = draw_index - lag(draw_index)) |>
  filter(!is.na(gap)) |>
  ungroup()

gaps_by_era |>
  group_by(era) |>
  summarise(
    mean_gap = mean(gap),
    p95_gap = quantile(gap, 0.95),
    max_gap = max(gap),
    n_gaps = n(),
    .groups = "drop"
  )

## NOTE: current-era (5/69) theoretical mean wait = 69/5 = 13.8 draws;
## pre-2015 (5/59) theoretical mean wait = 59/5 = 11.8 draws -- roughly
## a 17% increase. Confirm gaps_by_era's mean_gap tracks this before
## drawing any era-mixed conclusions.

