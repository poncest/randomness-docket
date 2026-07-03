## scripts/01_freeze_panel_findings.R
## Locks the specific numbers each surviving editorial panel cites.
## Run once diagnostics are settled; re-run only if a panel's underlying
## calculation genuinely changes (not for routine re-exploration).

pacman::p_load(tidyverse, lubridate, here)

df <- read_rds(here("data/processed/powerball_clean.rds"))
numbers_long <- read_rds(here("data/processed/powerball_numbers_long.rds"))

## ============================================================
## PANEL 1: CONSECUTIVE NUMBERS
## ============================================================

consecutive_check <- df |>
  rowwise() |>
  mutate(
    sorted_balls = list(sort(c(n1, n2, n3, n4, n5))),
    sorted_balls_str = paste(sort(c(n1, n2, n3, n4, n5)), collapse = "-"),
    has_consecutive_pair = any(diff(sorted_balls) == 1),
    longest_run = {
      d <- diff(sorted_balls)
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
  ungroup()

feb_20_2019 <- consecutive_check |>
  filter(draw_date == ymd("2019-02-20")) |>
  select(draw_date, n1:n5, powerball, sorted_balls_str, longest_run)

current_era_consecutive_rate <- consecutive_check |>
  filter(draw_date >= ymd("2015-10-07")) |>
  summarise(
    observed_pct = mean(has_consecutive_pair) * 100,
    n_draws = n()
  )

set.seed(123)
sim_rate_consecutive <- mean(replicate(
  20000,
  any(diff(sort(sample(1:69, 5))) == 1)
)) * 100

# Backup examples (run of 3) -- held in reserve, not shown by default
run_of_3_examples <- consecutive_check |>
  filter(longest_run == 3) |>
  select(draw_date, sorted_balls_str)

panel_1_consecutive <- list(
  headline_draw = feb_20_2019,
  observed_pct_current_era = current_era_consecutive_rate$observed_pct,
  simulated_pct_current_era = sim_rate_consecutive,
  n_draws_current_era = current_era_consecutive_rate$n_draws,
  n_run_of_3_examples = nrow(run_of_3_examples),
  run_of_3_examples = run_of_3_examples
)

## ============================================================
## PANEL 2: OVERLAP BETWEEN CONSECUTIVE DRAWS
## ============================================================

draws_sorted <- df |>
  arrange(draw_date) |>
  select(draw_date, white_max, n1, n2, n3, n4, n5) |>
  rowwise() |>
  mutate(ball_set = list(c(n1, n2, n3, n4, n5))) |>
  ungroup()

shared_counts_by_draw <- draws_sorted |>
  mutate(
    shared = map2_int(
      ball_set, lag(ball_set),
      ~ if (is.null(.y)) NA_integer_ else length(intersect(.x, .y))
    )
  ) |>
  filter(!is.na(shared)) |>
  select(draw_date, white_max, shared)

pct_at_least_one_shared <- mean(shared_counts_by_draw$shared >= 1) * 100

N_current <- 69
theoretical_current <- tibble(
  shared = 0:5,
  theoretical_pct = dhyper(0:5, 5, N_current - 5, 5) * 100
)

current_era_transitions <- shared_counts_by_draw |> filter(white_max == 69)
observed_current <- current_era_transitions |>
  count(shared) |>
  mutate(observed_pct = n / sum(n) * 100)

overlap_comparison <- theoretical_current |>
  left_join(observed_current, by = "shared") |>
  mutate(n = replace_na(n, 0), observed_pct = replace_na(observed_pct, 0))

overlap_comparison_collapsed <- overlap_comparison |>
  mutate(shared_bin = if_else(shared >= 3, "3+", as.character(shared))) |>
  group_by(shared_bin) |>
  summarise(theoretical_pct = sum(theoretical_pct), n = sum(n), .groups = "drop")

overlap_chisq <- chisq.test(
  x = overlap_comparison_collapsed$n,
  p = overlap_comparison_collapsed$theoretical_pct / sum(overlap_comparison_collapsed$theoretical_pct)
)

panel_2_overlap <- list(
  pct_at_least_one_shared_all_eras = pct_at_least_one_shared,
  comparison_table_current_era = overlap_comparison,
  comparison_table_collapsed = overlap_comparison_collapsed,
  chisq_statistic = unname(overlap_chisq$statistic),
  chisq_df = unname(overlap_chisq$parameter),
  chisq_p_value = overlap_chisq$p.value
)

## ============================================================
## PANEL 3: DROUGHTS (magnitude + live current-drought evidence)
## ============================================================

draw_index_lookup <- df |>
  distinct(draw_date, white_max) |>
  arrange(draw_date) |>
  mutate(draw_index = row_number())

appearances <- numbers_long |>
  distinct(draw_date, number) |>
  left_join(draw_index_lookup, by = "draw_date") |>
  arrange(number, draw_index)

gaps <- appearances |>
  group_by(number) |>
  mutate(gap = draw_index - lag(draw_index)) |>
  filter(!is.na(gap)) |>
  ungroup()

drought_contrast <- gaps |>
  group_by(number) |>
  summarise(
    mean_gap = mean(gap),
    p95_gap = quantile(gap, 0.95),
    max_gap = max(gap),
    .groups = "drop"
  ) |>
  arrange(desc(max_gap))

longest_drought_headline <- drought_contrast |> slice(1)

last_draw_index <- max(draw_index_lookup$draw_index)
current_droughts <- appearances |>
  group_by(number) |>
  summarise(last_seen = max(draw_index), .groups = "drop") |>
  mutate(current_drought = last_draw_index - last_seen) |>
  arrange(desc(current_drought))

most_overdue_now <- current_droughts |> slice(1)

panel_3_droughts <- list(
  longest_drought_headline = longest_drought_headline,
  drought_contrast_table = drought_contrast,
  most_overdue_number_current = most_overdue_now,
  current_droughts_table = current_droughts
)

## ============================================================
## FREEZE ALL PANELS
## ============================================================

panel_findings <- list(
  panel_1_consecutive = panel_1_consecutive,
  panel_2_overlap = panel_2_overlap,
  panel_3_droughts = panel_3_droughts,
  frozen_at = Sys.time()
)

write_rds(panel_findings, here("data/processed/panel_findings.rds"))

cat("Panel findings frozen:", format(panel_findings$frozen_at), "\n")
cat("Panel 1 headline:", panel_findings$panel_1_consecutive$headline_draw$sorted_balls_str, "\n")
cat("Panel 2 chi-sq p-value:", panel_findings$panel_2_overlap$chisq_p_value, "\n")
cat("Panel 3 longest drought:", panel_findings$panel_3_droughts$longest_drought_headline$max_gap, "\n")
