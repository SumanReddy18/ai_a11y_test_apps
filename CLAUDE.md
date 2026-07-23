# CLAUDE.md

Guidance for working in this repo. Read this before changing build config, adding a
flavor, or deploying.

## What this is

A test fixture for the
[BrowserStack App Accessibility Issue Detection Agent](https://www.browserstack.com/docs/app-accessibility/ai-powered-testing/issue-detection-agent)
that *deliberately* violates accessibility rules, one rule per build "flavor". You upload the
app, the scanner runs, and it should report the violation the build was made to demonstrate.

The repo is a **monorepo with two platform ports** that reproduce the SAME 8 violations:

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
defined in `app/build.gradle`. There are **10 flavors**: `full` + 8 single-issue +
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
| `allViolations` | `.allviolations` | all rules on one screen — launches straight into `AllViolationsActivity` (no home/install screen) |

How a single-issue APK is produced:

1. **Shared code** — every `Activity` and `activity_*.xml` lives in `src/main/`. There is
   no per-flavor Java/layout; all flavors compile the same source set.
2. **Per-flavor manifest** — `src/<flavor>/AndroidManifest.xml` overrides the main manifest:
   it makes that flavor's one Activity the `LAUNCHER`, and uses `tools:node="remove"` to
   strip every other activity (including `MainActivity` and `AllViolationsActivity`) from the
   built APK. So a scan targets exactly one rule.
3. **Distinct application IDs** — `applicationIdSuffix` gives each APK a unique package, so all
   9 can be installed side-by-side on one device.
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
- **Headings** — heading rules key off `android:accessibilityHeading="true"`, not bold/large text.

When a violation "isn't detected", first check the element actually has the accessibility
property/role the rule inspects — don't just restyle it.

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
./gradlew assembleDebug                   # all 10 flavors
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

QA serves the APKs from a Kubernetes pod (`qa-components` namespace, EKS staging cluster).
`android/scripts/push-to-qa.sh` `kubectl cp`s every APK in `android/releases/v<version>/` into the
pod's `.../files/apps/` dir. The version pushed is whatever `versionName` is in
`android/app/build.gradle` — the filenames don't change, so existing download URLs serve the new
bytes. (This QA-pod flow is Android-only; iOS `.ipa`s are distributed via the GitHub Release.)

```bash
cd android
# 1. build at the current version
export JAVA_HOME=/opt/homebrew/opt/openjdk@17; export PATH="$JAVA_HOME/bin:$PATH"
export ANDROID_HOME=/opt/homebrew/share/android-commandlinetools; export ANDROID_SDK_ROOT="$ANDROID_HOME"
./gradlew assembleDebug

# 2. sync fresh APKs into the release dir (release.sh does this for you; manual builds need it)
for apk in app/build/outputs/apk/*/debug/*.apk; do cp -f "$apk" releases/v1.2.0/; done

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

- One Activity + one layout per rule; keep violation screens self-explanatory (section labels,
  red "VIOLATION" badges, an explanatory footer describing what should be flagged).
- Don't bump the version just to refresh a screen's content — rebuild at the same version and
  re-push (the user often wants the same URL to serve corrected bytes).
- Commit the rebuilt `releases/v<version>/*.apk` alongside the source change so the committed
  binary matches the source.
