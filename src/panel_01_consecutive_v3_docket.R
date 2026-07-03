## ============================================================
## PANEL 1 v3 -- rebuilt in "The Randomness Docket" brand system
## (graphite/blue/gold, Libre Caslon + Archivo, ball-as-exhibit)
## ============================================================
##
## FONT NOTE: fonts registered directly via fontconfig in this sandbox
## (no network route to fonts.googleapis.com to run font_add_google()
## as theme-docket.R does in the real pipeline). Family names match
## exactly, so this is a faithful preview -- swap to the showtext
## version of theme-docket.R in production, no other changes needed.

library(tidyverse)
library(here)
library(scales)

panel_findings <- read_rds(here("data/processed/panel_findings.rds"))
p1 <- panel_findings$panel_1_consecutive

headline   <- p1$headline_draw
obs_pct    <- p1$observed_pct_current_era
sim_pct    <- p1$simulated_pct_current_era
n_draws    <- p1$n_draws_current_era

balls <- as.integer(headline[1, c("n1","n2","n3","n4","n5")])
draw_date_label <- format(headline$draw_date, "%b. %d, %Y")

# ── Docket palette (mirrors quarto/powerball-docket.scss) ─────────
paper     <- "#f5f1e8"
ink       <- "#24211c"
body_txt  <- "#4a463d"
muted     <- "#8a8272"
rule      <- "#ddd6c6"
blue      <- "#2e6f9e"          # expected
gold      <- "#a06e2a"          # observed -- large text / decorative ONLY
gold_text <- "#7a5220"          # observed -- AA-safe small text (fix applied)
ball_fill <- "#ece7db"          # exhibit-paper ball fill

display_font <- "Libre Caslon Display"
text_font    <- "Libre Caslon Text"
label_font   <- "Archivo"

canvas_w <- 100
canvas_h <- 140

ball_df <- tibble(x = seq(20, 80, length.out = 5), y = 92, label = balls)

p <- ggplot() +
  coord_cartesian(xlim = c(0, canvas_w), ylim = c(0, canvas_h), expand = FALSE) +

  ## -- Question --
  annotate("text", x = 50, y = 116,
           label = "Would these numbers look random?",
           family = text_font, fontface = "italic",
           size = 6.4, color = muted, hjust = 0.5) +

  ## -- Balls as exhibits: paper fill, graphite ring, ink number --
  geom_point(data = ball_df, aes(x = x, y = y),
             shape = 21, size = 30, stroke = 1.6,
             fill = ball_fill, color = ink) +
  geom_text(data = ball_df, aes(x = x, y = y, label = label),
            family = label_font, fontface = "bold",
            size = 9.2, color = ink) +

  annotate("text", x = 50, y = 80.5,
           label = "ACTUAL POWERBALL DRAWING",
           family = label_font, fontface = "bold",
           size = 3.3, color = ink, hjust = 0.5) +
  annotate("text", x = 50, y = 76,
           label = toupper(draw_date_label),
           family = label_font, fontface = "plain",
           size = 4.0, color = muted, hjust = 0.5) +

  ## -- Pause --
  annotate("text", x = 50, y = 60,
           label = "That doesn't look random.",
           family = text_font, fontface = "plain",
           size = 6.0, color = ink, hjust = 0.5) +

  ## -- Reveal --
  annotate("text", x = 50, y = 49,
           label = "About one in four Powerball drawings contain a\nconsecutive pair like this one.",
           family = text_font, fontface = "plain",
           size = 5.1, color = body_txt, hjust = 0.5, lineheight = 1.15) +

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
           label = "actual drawings",
           family = text_font, fontface = "italic",
           size = 2.9, color = muted, hjust = 0.5) +

  annotate("text", x = 50, y = 27,
           label = "\u2248",
           family = text_font, size = 8, color = muted, hjust = 0.5) +

  annotate("text", x = 67, y = 30,
           label = paste0(scales::number(sim_pct, accuracy = 0.1), "%"),
           family = display_font, fontface = "plain",
           size = 10.5, color = blue, hjust = 0.5) +
  annotate("text", x = 67, y = 22,
           label = "EXPECTED",
           family = label_font, fontface = "bold",
           size = 3.4, color = blue, hjust = 0.5) +
  annotate("text", x = 67, y = 18.5,
           label = "fair-random simulation",
           family = text_font, fontface = "italic",
           size = 2.9, color = muted, hjust = 0.5) +

  ## -- Footer --
  annotate("text", x = 50, y = 6,
           label = paste0("Current-era draws (2015-present, n = ",
                           scales::comma(n_draws),
                           ") vs. 20,000-draw simulation  \u00b7  NY State Gaming Commission"),
           family = label_font, size = 2.8, color = muted, hjust = 0.5) +

  theme_void() +
  theme(
    plot.background = element_rect(fill = paper, color = NA),
    panel.background = element_rect(fill = paper, color = NA),
    plot.margin = margin(20, 20, 20, 20)
  )

ggsave(here("outputs/panel_01_consecutive_v3_docket.png"), p,
       width = 8, height = 11.2, dpi = 300, bg = paper)

cat("Saved panel_01_consecutive_v3_docket.png\n")
