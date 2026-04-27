## v1.1.0 (code 2) — 2026-04-27

- Build now produces **6 APKs per release** via Gradle product flavors:
  - `ai-app-a11y-detection-v<ver>.apk` — full bundle (all 5 violations + home/quick-jump + combined screen).
  - `ai-app-a11y-detection-imagestext-v<ver>.apk` — single-screen APK for rule 1 only.
  - `ai-app-a11y-detection-imageviewlabel-v<ver>.apk` — single-screen APK for rule 2 only.
  - `ai-app-a11y-detection-interactivelabel-v<ver>.apk` — single-screen APK for rule 3 only.
  - `ai-app-a11y-detection-readingorder-v<ver>.apk` — single-screen APK for rule 4 only.
  - `ai-app-a11y-detection-visualorder-v<ver>.apk` — single-screen APK for rule 5 only.
- Each single-issue APK has its own `applicationId` (e.g. `com.browserstack.a11ydemo.imagestext`),
  so all six can install side-by-side on a single device.
- Single-issue APKs strip the other activities from the manifest entirely (`tools:node="remove"`)
  so the `.apk` exposes only the relevant violation screen.
- Action-bar back arrow is hidden when the issue activity is the launcher (no parent to return to).

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
