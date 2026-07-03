# theme-docket.R
# The Randomness Docket — R / ggplot2 side of the theme.
# Makes ggplot figures carry the SAME fonts + palette as the closeread HTML.
# All fonts are free Google Fonts (no Adobe).

library(ggplot2)
library(sysfonts)
library(showtext)

# ── Register the Google Fonts into R's graphics device ────────────
# Names on the left are what you use in R; they map to the same
# families the SCSS pulls from Google Fonts.
font_add_google("Libre Caslon Display", "caslon_display")
font_add_google("Libre Caslon Text",    "caslon")
font_add_google("Archivo",              "archivo")
showtext_auto()          # render registered fonts in all plots
showtext_opts(dpi = 300) # match your knitr fig.dpi so text isn't tiny

# ── Palette — single source of truth, mirrors powerball-docket.scss ─
docket <- list(
  paper = "#f5f1e8",  # warm ivory background
  ink   = "#24211c",  # warm graphite — structure, axes, headings
  body  = "#4a463d",  # secondary text
  muted = "#8a8272",  # captions / gridlines
  rule  = "#ddd6c6",  # hairlines
  blue  = "#2e6f9e",  # EXPECTED / model
  gold  = "#a06e2a",  # OBSERVED — large text (18px+/bold) & decorative use ONLY. 3.92:1 on paper: fails normal-text AA (4.5:1).
  gold_text = "#7a5220" # OBSERVED — small text variant (labels, captions). 6.11:1 on paper: passes AA.
)

# The piece's one recurring grammar: gold = observed, blue = expected.
# Use this named vector with scale_*_manual(values = pb_pal).
pb_pal <- c(observed = docket$gold, expected = docket$blue)

# ── ggplot theme ──────────────────────────────────────────────────
theme_docket <- function(base_size = 13) {
  theme_minimal(base_size = base_size, base_family = "caslon") %+replace%
    theme(
      plot.background   = element_rect(fill = docket$paper, colour = NA),
      panel.background  = element_rect(fill = docket$paper, colour = NA),
      panel.grid.major  = element_line(colour = docket$rule, linewidth = 0.3),
      panel.grid.minor  = element_blank(),
      axis.line.x       = element_line(colour = docket$ink, linewidth = 0.4),
      axis.ticks        = element_line(colour = docket$ink, linewidth = 0.3),
      text              = element_text(colour = docket$ink),
      axis.text         = element_text(colour = docket$body, size = rel(0.85)),
      # Titles in Caslon Display; eyebrow/labels in Archivo, tracked caps
      plot.title    = element_text(family = "caslon_display", size = rel(1.7),
                                   hjust = 0, margin = margin(b = 4)),
      plot.subtitle = element_text(family = "caslon", colour = docket$body,
                                   hjust = 0, margin = margin(b = 12)),
      plot.caption  = element_text(family = "archivo", colour = docket$muted,
                                   size = rel(0.7), hjust = 0,
                                   margin = margin(t = 12)),
      axis.title    = element_text(family = "archivo", colour = docket$muted,
                                   size = rel(0.72), face = "bold"),
      legend.text   = element_text(family = "archivo", size = rel(0.8)),
      legend.title  = element_blank(),
      plot.margin   = margin(16, 16, 12, 16)
    )
}

# Optional: make it the session default so every plot inherits it
theme_set(theme_docket())

# ── Example ───────────────────────────────────────────────────────
# ggplot(df, aes(number, count, colour = source)) +
#   geom_line() +
#   scale_colour_manual(values = pb_pal) +
#   labs(title = "That doesn't look random.",
#        subtitle = "White-ball frequency, NY Powerball, 2010–present",
#        x = "Ball number", y = "Times drawn",
#        caption = "OBSERVED vs EXPECTED under a fair draw") +
#   theme_docket()
