# THE RANDOMNESS DOCKET — Session Handoff

## Status: Phase 4 complete. Ready for cleanup + publish.

---

## What shipped

"Does This Look Random to You?" — a scrollytelling piece examining three
Powerball patterns (consecutive numbers, shared numbers between draws,
long droughts) against what a fair random process predicts.

**Final implementation:** plain CSS `position: sticky`, not Closeread.
Closeread/Scrollama was attempted first (see "Rejected: Closeread" below)
and abandoned after ~2 days of debugging framework internals rather than
project issues. The sticky-figure reading experience is ~95% identical
for the reader; the implementation is a fraction of the complexity.

**Final files:**
- `randomness-docket-sticky.qmd` — the piece itself
- `sticky-docket.css` — layout + sticky positioning
- `powerball-docket.scss` — brand theme (unchanged since Phase 1)
- `panel_01_consecutive_v3_docket.png` / `.R`
- `panel_02_overlap_v2_docket.png` / `.R` ⚠️ **see open item below**
- `panel_03_droughts_v5_docket.png` / `.R`
- `theme-docket.R`

---

## RESOLVED — Panel 2 ring treatment

Deferred across four phases; resolved at cleanup. **`panel_02_overlap_v2_docket`**
(thin gold ring) wins over `panel_02_overlap_v2b_graphite_ring_experiment`
(graphite ring / gold numeral). No `.qmd` change needed — v2 was already
the version wired in. `v2b` moves to the "delete after first commit"
bucket below, same as the other superseded panel drafts.

Nothing left blocking publish.

---

## Rejected: Closeread implementation

Built in full — `closeread-html` format, `cr-section`/sticky/`@cr-id`
wiring, manual Scrollama JS workaround carried from the PDC 2026
reference template. Extension installed and loaded correctly.

Root cause of the persistent sizing bugs: `object-fit: contain` inside
a flex container was letterboxing images inside a box whose aspect
ratio didn't match the image's — confirmed via `naturalWidth`/
`naturalHeight` (2400×3360, matching the `ggsave()` call exactly) vs.
the rendered box (450×822, wrong ratio). Not a stale-render or
pipeline issue — verified the compiled `<style>` block was picking up
every CSS edit correctly throughout.

Decision: abandon Closeread rather than keep chasing framework
internals. Plain `position: sticky` reproduces the reading experience
with no Scrollama, no `cr-active` state, no JS at all — solved the
underlying sizing bug immediately by switching `.exhibit-figure img`
sizing model from flex+`object-fit` to `width: 100%; height: auto`.

**Kept for reference, not deleted:** `04_funafuti_tuvalu_threshold.qmd`
(PDC template) and the Closeread-era `.qmd`/`.css` — useful precedent
if a future project's format is naturally sequential-reveal (multiple
states per figure) rather than one-static-image-per-section, which is
the case where Closeread's actual value proposition applies.

---

## Cleanup plan (do NOT delete before committing)

1. `git init`, commit everything as-is — including all `v1`–`v5` panel
   iterations and the abandoned Closeread files. Git preserves history;
   nothing is lost by pruning the working tree afterward.
2. After first commit, safe to delete from working tree:
   - `panel_02_overlap_v1_docket` (superseded)
   - `panel_02_overlap_v2b_graphite_ring_experiment` (rejected — see
     resolved ring decision above)
   - `panel_03_droughts_v1` through `v4` (superseded)
3. Move (don't delete) `01_frequency` through `08_overlap` diagnostic
   notebooks into an `analysis/` subfolder — they're the exploratory
   trail that found these three patterns, worth keeping visible as
   process documentation, not clutter.

---

## Publish plan

Same pattern as PDC 2026, not the standard TidyTuesday/portfolio embed
pattern — this needs its own repo + Netlify site, not a page inside
the personal-website Quarto build (theme/extension conflicts).

1. New standalone GitHub repo, push after cleanup commit.
2. `README.md` — draft in this handoff bundle.
3. New Netlify site pointed at that repo (same process as PDC 2026).
4. Optional: short `sa_2026-XX-XX.qmd` write-up page on the main
   personal-website repo, linking out to the live Netlify URL + GitHub
   repo — mirrors the pattern used for `sa_2026-04-25.qmd`
   (Noise Solution), not the TidyTuesday embed pattern.
5. Social copy for the launch post is drafted separately — lead with
   "Would these Powerball numbers look random to you?", not the
   conclusion. Don't give away the coda.

---

## Editorial notes carried forward (unchanged, for reference)

- Epistemic standard throughout: "consistent with a fair random
  process," never "is random."
- No unverified audience claims (first-person observational framing
  only).
- Coda — Candidate A, selected Phase 2.5: *"Randomness isn't the
  absence of patterns. It's the presence of patterns that don't mean
  anything."* Reframes rather than summarizes; this is why it won over
  Candidate B ("Resolved investigation").
- Exhibit A/B/C micro-triggers are navigation, not narration — they
  don't restate what's already in the panel PNGs.
