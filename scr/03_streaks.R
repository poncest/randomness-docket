## ============================================================
## DIAGNOSTIC 03: STREAKS
## How often does the same number appear in back-to-back draws?
## Tests whether "repeats feel impossible" intuition holds up.
## Depends on: 01_tidy_data.R (df, numbers_long)
## ============================================================

pacman::p_load(tidyverse, here)

# 1. Rebuild draw index (kept standalone in case run out of order) ----
draw_index_lookup <- df |>
  distinct(draw_date) |>
  arrange(draw_date) |>
  mutate(draw_index = row_number())

appearances <- numbers_long |>
  distinct(draw_date, number) |>
  left_join(draw_index_lookup, by = "draw_date") |>
  arrange(number, draw_index)

# 2. Flag immediate repeats (gap == 1, i.e. appeared in the very next draw) ----
repeats <- appearances |>
  group_by(number) |>
  mutate(gap = draw_index - lag(draw_index)) |>
  ungroup() |>
  filter(gap == 1)

nrow(repeats)          # total count of immediate back-to-back repeats
repeats |> count(number, sort = TRUE)

# 3. Which draws had a repeat from the immediately preceding draw ----
# draw_date already present via `appearances` -- no join needed
# (same trap as 02_droughts.R / 07_drought_evolution.R: joining
# draw_index_lookup again would duplicate draw_date into .x/.y columns)
repeat_draws <- repeats |>
  select(draw_date, number)

repeat_draws

# 4. Expected repeat rate under randomness ----
# For each draw transition, probability a *specific* number repeats
# is roughly (5/white_max) x (5/white_max_next) per number, summed across
# white_max eligible numbers = expected repeats per draw transition.
# Rough current-era approximation:
p_repeat_per_number <- (5 / 69) * (5 / 69)
n_transitions <- nrow(draw_index_lookup) - 1
expected_total_repeats <- p_repeat_per_number * 69 * n_transitions
expected_total_repeats

observed_total_repeats <- nrow(repeats)
observed_total_repeats

## NOTE: compare observed_total_repeats to expected_total_repeats.
## This is a rough single-era approximation (ignores the pre-2015 pool
## size) -- refine with an era-weighted version if this ratio looks
## interesting enough to pursue further.

# 5. Distribution of gap lengths generally (context for how rare gap=1 is) ----
appearances |>
  group_by(number) |>
  mutate(gap = draw_index - lag(draw_index)) |>
  ungroup() |>
  filter(!is.na(gap)) |>
  count(gap) |>
  arrange(gap) |>
  print(n = 15)
