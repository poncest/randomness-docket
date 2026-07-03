## ============================================================
## PANEL 3 -- Monte Carlo benchmark for "most overdue current drought"
## ============================================================
## NOT part of the frozen diagnostic notebook (01-08) -- this is a NEW,
## lightweight simulation built specifically for Panel 3's reveal, since
## panel_findings.rds has no frozen model/theoretical object for droughts
## (diagnostic 07's live resampling band was scoped as background
## material, not a standalone frozen dataset -- see EDITORIAL_BRIEF.md).
##
## QUESTION: After 1,369 fair-random current-era draws (5 unique numbers
## from a 69-number pool each time), how unusual is it that the MOST
## overdue number sits at a 48-draw current drought? Real data: 23 and
## 54 are tied at 48, nothing else currently exceeds that.
##
## METHOD: nsim replicate draw histories of length n_draws=1369, each
## draw = 5 numbers sampled without replacement from 1:69 (matches the
## real mechanism exactly, not a Bernoulli approximation). For each
## replicate, track last-seen draw index per number, compute each
## number's current drought at the end of the sequence, and record the
## MAX across all 69 numbers -- the simulated analogue of "the most
## overdue number in the pool," same statistic as the real 48.

library(tidyverse)
library(here)

set.seed(20260702)  # reproducible; matches session date

n_draws  <- 1369
n_pool   <- 69
n_picked <- 5
nsim     <- 5000

max_current_drought <- integer(nsim)

for (s in seq_len(nsim)) {
  last_seen <- integer(n_pool)  # 0 = not yet seen
  for (d in seq_len(n_draws)) {
    picked <- sample.int(n_pool, n_picked)
    last_seen[picked] <- d
  }
  current_drought <- n_draws - last_seen
  max_current_drought[s] <- max(current_drought)
}

sim_summary <- tibble(max_current_drought = max_current_drought)

real_value <- 48
percentile_of_real <- mean(sim_summary$max_current_drought <= real_value) * 100

q <- quantile(sim_summary$max_current_drought, probs = c(0.10, 0.25, 0.50, 0.75, 0.90))

cat("=== Simulation results (nsim =", nsim, ") ===\n")
cat("Median simulated max current drought:", q["50%"], "\n")
cat("10th-90th percentile range:", q["10%"], "-", q["90%"], "\n")
cat("25th-75th percentile range:", q["25%"], "-", q["75%"], "\n")
cat("Real value (23/54, tied):", real_value, "\n")
cat("Percentile of real value within simulated distribution:",
    round(percentile_of_real, 1), "%\n")
cat("Mean simulated max current drought:", round(mean(sim_summary$max_current_drought), 1), "\n")

write_rds(list(
  nsim = nsim, n_draws = n_draws, n_pool = n_pool, n_picked = n_picked,
  seed = 20260702,
  max_current_drought_samples = max_current_drought,
  quantiles = q,
  real_value = real_value,
  percentile_of_real = percentile_of_real
), here("data/processed/panel_3_drought_simulation.rds"))

cat("\nSaved data/processed/panel_3_drought_simulation.rds\n")
