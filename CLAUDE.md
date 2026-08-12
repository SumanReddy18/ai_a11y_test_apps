# CLAUDE.md

Guidance for working in this repo. Read this before changing build config, adding a
flavor, or deploying.

## What this is

A test fixture for the
[BrowserStack App Accessibility Issue Detection Agent](https://www.browserstack.com/docs/app-accessibility/ai-powered-testing/issue-detection-agent)
that *deliberately* violates accessibility rules, one rule per build "flavor". You upload the
app, the scanner runs, and it should report the violation the build was made to demonstrate.

The repo is a **monorepo with two platform ports** that reproduce the SAME 9 violations:

- **`android/`** — native **Java** app, **Gradle** flavors. `minSdk 24`, `compileSdk`/`targetSdk 34`,
  Java 17, package `com.browserstack.a11ydemo`. This is the original / source-of-truth fixture.
- **`ios/`** — native **SwiftUI** app, **XcodeGen** targets (one per rule), deployment target iOS 16.
  See `ios/README.md`. Built only on CI (no local iOS SDK) — see [[ios-fixture-ci-builds]].

Both are built and released together by `.github/workflows/release.yml` (see **Releasing** below).
Current version lives in `android/app/build.gradle` (`versionName`/`versionCode`) and is mirrored
into `ios/project.yml`; the release workflow bumps both.

## Repo layout

```
android/                               # the Android (Java/Gradle) fixture
  app/
    build.gradle                       # flavors, versioning, APK naming (the important file)
    src/
      main/                            # ALL shared code, layouts, strings, drawables
        java/com/browserstack/a11ydemo/
          MainActivity.java            # home + quick-jump nav (full flavor only)
          AllViolationsActivity.java   # every violation on one screen (full flavor only)
          BaseChildActivity.java       # base: up-navigation; all violation screens extend this
          <Rule>Activity.java          # one Activity per rule (see table below)
        res/layout/activity_*.xml      # one layout per rule screen
        res/values/strings.xml         # ruleN_title / ruleN_desc strings
        AndroidManifest.xml            # declares ALL activities (the superset)
      <flavor>/AndroidManifest.xml     # per-flavor override: launcher + remove other activities
  gradlew, settings.gradle, gradle/    # Gradle wrapper + project config
  scripts/
    release.sh                         # build all flavors -> releases/v<version>/ (legacy local flow)
    push-to-qa.sh                      # kubectl cp the APKs to the QA live-server pod
  releases/v<version>/*.apk            # committed pre-built APKs (historical)
ios/                                   # the iOS (SwiftUI/XcodeGen) fixture — see ios/README.md
  project.yml                          # XcodeGen: one target per rule (the important file)
  Sources/App/…                        # one SwiftUI view per rule + Rule.swift catalog
.github/workflows/release.yml          # builds BOTH platforms + publishes a GitHub Release
```

> Commands below run from **`android/`** unless noted (the Gradle project lives there now).

## Flavors (the core mechanism)

Each accessibility rule is a Gradle **product flavor** on the `issue` dimension,
defined in `app/build.gradle`. There are **11 flavors**: `full` + 9 single-issue +
`allViolations`.

| Flavor | applicationIdSuffix | Demonstrates |
|---|---|---|
| `full` | _(none)_ | all rules + home nav + combined screen |
| `imagesText` | `.imagestext` | Images with text |
| `imageviewLabel` | `.imageviewlabel` | Meaningful a11y label for image |
| `interactiveLabel` | `.interactivelabel` | Interactive element a11y label |
| `readingOrder` | `.readingorder` | Meaningful reading order |
| `visualOrder` | `.visualorder` | Meaningful visual order |
| `missingHeading` | `.missingheading` | Missing heading |
| `incorrectHeading` | `.incorrectheading` | Incorrect heading |
| `linkTextPurpose` | `.linktextpurpose` | Link text purpose |
| `inputFieldLabels` | `.inputfieldlabels` | Input field labels (accessible labels + input type) |
| `allViolations` | `.allviolations` | all rules on one screen — launches straight into `AllViolationsActivity` (no home/install screen) |

How a single-issue APK is produced:

1. **Shared code** — every `Activity` and `activity_*.xml` lives in `src/main/`. There is
   no per-flavor Java/layout; all flavors compile the same source set.
2. **Per-flavor manifest** — `src/<flavor>/AndroidManifest.xml` overrides the main manifest:
   it makes that flavor's one Activity the `LAUNCHER`, and uses `tools:node="remove"` to
   strip every other activity (including `MainActivity` and `AllViolationsActivity`) from the
   built APK. So a scan targets exactly one rule.
3. **Distinct application IDs** — `applicationIdSuffix` gives each APK a unique package, so all
   11 can be installed side-by-side on one device.
4. **APK naming** — the `applicationVariants` block renames outputs to
   `ai-app-a11y-detection[-<flavor>]-v<base-version>.apk` (the `full` flavor has no suffix).

### Adding a new rule/flavor

All Android paths below are under `android/`.

1. Add `<Rule>Activity.java` (extend `BaseChildActivity`) and `activity_<rule>.xml` in `app/src/main/`.
2. Declare the activity in `app/src/main/AndroidManifest.xml`.
3. Add a `productFlavors { <rule> { ... } }` block in `android/app/build.gradle` with a unique
   `applicationIdSuffix` / `versionNameSuffix` / `app_name`.
4. Create `app/src/<rule>/AndroidManifest.xml` (copy an existing one; set the new activity as
   launcher, `tools:node="remove"` all others — and add the new activity to every *other*
   flavor's remove-list).
5. Wire it into `MainActivity` nav and `AllViolationsActivity` if it should appear in `full`.
6. **iOS parity** — add the rule to `ios/Sources/App/Rule.swift` (enum case + title/desc/screen),
   a `Screens/<Rule>View.swift`, and a matching target in `ios/project.yml`. Keep the two ports
   in lockstep so a scan finds the same violation on both platforms.

## Critical gotcha: what counts as the violated element

The scanner classifies elements by their **Android accessibility semantics**, not by how
they look. A screen can *look* like it violates a rule and still report nothing because the
element isn't the right *type*. Concrete examples that have bitten us:

- **Link text purpose** — a plain `android:clickable="true"` `TextView` is **not** a link to
  accessibility services, so the rule never fires. Links must carry a `ClickableSpan`/`URLSpan`
  (set a `SpannableString` + `LinkMovementMethod` in the Activity — see
  `LinkTextPurposeActivity.java`). Only then is the element a "link" whose text is evaluated.
  On iOS an inline `AttributedString.link` inside a larger `Text` is not a separate element either
  — and `Text(…).accessibilityAddTraits(.isLink)` is *still* not enough: that is static text merely
  claiming the trait, with no activation behind it, and the scan skips it. Use SwiftUI's native
  `Link` (real link element + destination); `LinkTextPurposeView` also offers `Button`/`Image`
  variants carrying `.isLink` so detection doesn't hinge on one element shape.
  **And the span must cover the whole element.** `link_text_purpose.rb` judges the element's
  *speakable text*, not the span's substring: a `ClickableSpan` over "click here" inside "To view
  our refund policy, click here" produced `detectedLabel: "To view our refund policy, click here"`,
  which does convey a purpose, so it passed. Only the line whose sentence contained a raw URL was
  ever reported. Each link therefore gets its own `TextView` holding nothing but the phrase, spanned
  end-to-end (`LinkTextPurposeActivity.linkifyWholeText`). Then the phrase is an exact match against
  the rule's stop-word list — `click here`, `read more`, `here`, `learn more`, `tap here`, `this`,
  `more`, `continue`, `details`, `submit`, `open`, `download`, … — which is a deterministic FAIL, no
  AI review involved. Non-stop-words (a raw URL, a filename, `#`) still go to AI with just the phrase.
- **Images with text** — the rule needs an element that really is an image *and* pixels a scanner
  can read words out of. Two ways this silently fails: a photo that merely happens to contain text
  (graffiti, a page of a book) reads as an ordinary photo and is illegible once scaled into a grid
  cell; and on iOS, a coloured `ZStack` holding a SwiftUI `Text` tagged `.isImage` is not an image
  at all — the words are live text in the render tree, so there is nothing to find text *inside*.
  Android uses real bitmaps; iOS rasterises its own with `UIGraphicsImageRenderer` (see
  `TextArtwork` in `Components.swift`). Prefer several *kinds* of text-bearing graphic — banner,
  chart, screenshot of a paragraph, table, wordmark — over N variations of one.
- **Headings** — heading rules key off `android:accessibilityHeading="true"`, not bold/large text.
  But `missing-heading` needs *both*: it collects every visible simple-text leaf with its
  `isHeading` flag and an AI pass decides which ones **visually function** as headings. Pseudo-
  headings at 14sp regular over 13sp body read as body text, so the only thing reported on the
  Android screen was the ActionBar title (`text: "6. Missing heading", isHeading: false`) — our
  twelve fake section titles were all judged body copy. They are now 20sp bold over 13sp
  secondary. Keep that gap when editing these screens; and note the ActionBar title is itself a
  standing candidate on every screen.
- **Meaningful reading order** — the rule does *not* read `android:accessibilityTraversalAfter`
  off the view. It needs `snapshot['focusOrder']` (a captured TalkBack traversal) in
  `common_info.android_focus_order_caption_data`; with that missing the focus sequence is empty and
  the rule returns NOT_APPLICABLE without looking at the app at all. It also processes only the
  *first* element of a snapshot, so at most one finding per screen. If the traversal attributes are
  right and nothing is reported, the gap is scan-side focus-order capture, not the fixture.
- **Input fields** — the two input-purpose checks read different attributes. "Accessible input
  field labels" looks for a programmatic name (`android:labelFor` on the caption, `hint`,
  `contentDescription`) — a caption `TextView` that merely sits above an `EditText` is not a
  label. "Input type for input fields" compares that detected label against `android:inputType`,
  so a field must *be labelled* for a type mismatch to fire at all. On iOS a `TextField`'s
  placeholder becomes its accessibility label, so an unnamed field needs `TextField("", …)`.
  Two more things that silently killed "Input type for input fields":
  `android:importantForAutofill="no"` (it was on every field) strips the *autofill metadata* the
  rule inspects alongside the type, so the type-violation fields now carry a deliberately
  contradicting `android:autofillHints` instead; and on iOS `keyboardType`/`textContentType` are
  not accessibility attributes at all, so the only half of this rule iOS reliably exposes is
  secure entry — a plain `TextField` where a `SecureField` belongs shows up as a different
  element type.
- **Below the fold is invisible** — the scan captures the viewport and does not scroll, so a
  violation on the second screenful is simply never seen. This is why the input-type violations
  (~960dp down a 1700dp screen) were rarely reported while the label violations at the top always
  were. Every scrollable rule screen therefore pages itself down on a loop:
  `BaseChildActivity.onContentChanged` on Android (`AllViolationsActivity` opts out via
  `autoScrollsContent()`, it walks its own section anchors), `RuleScreen` + `RulePaging` on iOS.
  Keep `AllViolationsView`'s per-rule dwell at `RulePaging.fullPassSeconds` or that build only
  ever shows each rule's top viewport.

When a violation "isn't detected", first check the element actually has the accessibility
property/role the rule inspects — don't just restyle it. Then check it is on the first screenful,
or that the screen pages itself.

## Building

**Primary path is CI** — `.github/workflows/release.yml` builds both platforms on every push to
`main`. iOS can only be built on CI here (no local iOS SDK). Build Android locally like so:

Toolchain on this machine (no `local.properties`, env not exported globally):

```bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@17
export PATH="$JAVA_HOME/bin:$PATH"
export ANDROID_HOME=/opt/homebrew/share/android-commandlinetools
export ANDROID_SDK_ROOT="$ANDROID_HOME"
```

(`android/scripts/release.sh` already defaults `ANDROID_HOME`/`ANDROID_SDK_ROOT` to that path; it
does **not** set `JAVA_HOME`, so export that yourself if `java` isn't on PATH.)

```bash
cd android
./gradlew assembleDebug                   # all 11 flavors
./gradlew assembleLinkTextPurposeDebug    # one flavor
# override version:  -PappVersionName=1.4.0 -PappVersionCode=6
# outputs: android/app/build/outputs/apk/<flavor>/debug/ai-app-a11y-detection[-<flavor>]-v<version>.apk
```

## Releasing

**Primary: the release workflow.** Any push to `main` whose head commit message does **not**
contain `skip ci` will: bump the patch version + versionCode, build ALL Android APKs and ALL iOS
IPAs at that version, publish a **GitHub Release `v<version>`** with every `.apk`/`.ipa` attached,
and commit the version bump back with `[skip ci]`. Manual runs (Actions → "Build & Release" → Run
workflow) accept an explicit version, else auto-bump. To land a commit **without** cutting a
release, put `skip ci` in the commit message.

**Legacy local flow (Android only, for QA-pod pushes):** `android/scripts/release.sh` builds every
flavor and copies the APKs into `android/releases/v<version>/`.

```bash
cd android
scripts/release.sh           # rebuild at the CURRENT version (no bump)
scripts/release.sh 1.3.0     # bump versionName to 1.3.0 + versionCode +1, then build
```

The committed APKs under `android/releases/v<version>/` are the source of truth for
`push-to-qa.sh` (it copies from there, not from `build/outputs`). If you build manually instead of
via `release.sh`, copy the fresh APKs into `android/releases/v<version>/` before pushing.

## Pushing to the QA live server

QA serves the builds from a Kubernetes pod (`qa-components` namespace, EKS staging cluster).
`android/scripts/push-to-qa.sh` `kubectl cp`s every `.apk` **and `.ipa`** in
`android/releases/v<version>/` into the pod's `.../files/apps/` dir. The version pushed is whatever
`versionName` is in `android/app/build.gradle` (override with `VERSION=`) — the filenames don't
change, so existing download URLs serve the new bytes.

The pod is a plain file server, so it serves both platforms. Only the *build* half is
Android-only: `--build`/`release.sh` is Gradle, and iOS can only be built on CI — so fetch the
`.ipa`s from the GitHub Release into the same dir before pushing (step 2 below).

```bash
cd android
# 1. build at the current version
export JAVA_HOME=/opt/homebrew/opt/openjdk@17; export PATH="$JAVA_HOME/bin:$PATH"
export ANDROID_HOME=/opt/homebrew/share/android-commandlinetools; export ANDROID_SDK_ROOT="$ANDROID_HOME"
./gradlew assembleDebug

# 2. sync fresh APKs into the release dir (release.sh does this for you; manual builds need it)
for apk in app/build/outputs/apk/*/debug/*.apk; do cp -f "$apk" releases/v1.2.0/; done

# 2b. to serve the iOS builds too, pull the IPAs from the GitHub Release into the same dir
gh release download v1.3.1 --pattern '*.ipa' --dir releases/v1.3.1 --clobber
# (same trick works for the APKs if you'd rather serve CI's exact bytes than a local build)

# 3. push (auto-discovers the Running pod via label browserstack.com/application=qa-live-server)
scripts/push-to-qa.sh

# convenience: rebuild via release.sh AND push in one step (re-runs release.sh, no bump)
scripts/push-to-qa.sh --build

# overrides
scripts/push-to-qa.sh --pod qa-live-server-xxxx-yyyy
POD=... NAMESPACE=... DEST=... scripts/push-to-qa.sh
```

Requirements: `kubectl` configured against the staging cluster
(`arn:aws:eks:eu-central-1:...:cluster/browserstack-euc1-stag-001`), and the pod must be `Running`.

Download URLs (auth/VPN-gated — a `403` from curl is the access gate, not a push failure):

```
https://qa-live-server.bsstag.com/download/ai-app-a11y-detection-v1.2.0.apk
https://qa-live-server.bsstag.com/download/ai-app-a11y-detection-<flavor>-v1.2.0.apk
```

To verify a push landed, compare the served `Content-Length` (once authed) against the local
APK size, or re-run the scan. Do **not** rely on `kubectl exec` into the shared pod.

## Installing for manual testing

```bash
adb install -r releases/v1.2.0/ai-app-a11y-detection-linktextpurpose-v1.2.0.apk
```

If the installer complains about an existing install at the same `versionCode`, uninstall first
(`adb uninstall com.browserstack.a11ydemo.linktextpurpose`). Distinct application IDs mean each
flavor installs alongside the others.

## Conventions

- One Activity + one layout per rule.
- **Violation screens carry NO chrome, on both platforms.** No screen title, no subtitle, no red
  "VIOLATION N" badge, no per-section note, no explanatory footer. Every one of those is a real
  element in the accessibility tree, so a scanned screen was mostly text that *isn't* a violation
  — and on iOS the old `RuleScreen` title even carried `.isHeader`, handing the `missingHeading`
  build a perfectly correct heading. The upstream fixtures
  ([iOS](https://github.com/browserstack/app-accessibility-ios-app/tree/app-for-issue-details),
  [Android](https://github.com/browserstack/app-accessibility-android-app/tree/multi-page-regression-app))
  ship violating elements and little else; the iOS one gets every violation off a single screen.
  Put the explanation in an XML comment or the SwiftUI view's doc comment — somewhere the scanner
  cannot see it. A caption that is *part* of a violation (an unassociated "Email" label above an
  unnamed field) is not chrome; keep it.
- `AllViolationsActivity`'s auto-scroll anchors (`sec1…sec9`) therefore sit on layout containers
  and 1dp dividers, never on a heading TextView.
- Don't bump the version just to refresh a screen's content — rebuild at the same version and
  re-push (the user often wants the same URL to serve corrected bytes).
- Commit the rebuilt `releases/v<version>/*.apk` alongside the source change so the committed
  binary matches the source.
