## ============================================================
## PANEL 3 v1 -- "The Randomness Docket" brand system
## Long droughts (exhibit-first grammar; range reveal, not a point stat)
## ============================================================
##
## FONT NOTE: same sandbox workaround as panels 1 & 2 -- fonts pulled
## from the google/fonts GitHub mirror and registered via fontconfig
## for THIS preview only (no route to fonts.googleapis.com here).
## theme-docket.R's font_add_google() path is untouched for production.
##
## DESIGN DECISIONS LOCKED (this session):
##  - No frozen model/theoretical object existed for droughts in
##    panel_findings.rds, so a NEW lightweight Monte Carlo was run
##    (scripts/panel_03_drought_simulation.R, NOT part of the frozen
##    01-08 diagnostic notebook) to give blue a genuine "what chance
##    predicts" meaning, consistent with Panels 1 & 2's grammar.
##  - The reveal is a RANGE (10th-90th percentile band), not a single
##    point comparison -- a drought is a trajectory/spread, not a point
##    estimate, and forcing a single blue number here would misrepresent
##    what randomness actually produces.
##  - Explicitly NOT centering on the median (61). Real value (48) is
##    shown only as a marker inside the typical-range band -- comparing
##    48 vs. 61 invites "so 48 is shorter" as the takeaway, which misses
##    the point. The lesson is "inside the normal spread," not a
##    number-vs-number comparison.
##  - Narrative finding is STRONGER than the brief assumed: 48 isn't
##    just unsurprising, it's on the low side of typical (16th
##    percentile) -- fair randomness usually has a number waiting even
##    longer than this. Reveal copy reflects that inversion.

library(tidyverse)
library(here)
library(scales)

panel_findings <- read_rds(here("data/processed/panel_findings.rds"))
sim <- read_rds(here("data/processed/panel_3_drought_simulation.rds"))

p3    <- panel_findings$panel_3_droughts
hero  <- p3$hero_example

number_id    <- hero$number
last_seen    <- format(hero$last_seen_date, "%b. %d, %Y")
current_val  <- hero$current_drought

q10 <- unname(round(sim$quantiles["10%"]))
q90 <- unname(round(sim$quantiles["90%"]))

# ── Docket palette (mirrors quarto/powerball-docket.scss) ─────────
paper     <- "#f5f1e8"
ink       <- "#24211c"
body_txt  <- "#4a463d"
muted     <- "#8a8272"
rule      <- "#ddd6c6"
blue      <- "#2e6f9e"
blue_soft <- "#c8d9e4"          # light band fill (blue at low visual weight)
gold      <- "#a06e2a"
gold_text <- "#7a5220"
ball_fill <- "#ece7db"

display_font <- "Libre Caslon Display"
text_font    <- "Libre Caslon Text"
label_font   <- "Archivo"

canvas_w <- 100
canvas_h <- 220

# ── Draws-axis scale: domain [30,100] -> x [15,85] (1:1 slope, v-15) ──
scale_x <- function(draws) draws - 15

band_x0 <- scale_x(q10)
band_x1 <- scale_x(q90)
marker_x <- scale_x(current_val)

p <- ggplot() +
  coord_cartesian(xlim = c(0, canvas_w), ylim = c(0, canvas_h), expand = FALSE) +

  ## -- Eyebrow --
  annotate("text", x = 50, y = 210,
           label = "EXHIBIT C \u2014 LONG DROUGHTS",
           family = label_font, fontface = "bold",
           size = 3.4, color = ink, hjust = 0.5) +

  ## -- Date label (de-emphasized, matches Panel 2's revised weight) --
  annotate("text", x = 50, y = 194,
           label = toupper(paste0("LAST SEEN ", last_seen)),
           family = label_font, fontface = "plain",
           size = 3.3, color = muted, hjust = 0.5) +

  ## -- Drought card: the single exhibit object --
  geom_point(aes(x = 50, y = 150),
             shape = 21, size = 60, stroke = 1.8,
             fill = ball_fill, color = ink) +
  geom_text(aes(x = 50, y = 150, label = number_id),
             family = label_font, fontface = "bold",
             size = 15, color = ink) +

  annotate("text", x = 50, y = 112,
           label = "CURRENT DROUGHT",
           family = label_font, fontface = "bold",
           size = 3.4, color = gold_text, hjust = 0.5) +
  annotate("text", x = 50, y = 97,
           label = paste0(current_val, " draws"),
           family = display_font, fontface = "plain",
           size = 9.5, color = gold, hjust = 0.5) +

  ## -- Divider --
  annotate("segment", x = 8, xend = 92, y = 82, yend = 82,
           color = rule, linewidth = 0.4) +

  ## -- Question (exhibit-first: appears AFTER the card) --
  annotate("text", x = 50, y = 64,
           label = paste0("Number ", number_id, " hasn't hit in ", current_val,
                           " drawings.\nOverdue?"),
           family = text_font, fontface = "italic",
           size = 5.8, color = ink, hjust = 0.5, lineheight = 1.05) +

  ## -- Divider --
  annotate("segment", x = 8, xend = 92, y = 45, yend = 45,
           color = rule, linewidth = 0.4) +

  ## -- Reveal: headline + supporting sentence (Panel 1's pattern) --
  annotate("text", x = 50, y = 34,
           label = paste0(current_val, " draws feels unusually long."),
           family = text_font, fontface = "plain",
           size = 5.6, color = ink, hjust = 0.5) +
  annotate("text", x = 50, y = 27,
           label = paste0("Under today's Powerball rules, a fair lottery typically has\n",
                           "at least one number waiting roughly ", q10, "\u2013", q90,
                           " draws between appearances."),
           family = text_font, fontface = "plain",
           size = 3.5, color = body_txt, hjust = 0.5, lineheight = 1.1) +

  ## -- Range visual: typical-range band + current marker (NOT a point stat) --
  annotate("text", x = 50, y = 17,
           label = "TYPICAL RANGE UNDER CHANCE",
           family = label_font, fontface = "bold",
           size = 3.2, color = blue, hjust = 0.5) +

  # band
  annotate("rect", xmin = band_x0, xmax = band_x1, ymin = 6, ymax = 10,
           fill = blue_soft, color = blue, linewidth = 0.6) +
  # end tick labels
  annotate("text", x = band_x0, y = 3.2, label = q10,
           family = label_font, size = 3, color = muted, hjust = 0.5) +
  annotate("text", x = band_x1, y = 3.2, label = q90,
           family = label_font, size = 3, color = muted, hjust = 0.5) +

  # current-value marker: gold dot on the band + gold label above
  annotate("point", x = marker_x, y = 8, size = 3.2, color = gold) +
  annotate("segment", x = marker_x, xend = marker_x, y = 10.3, yend = 13,
           color = gold, linewidth = 0.6) +
  annotate("text", x = marker_x, y = 15.5,
           label = current_val,
           family = label_font, fontface = "bold",
           size = 4, color = gold_text, hjust = 0.5) +

  ## -- Footer: methodology --
  annotate("text", x = 50, y = -2,
           label = paste0("Monte Carlo simulation, ", scales::comma(sim$nsim),
                           " replicates of ", scales::comma(sim$n_draws),
                           " current-era draws (5-of-", sim$n_pool,
                           ", no replacement). Range = 10th\u201390th percentile ",
                           "of the most-overdue number's current drought.  \u00b7  NY State Gaming Commission"),
           family = label_font, size = 3.1, color = muted, hjust = 0.5) +

  theme_void() +
  theme(
    plot.background = element_rect(fill = paper, color = NA),
    panel.background = element_rect(fill = paper, color = NA),
    plot.margin = margin(20, 20, 30, 20)
  )

ggsave(here("outputs/panel_03_droughts_v1_docket.png"), p,
       width = 8, height = 15.4, dpi = 300, bg = paper)

cat("Saved panel_03_droughts_v1_docket.png\n")
cat(sprintf("Number %d: current drought %d, typical range %d-%d\n",
            number_id, current_val, q10, q90))
