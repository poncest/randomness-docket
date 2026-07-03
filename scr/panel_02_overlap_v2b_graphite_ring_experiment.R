## ============================================================
## PANEL 2 v1 -- "The Randomness Docket" brand system
## Shared numbers between consecutive draws (exhibit-first grammar)
## ============================================================
##
## FONT NOTE: same sandbox limitation as panel_01_consecutive_v3_docket.R
## -- no network route to fonts.googleapis.com here, so font_add_google()
## in theme-docket.R can't run in THIS environment. Fonts pulled directly
## from the google/fonts GitHub mirror and registered via fontconfig for
## this preview only. Family names match exactly -- your real pipeline
## should keep sourcing theme-docket.R as written; nothing here should
## change for production.
##
## DESIGN DECISIONS LOCKED (see SESSION_HANDOFF.md, this session):
##  - Powerball circles dropped: the overlap claim is about the five
##    white balls only.
##  - Each row sorted ascending -- shared numbers {6, 48} bookend both
##    rows naturally (lowest + highest), no reordering/annotation needed.
##  - Gold rings on shared numbers, NO connector lines between rows --
##    connectors read as worksheet-ish and one crossed the label; let
##    the reader notice the repeat unassisted.
##  - Stat block is ERA-MATCHED (current era, 2015-present, n = 1,369),
##    same standard as Panel 1's observed_pct_current_era /
##    simulated_pct_current_era. The frozen all-eras figure (34.3%) is
##    NOT used here -- see EDITORIAL_BRIEF.md note on why.
##  - Question revised: "The next drawing shared two numbers with the
##    last one. Suspicious?" -- avoids overstating "today/yesterday"
##    when the hero pair is Feb 9/11, not literally consecutive days.
##
## EXPERIMENT VARIANT -- your "biggest suggestion": all ball outlines
## graphite (uniform), ONLY the numerals 6 and 48 go gold. Rendered
## alongside v2 (thinned gold ring) for side-by-side comparison, per
## "I don't know if it'll be better -- I wouldn't commit without
## rendering." Everything else identical to v2.
##  - Question + "Suspicious?" merged into ONE annotate() text block
##    (was two separate calls with a large gap) so they read as one
##    thought, not a caption that got separated.
##  - Date labels de-emphasized: smaller, plain weight, muted color --
##    evidence labels, not headings. The balls should dominate.
##  - Gold ring on shared numbers thinned (2.5 -> 1.9, close to the
##    graphite ring's 1.6) so repeats read as "the same object," not
##    "selected" -- closer to infographic-highlighting overreach before.
##  - Footer bumped one size step (2.7 -> 3.1) -- reward a close look.
##  - Eyebrow restored to "EXHIBIT B -- SHARED NUMBERS" (docket framing:
##    reviewing evidence, not reading chapters). NOTE: Panel 1's v3
##    script does not yet carry an "EXHIBIT A" label -- flagged as a
##    cross-panel consistency item for a later pass, not fixed here
##    since Panel 1 is already signed off.

library(tidyverse)
library(here)
library(scales)

panel_findings <- read_rds(here("data/processed/panel_findings.rds"))
p2 <- panel_findings$panel_2_overlap

# ── Era-matched observed/expected, derived from the frozen collapsed
#    table (NOT the all-eras pct_at_least_one_shared_all_eras field) ──
collapsed   <- p2$comparison_table_collapsed
n_draws     <- sum(collapsed$n)
obs_pct     <- sum(collapsed$n[collapsed$shared_bin != "0"]) / n_draws * 100
exp_pct     <- sum(collapsed$theoretical_pct[collapsed$shared_bin != "0"])
chisq_p     <- p2$chisq_p_value

hero        <- p2$hero_example
balls_1     <- sort(as.integer(hero$balls_1))
balls_2     <- sort(as.integer(hero$balls_2))
shared_nums <- as.integer(hero$shared_numbers)
date_1      <- format(hero$date_1, "%b. %d, %Y")
date_2      <- format(hero$date_2, "%b. %d, %Y")

# ── Docket palette (mirrors quarto/powerball-docket.scss) ─────────
paper     <- "#f5f1e8"
ink       <- "#24211c"
body_txt  <- "#4a463d"
muted     <- "#8a8272"
rule      <- "#ddd6c6"
blue      <- "#2e6f9e"          # expected
gold      <- "#a06e2a"          # observed -- large text / decorative ONLY
gold_text <- "#7a5220"          # observed -- AA-safe small text
ball_fill <- "#ece7db"          # exhibit-paper ball fill

display_font <- "Libre Caslon Display"
text_font    <- "Libre Caslon Text"
label_font   <- "Archivo"

canvas_w <- 100
canvas_h <- 170

# ── Ball rows: sorted ascending, shared numbers get the gold ring ──
make_row <- function(balls, y) {
  tibble(
    x        = seq(20, 80, length.out = 5),
    y        = y,
    label    = balls,
    is_shared = balls %in% shared_nums
  )
}

row_1 <- make_row(balls_1, 128)
row_2 <- make_row(balls_2, 96)
balls_df <- bind_rows(row_1, row_2)

balls_plain  <- filter(balls_df, !is_shared)
balls_shared <- filter(balls_df, is_shared)

p <- ggplot() +
  coord_cartesian(xlim = c(0, canvas_w), ylim = c(0, canvas_h), expand = FALSE) +

  ## -- Eyebrow --
  annotate("text", x = 50, y = 162,
           label = "EXHIBIT B \u2014 SHARED NUMBERS",
           family = label_font, fontface = "bold",
           size = 3.4, color = ink, hjust = 0.5) +

  ## -- Row 1 date label (de-emphasized: evidence label, not heading) --
  annotate("text", x = 50, y = 147,
           label = toupper(date_1),
           family = label_font, fontface = "plain",
           size = 3.3, color = muted, hjust = 0.5) +

  ## -- Row 2 date label --
  annotate("text", x = 50, y = 115,
           label = toupper(date_2),
           family = label_font, fontface = "plain",
           size = 3.3, color = muted, hjust = 0.5) +

  ## -- Balls as exhibits: plain (ink ring) vs shared (gold ring) --
  geom_point(data = balls_plain, aes(x = x, y = y),
             shape = 21, size = 26, stroke = 1.6,
             fill = ball_fill, color = ink) +
  geom_point(data = balls_shared, aes(x = x, y = y),
             shape = 21, size = 26, stroke = 1.6,
             fill = ball_fill, color = ink) +
  geom_text(data = balls_plain, aes(x = x, y = y, label = label),
            family = label_font, fontface = "bold",
            size = 7.8, color = ink) +
  geom_text(data = balls_shared, aes(x = x, y = y, label = label),
            family = label_font, fontface = "bold",
            size = 7.8, color = gold_text) +

  ## -- Divider --
  annotate("segment", x = 8, xend = 92, y = 80, yend = 80,
           color = rule, linewidth = 0.4) +

  ## -- Question (exhibit-first: appears AFTER both rows) --
  ## Bound as ONE text block (was two separate annotate() calls with a
  ## large gap, which read as a caption that got separated from its line)
  annotate("text", x = 50, y = 63,
           label = "The next drawing shared two numbers with the last one.\nSuspicious?",
           family = text_font, fontface = "italic",
           size = 5.8, color = ink, hjust = 0.5, lineheight = 1.05) +

  ## -- Divider --
  annotate("segment", x = 8, xend = 92, y = 46, yend = 46,
           color = rule, linewidth = 0.4) +

  ## -- Stat comparison: gold at large size (passes contrast), gold_text for labels --
  annotate("text", x = 33, y = 30,
           label = paste0(scales::number(obs_pct, accuracy = 0.1), "%"),
           family = display_font, fontface = "plain",
           size = 10.5, color = gold, hjust = 0.5) +
  annotate("text", x = 33, y = 22,
           label = "OBSERVED",
           family = label_font, fontface = "bold",
           size = 3.4, color = gold_text, hjust = 0.5) +
  annotate("text", x = 33, y = 18.5,
           label = "shared one or more white balls",
           family = text_font, fontface = "italic",
           size = 2.8, color = muted, hjust = 0.5) +

  annotate("text", x = 50, y = 27,
           label = "\u2248",
           family = text_font, size = 8, color = muted, hjust = 0.5) +

  annotate("text", x = 67, y = 30,
           label = paste0(scales::number(exp_pct, accuracy = 0.1), "%"),
           family = display_font, fontface = "plain",
           size = 10.5, color = blue, hjust = 0.5) +
  annotate("text", x = 67, y = 22,
           label = "EXPECTED",
           family = label_font, fontface = "bold",
           size = 3.4, color = blue, hjust = 0.5) +
  annotate("text", x = 67, y = 18.5,
           label = "hypergeometric model",
           family = text_font, fontface = "italic",
           size = 2.8, color = muted, hjust = 0.5) +

  ## -- Footer: methodology, not caveat --
  annotate("text", x = 50, y = 6,
           label = paste0("\u03c7\u00b2 goodness-of-fit p = ",
                           scales::number(chisq_p, accuracy = 0.01),
                           ". Analysis uses the current Powerball rules (2015\u2013present, n = ",
                           scales::comma(n_draws),
                           ")  \u00b7  NY State Gaming Commission"),
           family = label_font, size = 3.1, color = muted, hjust = 0.5) +

  theme_void() +
  theme(
    plot.background = element_rect(fill = paper, color = NA),
    panel.background = element_rect(fill = paper, color = NA),
    plot.margin = margin(20, 20, 20, 20)
  )

ggsave(here("outputs/panel_02_overlap_v2b_graphite_ring_experiment.png"), p,
       width = 8, height = 13.6, dpi = 300, bg = paper)

cat("Saved panel_02_overlap_v2b_graphite_ring_experiment.png\n")
cat(sprintf("Observed: %.1f%%  |  Expected: %.1f%%  |  chi-sq p = %.2f  |  n = %d\n",
            obs_pct, exp_pct, chisq_p, n_draws))
