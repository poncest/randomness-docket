## ============================================================
## DIAGNOSTIC 04: CONSECUTIVE NUMBERS WITHIN A DRAW
## How often do sequential numbers (e.g. 23-24-25) appear together?
## Tests the "sequences feel impossible" intuition.
## Depends on: 01_tidy_data.R (df)
## ============================================================

pacman::p_load(tidyverse, here)

# 1. For each draw, sort the 5 white balls and check for adjacent pairs ----
consecutive_check <- df |>
  select(draw_date, n1, n2, n3, n4, n5) |>
  rowwise() |>
  mutate(
    sorted = list(sort(c(n1, n2, n3, n4, n5))),
    diffs = list(diff(sorted)),
    has_consecutive_pair = any(diffs == 1),
    n_consecutive_pairs = sum(diffs == 1),
    longest_run = {
      d <- diffs
      max_run <- 1L
      current_run <- 1L
      for (i in seq_along(d)) {
        if (d[i] == 1) {
          current_run <- current_run + 1L
          max_run <- max(max_run, current_run)
        } else {
          current_run <- 1L
        }
      }
      max_run
    }
  ) |>
  ungroup() |>
  select(draw_date, has_consecutive_pair, n_consecutive_pairs, longest_run)

# 2. Summary ----
consecutive_check |> count(has_consecutive_pair)
mean(consecutive_check$has_consecutive_pair)   # proportion of draws with >=1 adjacent pair

consecutive_check |> count(longest_run)

# 3. Distribution of run lengths ----
hist(consecutive_check$n_consecutive_pairs, breaks = 0:5,
     main = "Number of adjacent pairs per draw")

# 4. Rough theoretical benchmark (current era, 69 numbers, 5 drawn) ----
# Approximate probability at least one adjacent pair exists among 5 numbers
# drawn without replacement from 1:69 -- simulate rather than derive closed-form,
# since exact combinatorics get messy fast.
set.seed(123)
sim_draws <- replicate(20000, sort(sample(1:69, 5)), simplify = FALSE)
sim_has_consecutive <- map_lgl(sim_draws, ~ any(diff(.x) == 1))
mean(sim_has_consecutive)

## NOTE: compare mean(consecutive_check$has_consecutive_pair) [observed,
## all eras mixed] against mean(sim_has_consecutive) [simulated benchmark,
## current era pool size only]. If observed proportion (once restricted
## to post-2015 draws for a fair comparison) lands close to the simulated
## rate, human intuition about "impossible" sequences is simply wrong --
## which could be a strong visual hook on its own.

# 5. Restrict to current era only for a fair apples-to-apples check ----
consecutive_check_current_era <- df |>
  filter(draw_date >= ymd("2015-10-07")) |>
  select(draw_date, n1, n2, n3, n4, n5) |>
  rowwise() |>
  mutate(has_consecutive_pair = any(diff(sort(c(n1, n2, n3, n4, n5))) == 1)) |>
  ungroup()

mean(consecutive_check_current_era$has_consecutive_pair)

# 6. Recover the ACTUAL draws behind the longest runs -- annotation material ----
# Rebuild with the sorted ball values retained (not just summary stats)
runs_with_numbers <- df |>
  select(draw_date, n1, n2, n3, n4, n5) |>
  rowwise() |>
  mutate(
    sorted_balls = paste(sort(c(n1, n2, n3, n4, n5)), collapse = "-"),
    diffs = list(diff(sort(c(n1, n2, n3, n4, n5)))),
    longest_run = {
      d <- diffs
      max_run <- 1L
      current_run <- 1L
      for (i in seq_along(d)) {
        if (d[i] == 1) {
          current_run <- current_run + 1L
          max_run <- max(max_run, current_run)
        } else {
          current_run <- 1L
        }
      }
      max_run
    }
  ) |>
  ungroup() |>
  select(draw_date, sorted_balls, longest_run)

# The headline example -- longest run of 4 consecutive numbers
runs_with_numbers |> filter(longest_run == 4)

# All draws with a run of 3 (secondary examples, useful if the run-of-4
# draw needs a supporting second example in the same panel)
runs_with_numbers |> filter(longest_run == 3)

## NOTE: sorted_balls gives the exact winning numbers for the annotation,
## e.g. "14-15-16-17-52" -- draw_date pins it to a specific, checkable
## drawing, which is far more persuasive than a percentage alone.