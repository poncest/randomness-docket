## 1. LOAD PACKAGES & SETUP ----
if (!require("pacman")) install.packages("pacman")
pacman::p_load(
  tidyverse, ggtext, showtext, janitor, ggrepel,      
  scales, glue, skimr
)

### |- figure size ----
camcorder::gg_record(
  dir    = here::here("temp_plots"),
  device = "png",
  width  = 10,
  height = 6.5,
  units  = "in",
  dpi    = 320
)

# Source utility functions
source(here::here("R/utils/fonts.R"))
source(here::here("R/utils/social_icons.R"))
source(here::here("R/themes/base_theme.R"))
source(here::here("R/utils/snap.R"))

## 2. READ IN THE DATA ----

df_raw <- read_csv(
  here::here("data/Lottery_Powerball_Winning_Numbers__Beginning_2010.csv")) |> 
  clean_names()


## 3. EXAMINING THE DATA ----
glimpse(df_raw)
skimr::skim_without_charts(df_raw)


## 4. TIDY DATA ----

## 4.1 Parse dates, split winning numbers, flag rule-change eras ----
#
# Powerball rule changes affecting this dataset's date range (2010-present):
#   pre 2012-01-15  : white balls 1-59, Powerball 1-39
#   2012-01-15 to
#   2015-10-06      : white balls 1-59, Powerball 1-35
#   2015-10-07 on   : white balls 1-69, Powerball 1-26 (current)
#
# white_max / pb_max are used downstream to compute era-adjusted
# expected frequencies -- without this, numbers 60-69 would look
# artificially "cold" simply because they weren't eligible before
# Oct 2015.

df <- df_raw |>
  mutate(draw_date = mdy(draw_date)) |>
  separate_wider_delim(
    winning_numbers,
    delim = " ",
    names = c("n1", "n2", "n3", "n4", "n5", "powerball")
  ) |>
  mutate(across(n1:powerball, as.integer)) |>
  mutate(
    era = case_when(
      draw_date < ymd("2012-01-15") ~ "2010-01: white 1-59, PB 1-39",
      draw_date < ymd("2015-10-07") ~ "2012-15: white 1-59, PB 1-35",
      TRUE                          ~ "2015-present: white 1-69, PB 1-26"
    ),
    white_max = if_else(draw_date < ymd("2015-10-07"), 59, 69),
    pb_max = case_when(
      draw_date < ymd("2012-01-15") ~ 39,
      draw_date < ymd("2015-10-07") ~ 35,
      TRUE                          ~ 26
    )
  )

# QC check: confirm structure
colnames(df)
glimpse(df)

## 4.2 Reshape white balls to long format ----
# One row per (draw_date, white-ball position) -- 1,960 draws x 5 = 9,800 rows
numbers_long <- df |>
  pivot_longer(n1:n5, names_to = "position", values_to = "number")

# QC check
nrow(numbers_long) == nrow(df) * 5

## 5. ERA-ADJUSTED EXPECTED VS. OBSERVED FREQUENCY ----
#
# Raw frequency counts are misleading across rule changes: a number
# only eligible since Oct 2015 (e.g. 60-69) will always show fewer
# raw appearances than a number eligible since 2010, even under
# perfectly random draws. Expected count is built by summing each
# number's per-draw probability (5 / white_max) only across draws
# where it was actually eligible to be drawn.

draws <- df |> distinct(draw_date, white_max)

expected_counts <- tidyr::crossing(number = 1:69, draws) |>
  filter(white_max >= number) |>
  group_by(number) |>
  summarise(
    eligible_draws = n(),
    expected = sum(5 / white_max),
    .groups = "drop"
  )

observed_counts <- numbers_long |>
  count(number, name = "observed")

expected_counts <- expected_counts |>
  left_join(observed_counts, by = "number") |>
  mutate(observed = replace_na(observed, 0))

## 6. STATISTICAL TEST: IS THE VARIATION REAL? ----

# Omnibus test first -- is the overall pattern consistent with random draws?
chisq.test(
  x = expected_counts$observed,
  p = expected_counts$expected / sum(expected_counts$expected)
)
# X-squared = 68.007, df = 68, p-value = 0.4769
# -> No significant deviation from chance. This is the headline finding.

# Per-number z-scores -- surfaces which numbers deviate most, while
# flagging that with 69 comparisons, ~3-4 exceeding |z| > 2 is expected
# by chance alone (multiple-comparisons noise, not signal).
expected_counts <- expected_counts |>
  mutate(
    ratio = observed / expected,
    z = (observed - expected) / sqrt(expected)
  ) |>
  arrange(desc(abs(z)))

expected_counts

## ============================================================
## SUMMARY
## ============================================================
# - Data is clean, one row per draw, no true data-quality issues
# - Double Play NAs are structural (feature launched 2021), not missing data
# - Multiplier NAs need separate investigation (see open item below)
# - chi-square test confirms observed white-ball frequencies are
#   consistent with random draws once era-eligibility is accounted for
# - Story for visualization: "what randomness actually looks like"
#   rather than hot/cold numbers -- ties to human pattern-perception bias
#
# OPEN ITEMS:
# - [ ] Investigate 210 missing multiplier values -- do they cluster
#       before a specific date, or are they scattered gaps?
# - [ ] Confirm double_play_winning_numbers first non-NA row aligns
#       with Aug 2021 Double Play launch date
# - [ ] Decide: single dashboard spanning all 3 eras (era-adjustment
#       baked in) vs. standalone piece on the current 2015-present ruleset



