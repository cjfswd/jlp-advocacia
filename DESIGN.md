# Design

## Theme

Light-neutral base (cream) with a saturated dark-bordô brand block strategy: hero, áreas, reforma-side, contato and footer run drenched in bordô; sobre/pillars/escritórios run on cream. Committed color strategy, not restrained — bordô + dourado carry 40-60% of the page.

## Color Palette

```css
--bordo-950: #2a0a0d; /* deepest bg (hero base, footer) */
--bordo-900: #3d0f14; /* primary brand surface */
--bordo-800: #4f151b; /* card / panel surface on dark */
--bordo-700: #661c23; /* lighter accent surface */
--gold-400:  #e6c877; /* headings/links on dark, primary accent */
--gold-500:  #d4af37; /* button gradient start, borders */
--gold-600:  #b8863b; /* button gradient end, eyebrow/kicker text */
--cream:      #f8f2e9; /* light section bg */
--cream-dark: #efe4d2; /* alternate light section bg, card border */
--ink:        #201412; /* body text on light */
--ink-soft:   #4a3a37; /* secondary text on light */
```

Known contrast risk (flag in critique): `--gold-600` (#b8863b) used as body/label text on `--cream` (#f8f2e9) and on white cards — verify ≥4.5:1, likely borderline/failing at small sizes. `--gold-400` on `--bordo-950` for links/labels — verify at small sizes too.

## Typography

- Display / headings: **Playfair Display** (500/600/700/800) — classic serif, carries the law-firm gravitas.
- Body / UI: **Poppins** (300-700) — geometric sans, contemporary counterweight to the serif.
- Pairing axis: serif + geometric sans (valid contrast pairing per house rules).
- Hero h1 currently fixed at 3.1rem (not clamped/fluid) — no `text-wrap: balance` set on headings yet.

## Layout & Components

- Section rhythm: alternating full-bleed bands (dark bordô / light cream), `.container` max-width 1180px.
- `.eyebrow` kicker (tracked caps + rule lines) used above **every** section head — flagged pattern, see critique.
- `.pillar-grid`, `.area-grid`, `.office-grid`: identical 3-up card grids, same shape/weight repeated three times across the page.
- `.hero-card`, `.reforma-panel`: the two components with real compositional distinctness (glass-tinted panel, split two-tone panel).
- `.area-card .num` uses `01/02/03` numbering above each card heading — sequence markers on non-sequential content.
- Buttons: `.btn-gold` (gradient gold, primary), `.btn-outline` (dark-bg outline), `.btn-outline-dark` (light-bg outline, currently unused in markup).
- Floating WhatsApp CTA fixed bottom-right, pulse animation, duplicate of in-page CTAs.

## Motion

- `.reveal` class + IntersectionObserver fade/translateY on scroll, uniform across every section (same entrance, no per-section variation).
- No `prefers-reduced-motion` handling on `.reveal` transitions or the WhatsApp pulse `@keyframes`.
- `html{scroll-behavior:smooth}` applies globally, including to JS `scrollIntoView`/`scrollTo` calls (can surprise script-driven scrolling).

## Known Gaps (for audit/polish, not fixed here)

- Founder portrait is a placeholder (initials on gradient), not a real photo.
- Mobile nav (`.burger`) hides all header CTAs at ≤900px instead of adapting them.
- No dark-mode / prefers-color-scheme handling (brand is single-theme by design, confirm this is intentional).
