## ============================================================
## DIAGNOSTIC 07: DROUGHT EVOLUTION THROUGH TIME (v2)
##
## v1 tracked the running max of COMPLETED droughts -- but once
## number 1's 140-draw drought happened, that statistic plateaus
## forever (same failure mode as plotting "tallest person ever").
## Mechanically uninformative, not a real finding.
##
## v2 tracks CURRENT ACTIVE drought instead: at every draw, "how
## long has each number gone since it last appeared, right now."
## The max of that across all 69 numbers is a live series -- it
## rises and resets as different numbers take turns being overdue.
##
## Simulation is also rebuilt: v1 drew from one independent geometric
## stream, which isn't the real generating process. v2 simulates
## actual 5-of-N draws without replacement, using the REAL sequence
## of era pool sizes (59 -> 69), so eligibility timing for 60-69
## matches the true dataset.
##
## Depends on: 01_tidy_data.R (df, numbers_long)
## ============================================================

pacman::p_load(tidyverse, here)

# 1. Setup ----
draw_index_lookup <- df |>
  distinct(draw_date, white_max) |>
  arrange(draw_date) |>
  mutate(draw_index = row_number())

n_draws <- nrow(draw_index_lookup)
white_max_seq <- draw_index_lookup$white_max   # real era sequence, in draw order

# When does each number 1:69 first become eligible? (first draw where
# white_max >= number)
eligible_from <- map_int(1:69, function(num) {
  idx <- which(white_max_seq >= num)
  if (length(idx) == 0) NA_integer_ else min(idx)
})

# 2. OBSERVED: current active drought at every draw, real data ----
draw_number_matrix <- numbers_long |>
  distinct(draw_date, number) |>
  left_join(draw_index_lookup, by = "draw_date") |>
  select(draw_index, number)

last_seen <- rep(NA_integer_, 69)
current_max_drought_observed <- integer(n_draws)

for (t in seq_len(n_draws)) {
  drawn_today <- draw_number_matrix$number[draw_number_matrix$draw_index == t]
  last_seen[drawn_today] <- t
  
  eligible <- which(eligible_from <= t)
  drought_now <- ifelse(
    is.na(last_seen[eligible]),
    t - eligible_from[eligible] + 1,   # never yet drawn since eligible
    t - last_seen[eligible]
  )
  current_max_drought_observed[t] <- if (length(drought_now) > 0) max(drought_now) else 0L
}

observed_series <- draw_index_lookup |>
  mutate(current_max_drought = current_max_drought_observed)

# 3. Plot the LIVE series (not a plateauing running max) ----
ggplot(observed_series, aes(draw_date, current_max_drought)) +
  geom_line() +
  labs(
    title = "Longest currently-active drought, over time",
    subtitle = "Should fluctuate -- rising as a number goes quiet, resetting when it hits",
    x = NULL, y = "Draws since the most-overdue number last appeared"
  )

# Quick summary
summary(observed_series$current_max_drought)

# 4. SIMULATION: actual 5-of-N draws without replacement, real era sequence ----
simulate_current_max_drought <- function(white_max_seq, eligible_from) {
  n <- length(white_max_seq)
  last_seen <- rep(NA_integer_, 69)
  out <- integer(n)
  
  for (t in seq_len(n)) {
    wm <- white_max_seq[t]
    drawn <- sample.int(wm, 5)
    last_seen[drawn] <- t
    
    eligible <- which(eligible_from <= t)
    drought_now <- ifelse(
      is.na(last_seen[eligible]),
      t - eligible_from[eligible] + 1,
      t - last_seen[eligible]
    )
    out[t] <- if (length(drought_now) > 0) max(drought_now) else 0L
  }
  out
}

set.seed(42)
n_sims <- 200  

sim_results <- map(1:n_sims, function(i) {
  simulate_current_max_drought(white_max_seq, eligible_from)
})

sim_matrix <- do.call(cbind, sim_results)  # n_draws x n_sims

sim_summary <- tibble(
  draw_index = seq_len(n_draws),
  sim_mean = rowMeans(sim_matrix),
  sim_p05 = apply(sim_matrix, 1, quantile, probs = 0.05),
  sim_p95 = apply(sim_matrix, 1, quantile, probs = 0.95)
) |>
  left_join(draw_index_lookup, by = "draw_index")

# 5. Observed vs. simulated band ----
observed_vs_sim <- observed_series |>
  left_join(sim_summary, by = c("draw_index", "draw_date", "white_max"))

ggplot(observed_vs_sim, aes(draw_date)) +
  geom_ribbon(aes(ymin = sim_p05, ymax = sim_p95), alpha = 0.2) +
  geom_line(aes(y = sim_mean), linetype = "dashed") +
  geom_line(aes(y = current_max_drought)) +
  labs(
    title = "Longest active drought: observed vs. simulated random benchmark",
    subtitle = "Simulation draws 5-of-N without replacement, matching the real era sequence",
    x = NULL, y = "Draws since the most-overdue number last appeared"
  )

## NOTE: this is now a genuine resampling simulation of the actual
## draw mechanics (5-without-replacement, real pool-size sequence),
## not an approximation via independent geometric streams. If the
## observed line tracks inside the simulated band throughout, that's
## solid support for "current droughts behave exactly like randomness
## predicts" -- a live, fluctuating series rather than a plateauing
## record, which is the actual visual hook v1 was reaching for.