# Does This Look Random to You?

**The Randomness Docket** — a scrollytelling piece examining how real
Powerball drawings can make ordinary randomness look suspicious.

🔗 **Live:** _add Netlify URL after deploy_
💻 **Source:** this repository

---

## What it is

Three real Powerball drawings, each read as an "exhibit":

- **Exhibit A** — a single drawing with consecutive numbers
- **Exhibit B** — two drawings sharing numbers
- **Exhibit C** — a number on a long drought

Each pattern feels like a signal. Each one is exactly what a fair
random process predicts at this sample size. The piece walks through
why — and closes on the idea that randomness isn't the absence of
patterns, it's the presence of patterns that don't mean anything.

## Approach

Built as a static Quarto site with pinned ("sticky") figures beside
scrolling exhibit text — a lightweight scrollytelling pattern using
plain CSS `position: sticky`, no JavaScript, no scroll-linked
framework. See `docs/SESSION_HANDOFF.md` for why a Closeread/Scrollama
implementation was attempted first and abandoned in favor of this
simpler approach.

## Data

NY State Gaming Commission, Powerball Winning Numbers, 2010–present.
Current-era statistics (all three exhibits) use 2015–present draws
only, matching the 2015 white-ball pool-size change. Simulation:
5,000-replicate Monte Carlo using real draw mechanics (5-of-69, no
replacement).

## Stack

R · tidyverse · ggplot2 · Quarto (`html` format, plain CSS sticky
positioning)

## Structure

```
.
├── quarto/
│   ├── randomness-docket-sticky.qmd   # the piece
│   ├── sticky-docket.css              # layout + sticky figures
│   └── powerball-docket.scss          # brand theme
├── src/
│   ├── 00_build_processed_powerball.R
│   ├── 01_freeze_panel_findings.R
│   ├── panel_01_consecutive_v3_docket.R
│   ├── panel_02_overlap_v2_docket.R
│   ├── panel_03_droughts_v5_docket.R
│   ├── panel_03_drought_simulation.R
│   └── theme-docket.R
├── analysis/                          # exploratory notebooks (01–08)
├── outputs/                           # rendered panel PNGs
├── data/
└── docs/
    └── SESSION_HANDOFF.md             # build history + design decisions
```

## Author

Steven Ponce · [stevenponce.netlify.app](https://stevenponce.netlify.app)
