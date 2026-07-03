## ============================================================
## DIAGNOSTIC 06: CUMULATIVE CONVERGENCE
## As draws accumulate, does each number's observed/expected ratio
## settle toward 1.0? This is the "how quickly does randomness
## converge" angle (Option C) -- candidate mechanism within the
## broader "randomness looks non-random" hypothesis.
##
## v2: primary signal is now cross-number SPREAD over time (coefficient
## of variation across all 69 numbers' running observed/expected ratios)
## rather than 69 individual spaghetti lines -- much cleaner "does
## variability shrink toward expectation" story than trying to read
## 69 overlapping trajectories.
##
## Depends on: 01_tidy_data.R (df, numbers_long)
## ============================================================

pacman::p_load(tidyverse, here)

# 1. Build draw index + per-draw eligibility (reused from 02/03) ----
draw_index_lookup <- df |>
  distinct(draw_date, white_max) |>
  arrange(draw_date) |>
  mutate(draw_index = row_number())

appearances <- numbers_long |>
  distinct(draw_date, number) |>
  mutate(appeared = 1L)

# 2. Full grid: every eligible (number, draw) combination ----
grid <- draw_index_lookup |>
  tidyr::crossing(number = 1:69) |>
  filter(white_max >= number) |>
  left_join(appearances, by = c("draw_date", "number")) |>
  mutate(appeared = replace_na(appeared, 0L))

# 3. Running observed/expected ratio per number ----
cumulative <- grid |>
  arrange(number, draw_index) |>
  group_by(number) |>
  mutate(
    cum_observed = cumsum(appeared),
    cum_expected = cumsum(5 / white_max),
    cum_ratio = cum_observed / cum_expected,
    draws_since_eligible = row_number()
  ) |>
  ungroup()

# 4. PRIMARY SIGNAL: cross-number spread of cum_ratio, over calendar time ----
# At each draw_date, look across all 69 (eligible) numbers' cum_ratio
# values and compute the coefficient of variation (sd / mean). Under
# pure randomness, this should shrink as more draws accumulate --
# early on, a few draws create big apparent differences between
# numbers; late, differences wash out toward the ~1.0 expectation.
spread_over_time <- cumulative |>
  filter(draws_since_eligible >= 5) |>  # skip the first few draws (undefined/unstable ratios)
  group_by(draw_date) |>
  summarise(
    n_numbers = n(),
    mean_ratio = mean(cum_ratio),
    sd_ratio = sd(cum_ratio),
    cv_ratio = sd_ratio / mean_ratio,
    .groups = "drop"
  )

ggplot(spread_over_time, aes(draw_date, cv_ratio)) +
  geom_line() +
  geom_smooth(se = FALSE) +
  labs(
    title = "Spread of observed/expected ratios across all 69 numbers, over time",
    subtitle = "Coefficient of variation -- should shrink as draws accumulate under pure randomness",
    x = NULL, y = "CV of cum_ratio across numbers"
  )

## NOTE: watch for a discontinuity around Oct 2015 -- numbers 60-69
## re-enter with draws_since_eligible = 1 right when the rest of the
## field has thousands of draws behind it, which could create an
## artificial spike in cv_ratio right at the era boundary. If so,
## consider computing spread separately per era rather than pooled.

# 5. Supporting visual: individual trajectories, LIMITED to a few
#    representative numbers (not all 69 -- avoids spaghetti) ----
sample_numbers <- c(1, 26, 61, 65)

cumulative |>
  filter(number %in% sample_numbers) |>
  ggplot(aes(draws_since_eligible, cum_ratio, color = factor(number))) +
  geom_line() +
  geom_hline(yintercept = 1, linetype = "dashed") +
  labs(
    title = "Cumulative observed/expected ratio over time (sample of 4 numbers)",
    subtitle = "Dashed line = perfect convergence to expectation",
    x = "Draws since number became eligible",
    color = "Number"
  )

# 6. Quantify: early vs. late volatility, across all numbers with enough history ----
volatility_check <- cumulative |>
  group_by(number) |>
  filter(n() >= 200) |>
  summarise(
    early_sd = sd(cum_ratio[draws_since_eligible <= 100]),
    late_sd = sd(cum_ratio[draws_since_eligible > max(draws_since_eligible) - 100]),
    .groups = "drop"
  ) |>
  mutate(sd_ratio = early_sd / late_sd)

volatility_check
summary(volatility_check$sd_ratio)

## NOTE: sd_ratio > 1 across most numbers supports the convergence
## story (early volatility genuinely settles down). If sd_ratio is
## close to 1, convergence isn't visually or statistically distinct
## enough to carry a chart on its own -- likely a supporting panel
## rather than the spine. The cv_ratio-over-time plot (step 4) is the
## stronger candidate visual either way -- one clean line/curve rather
## than a volatility-ratio table.