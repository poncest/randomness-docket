## scripts/00_build_processed_powerball.R
## Builds the clean dataset from raw CSV and writes processed RDS files.
## Run this whenever the raw source data changes; otherwise downstream
## scripts should read from data/processed/ directly.

pacman::p_load(tidyverse, lubridate, janitor, here)

df_raw <- read_csv(
  here("data/Lottery_Powerball_Winning_Numbers__Beginning_2010.csv"),
  show_col_types = FALSE
) |>
  clean_names()

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
    white_max = if_else(draw_date < ymd("2015-10-07"), 59L, 69L),
    pb_max = case_when(
      draw_date < ymd("2012-01-15") ~ 39L,
      draw_date < ymd("2015-10-07") ~ 35L,
      TRUE                          ~ 26L
    )
  )

numbers_long <- df |>
  pivot_longer(n1:n5, names_to = "position", values_to = "number")

dir.create(here("data/processed"), recursive = TRUE, showWarnings = FALSE)

write_rds(df, here("data/processed/powerball_clean.rds"))
write_rds(numbers_long, here("data/processed/powerball_numbers_long.rds"))

## QC check
stopifnot(nrow(numbers_long) == nrow(df) * 5)
cat("Processed files written:", nrow(df), "draws,", nrow(numbers_long), "number rows.\n")
