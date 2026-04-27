## v1.1.0 (code 2) — 2026-04-27

- _describe changes here_

## v1.0.0 (code 1) — 2026-04-27

Initial release.

- Home screen lists 5 BrowserStack Issue Detection Agent rules with quick-jump number buttons and rule cards.
- 5 dedicated screens, each violating one rule:
  1. **Images with text** — informational text in images with no/poor contentDescription (real text-bearing image included).
  2. **ImageView accessibility label** — meaningful icons with missing or generic labels.
  3. **Interactive element accessibility label** — icon buttons with missing/generic/wrong labels.
  4. **Meaningful reading order** — `accessibilityTraversalAfter` scrambles TalkBack focus.
  5. **Meaningful visual order** — Submit before inputs, step labels rendered out of order.
- Combined "All violations" screen — every rule on a single page for one-shot scanning.
- Action-bar back arrow on every child screen.
