## ============================================================
## DIAGNOSTIC 08: OVERLAP BETWEEN CONSECUTIVE DRAWS
##
## Pivot from 03_streaks.R: instead of counting individual number
## repeats (gap == 1), count the FULL intersection size between each
## pair of consecutive draws -- how many of the 5 white balls are
## shared, 0 through 5. This is the more intuitive framing (humans
## perceive "two draws share 2 numbers" as one event, not two), and
## it has a clean theoretical benchmark: the hypergeometric distribution.
##
## Depends on: 01_tidy_data.R (df)
## ============================================================

pacman::p_load(tidyverse, here)

# 1. Build ordered list of white-ball sets, one per draw ----
draws_sorted <- df |>
  arrange(draw_date) |>
  select(draw_date, white_max, n1, n2, n3, n4, n5) |>
  rowwise() |>
  mutate(ball_set = list(c(n1, n2, n3, n4, n5))) |>
  ungroup()

# 2. Intersection size between each draw and the one immediately before it ----
shared_counts_by_draw <- draws_sorted |>
  mutate(
    shared = map2_int(
      ball_set, lag(ball_set),
      ~ if (is.null(.y)) NA_integer_ else length(intersect(.x, .y))
    )
  ) |>
  filter(!is.na(shared)) |>
  select(draw_date, white_max, shared)

# 3. Full distribution: 0, 1, 2, 3, 4(+) shared numbers ----
shared_distribution <- shared_counts_by_draw |>
  count(shared) |>
  mutate(pct = n / sum(n) * 100)

shared_distribution

# 4. Percent of draws sharing AT LEAST ONE number with the previous draw ----
pct_at_least_one_shared <- mean(shared_counts_by_draw$shared >= 1) * 100
pct_at_least_one_shared

# 5. Theoretical hypergeometric benchmark, CURRENT ERA ONLY (N = 69) ----
# P(k shared) for two independent 5-of-69 draws = dhyper(k, 5, 69-5, 5)
N_current <- 69
theoretical_current <- tibble(
  shared = 0:5,
  theoretical_prob = dhyper(0:5, 5, N_current - 5, 5)
) |>
  mutate(theoretical_pct = theoretical_prob * 100)

theoretical_current

# 6. Observed vs theoretical, CURRENT ERA transitions only ----
# (restrict to transitions where both draws fall in the 2015-present era,
# so the N=69 benchmark is a fair comparison)
current_era_transitions <- shared_counts_by_draw |>
  filter(white_max == 69)

observed_current <- current_era_transitions |>
  count(shared) |>
  mutate(observed_pct = n / sum(n) * 100)

comparison <- theoretical_current |>
  left_join(observed_current, by = "shared") |>
  mutate(
    n = replace_na(n, 0),
    observed_pct = replace_na(observed_pct, 0)
  ) |>
  select(shared, theoretical_pct, observed_pct, n)

comparison

# 7. Chi-square goodness of fit: does the observed distribution match
#    the theoretical hypergeometric distribution? ----
chisq.test(
  x = comparison$n,
  p = comparison$theoretical_pct / sum(comparison$theoretical_pct)
)

# 8. Quick visual ----
comparison |>
  pivot_longer(c(theoretical_pct, observed_pct), names_to = "source", values_to = "pct") |>
  ggplot(aes(factor(shared), pct, fill = source)) +
  geom_col(position = "dodge") +
  labs(
    title = "Shared numbers between consecutive draws: observed vs. theoretical",
    x = "Number of shared white balls", y = "% of draw transitions"
  )

## NOTE: this is the "impossible-feeling but perfectly ordinary" hook --
## e.g. sharing 2+ numbers with the previous draw happens far more often
## than intuition suggests. If comparison shows close alignment (and the
## chi-square test is non-significant), that's the sharpest version yet
## of the "humans misjudge randomness" story, with an intuitive, easy-to-
## communicate unit (shared numbers) and a citable theoretical benchmark.
