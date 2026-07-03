## ============================================================
## DIAGNOSTIC 05: SUMS
## Distribution of the sum of the 5 white balls per draw.
## Should approximate a bell curve (CLT) -- does it, and does the
## shape/center shift with the 2015 pool-size change?
## Depends on: 01_tidy_data.R (df)
## ============================================================

pacman::p_load(tidyverse, here)

# 1. Compute sum per draw ----
sums_df <- df |>
  mutate(
    total = n1 + n2 + n3 + n4 + n5,
    avg = total / 5
  )

# 2. Overall distribution ----
summary(sums_df$total)
hist(sums_df$total, breaks = 40, main = "Distribution of sum of 5 white balls (all eras)")

# 3. Split by era -- pool size changes shift both the range and the mean ----
sums_df |>
  group_by(era) |>
  summarise(
    n = n(),
    mean_sum = mean(total),
    sd_sum = sd(total),
    min_sum = min(total),
    max_sum = max(total),
    .groups = "drop"
  )

# Quick visual: overlaid histograms by era (base R, no styling)
ggplot(sums_df, aes(total, fill = era)) +
  geom_histogram(alpha = 0.5, position = "identity", bins = 40) +
  labs(title = "Sum of 5 white balls per draw, by era")

# 4. Theoretical expected mean per era (sampling without replacement) ----
# For 5 numbers drawn without replacement from 1:N, E[sum] = 5 * (N+1)/2
theoretical_means <- tibble(
  era = c("2010-01: white 1-59, PB 1-39", "2012-15: white 1-59, PB 1-35",
          "2015-present: white 1-69, PB 1-26"),
  white_max = c(59, 59, 69)
) |>
  mutate(theoretical_mean_sum = 5 * (white_max + 1) / 2)

theoretical_means

## NOTE: compare theoretical_mean_sum against observed mean_sum per era
## from step 3. Large deviations would be a genuine red flag (data issue
## or actual anomaly); close alignment supports the "clean random process"
## story and gives a simple, intuitive companion chart to the frequency
## diagnostic -- "even the totals behave exactly as math predicts."

# 5. Trend over time -- does the average sum drift or stay flat within era? ----
ggplot(sums_df, aes(draw_date, avg)) +
  geom_line(alpha = 0.3) +
  geom_smooth(se = FALSE) +
  labs(title = "Average of 5 white balls over time")
