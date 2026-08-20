# All-Rules Fixture (`allrules/`)

Standalone Android + iOS apps that deliberately violate **every active rule (40) in the
BrowserStack App Accessibility rule engine**, packed into **3 auto-advancing pages** (~1
viewport each). Completely separate from the per-flavor fixtures in `../android` / `../ios`:
own Gradle project, own XcodeGen project, own bundle ids (`com.browserstack.a11yallrules`).

- Rule reference: <https://www.browserstack.com/docs/app-accessibility/references/rule-name-id>
- Engine source of truth mined for FAIL conditions: `app-accessibility` repo,
  `lib/bstack_rule_engine/rules/**` (legacy Ruby engine — behaviorally equivalent to the
  on-device Kotlin/Swift engines per the AIA "Rule Engine Context" Confluence page).

## Catalog: 41 rules = 40 active + 1 disabled placeholder

- 36 rules run on **both** platforms.
- 4 are **Android-only**: `readable-text-size`, `readable-text-spacing`,
  `checkbox-element-content-label`, `editable-element-no-content-description`.
- `traversal-order-cycle` is registered for both but exits immediately on iOS → effectively Android-only.
- 2 more are **iOS engine dead-ends** (fixture is present but the iOS rule cannot reach FAIL):
  `responsive-containers` and `overlapping-interactive-elements` — see their rows below.
- `interactive-element-accessibility` is the disabled placeholder (not implemented anywhere).
- 11 rules are AI-assisted (verdict from an async AI pass); the rest are deterministic.

## Page map

The app cycles Page 1 → 2 → 3 → 1 forever (~30 s per page); each Android page also pages
its own scroll content down so everything spends time fully inside the viewport (the scan
captures the viewport and never scrolls). iOS pages are non-scrolling single viewports —
an iOS `ScrollView` ancestor would exempt every element from `responsive-containers`.

### Page 1 — labels & controls

| # | Rule ID | Fixture | Platforms |
|---|---|---|---|
| 1 | `interactable-element-content-label` | Button with empty text, no desc | both |
| 2 | `imageview-element-content-label` | ImageView with no contentDescription (iOS: accessible `UIImageView`, no label — deterministic) | both |
| 3 | `screen-reader-for-interactive-elements` | clickable ImageButton with no label (violated via its dependent rules) | both |
| 4 | `duplicate-element-content-label` | two ImageButtons both labelled "Add" (iOS: two `UIButton`s — SwiftUI nodes carry no `isHittable`, so the rule skips them) | both |
| 5 | `button-element-content-label-capitalization` | Button "submit now" (lowercase first word) | both |
| 6 | `label-at-front` | Button text "Submit", label "Tap here to Submit" (iOS: label "Button Submit" — the iOS rule fails a label that STARTS WITH a trait word) | both |
| 7 | `label-in-name` | Button text "Confirm", label "Send form" (iOS: `UIButton` — SwiftUI nodes report text = label, which can never fail) | both |
| 8 | `special-character-element-content-label` | label "Notifications 🔔" (iOS: label "🔔" — the iOS rule fails only a SYMBOL-ONLY label) | both |
| 9 | `view-type-in-content-label` | label "Play Button, Button" (role word twice) | both |
| 10 | `state-in-content-label` | checked Switch labelled "Wi-Fi on" → spoken "…on on" (iOS: "Selected filter, selected") | both |
| 11 | `switch-element-content-label` | bare Switch / `Toggle("", …).labelsHidden()` | both |
| 12 | `checkbox-element-content-label` | bare CheckBox, caption not linked via labelFor | Android |
| 13 | `images-of-text` | JPEG with baked-in text (AI + OCR verdict) | both |
| 14 | `interactive-element-unsupported-type` | custom `FancyToggle extends View` (class outside android.*/androidx); iOS: `UIButton` with EMPTY traits — the iOS rule only fails a recognised control class missing its traits | both |
| 15 | `traversal-order-cycle` | two views with mutual `accessibilityTraversalBefore` | Android |

### Page 2 — text, contrast, geometry

| # | Rule ID | Fixture | Platforms |
|---|---|---|---|
| 16 | `text-color-contrast` | 14sp #999999 on #FFFFFF (2.85:1 < 4.5:1) (iOS: `UILabel` — swatches are captured off UIKit text classes only) | both |
| 17 | `non-text-color-contrast` | flat #BBBBBB icon on white (≈2:1 < 3:1) | both |
| 18 | `readable-text-size` | 4sp TextView (reported px < 14) | Android |
| 19 | `readable-text-spacing` | multi-line TextView at 1.0 line multiplier (needs OCR) | Android |
| 20 | `text-magnification` | `android:textSize="16dp"` (dp not sp); iOS fixed custom font | both |
| 21 | `text-truncation` | fixed-width 16sp single-line TextView, long text (Android needs characterLocations; iOS: `UILabel` numberOfLines=1 — the clip flag is UIKit-only) | both |
| 22 | `responsive-containers` | fixed 140×24dp box with overflowing text — **page must support both orientations** | Android (iOS engine dead-end: the ancestor walk aborts NA on plain UIView/UIWindow, so FAIL is unreachable) |
| 23 | `touch-target-size` | isolated 32dp button (< 44dp) | both |
| 24 | `touch-target-size-and-spacing` | two 20dp buttons 0dp apart (< 24dp + proximity) | both |
| 25 | `overlapping-interactive-elements` | two sibling clickables with pixel-identical bounds | Android (iOS engine dead-end: hittable() is a centre hitTest — only one of two same-bounds views can ever be hittable) |
| 26 | `two-dimensional-scroll` | custom view exposing all four scroll actions; iOS: real `UIScrollView` with oversize content (the rule matches type == "UIScrollView" literally) | both |
| 27 | `missing-heading` | 22sp-bold section titles over 13sp body, no heading flag (AI verdict) | both |
| 28 | `incorrect-heading` | 14sp "Info" flagged `accessibilityHeading="true"` (AI verdict) | both |

### Page 3 — forms, order, focus (portrait-locked)

| # | Rule ID | Fixture | Platforms |
|---|---|---|---|
| 29 | `accessible-input-field-label` | caption TextView without `labelFor` + unnamed EditText (iOS: field with placeholder "Enter shipping address" and no label — the iOS rule fails placeholder-in-lieu-of-label, not an unnamed field) | both |
| 30 | `editable-element-content-label` | same unnamed EditText (label from typed text only) | both |
| 31 | `editable-element-no-content-description` | EditText **with** a contentDescription | Android |
| 32 | `input-type-for-input-field` | `inputType="phone"` holding "Full name"; iOS SecureField labelled "Card number" | both |
| 33 | `meaningful-reading-order` | Step 1/2/3 with traversal order 3→1→2 (needs TalkBack focus capture; AI verdict) | both |
| 34 | `meaningful-visual-order` | ordered steps visually scrambled (AI verdict) | both |
| 35 | `focus-order-for-interactive-elements` | clickable view removed from the a11y tree (needs focus capture) | both |
| 36 | `keyboard-focus-for-interactive-elements` | `clickable="true" focusable="false"` | both |
| 37 | `missing-view-type-in-spoken-output` | custom `TapArea` clickable view, no role in spoken output (iOS: trait-less `UIButton` — a trait-bearing element always passes, the caption appends trait words) | both |
| 38 | `link-text-purpose` | whole-text `URLSpan` "Click here" / "Read more"; iOS native `Link` | both |
| 39 | `screen-orientation` | Page 3 activity locked portrait (rule skipped on Automate scans) | both |
| 40 | `app-orientation-support` | Android: a locked activity in the manifest; iOS: Info.plist missing LandscapeRight | both |

## Why the orientation setup is asymmetric

`responsive-containers` returns NOT_APPLICABLE for the *whole snapshot* unless the current
screen supports both portrait and landscape, while the two orientation rules need a lock.
So only Page 3 is locked; Pages 1–2 rotate. On iOS the Info.plist keeps
Portrait + LandscapeLeft (missing LandscapeRight fails `app-orientation-support` while
keeping per-screen landscape support alive), and an AppDelegate hook drops Page 3 to
portrait-only for `screen-orientation`.

## Scan-side dependencies (fixture is correct, capture must cooperate)

Verified against the on-device engine (`browserstack/talkback` → `talkback-rule-engine`,
wire version 2026.10.0) after two real scans:

- **Focus order is always captured on-device** (`ensureTraversalOrderComputed` runs on
  every snapshot) — but scanner-mode TalkBack sets `FLAG_INCLUDE_NOT_IMPORTANT_VIEWS`
  and `shouldFocusNode` ignores importance, so `importantForAccessibility="no"` does NOT
  remove a clickable leaf from the traversal. The working `focus-order` fixture is a
  clickable container with children and nothing to speak (TalkBack: "focusable but has
  nothing to speak").
- `traversal-order-cycle` **cannot fire on-device today**: no serializer code emits
  `traversalBeforeCycle` / `belongsToCycle` (the engine only reads them). Engine gap.
- `app-orientation-support` / `screen-orientation` get their orientation list only on
  the **App Automate path** (`currentAutomateSupportedOrientations` from appDetails,
  `AppAccessibility.java:1877`); manual scans serialize `""` → both rules silently pass.
  `screen-orientation` is additionally absent from the org rule config we scanned with.
- `screen-reader-for-interactive-elements` never FAILs in the engine (PASS/NA carrier);
  the server marks it violated alongside its dependent label rules.
- `readable-text-spacing` needs OCR data; `text-truncation` (Android) needs
  `characterLocations`; the contrast rules need agent-computed swatches.
- AI-assisted rules surface as AI_REVIEW → issue only after the AI callback (and only
  when the org has AI checks enabled).

iOS capture facts (verified against `browserstack/ios_app_patcher` →
`BrowserStackInjector/AppAccessibility`, engine wire version 2026.10.0, and the
19 Aug 2026 scan pair — Android fired 31 rules, iOS 13 before the UIKit-backed fixtures):

- **SwiftUI content is captured as `AccessibilityNode`s, not UIKit views**: no
  `isHittable` key (adapter defaults "0" → hittable-gated rules skip every SwiftUI
  element), `text` is a copy of the accessibility label (label-vs-text rules pass by
  construction), and `textProperties` are empty (contrast / truncation / dynamic-type
  flags come from UILabel/UITextField/UITextView/UIButton instances only). Any fixture
  whose rule reads one of those signals must be a `UIViewRepresentable` UIKit view —
  see `ios/Sources/App/UIKitFixtures.swift`.
- iOS rule semantics that differ from the obvious reading: `label-at-front` fails a
  label that STARTS WITH a trait word; `special-character-…` fails only symbol-only
  labels; `accessible-input-field-label` fails placeholder-in-lieu-of-label (an unnamed
  empty-placeholder field only goes to AI review); `missing-view-type-…` can only fail a
  recognised control class with EMPTY traits (the capture appends trait words to the
  caption, so any trait-bearing element passes).
- The iOS focus-order caption data is not wired into the engine, so
  `focus-order-for-interactive-elements` no-ops on iOS today.

## Building

```bash
# Android
cd allrules/android
export JAVA_HOME=/opt/homebrew/opt/openjdk@17; export PATH="$JAVA_HOME/bin:$PATH"
export ANDROID_HOME=/opt/homebrew/share/android-commandlinetools; export ANDROID_SDK_ROOT="$ANDROID_HOME"
./gradlew assembleDebug   # -> app/build/outputs/apk/debug/ai-app-a11y-allrules-v<version>.apk

# iOS (CI or a machine with an iOS SDK)
cd allrules/ios && xcodegen generate   # then build the A11yAllRules scheme
```
