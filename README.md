# app_apk — BrowserStack Issue Detection Agent demo

Test fixtures that **deliberately violate** the 8 AI-enhanced accessibility rules from the
[BrowserStack App Accessibility Issue Detection Agent](https://www.browserstack.com/docs/app-accessibility/ai-powered-testing/issue-detection-agent).
Upload a build, run the scan, and it should report the violation that build was made to demonstrate.

Two native ports, kept in lockstep so a scan finds the same violations on both platforms:

- **`android/`** — native **Java** app, Gradle product flavors → **APK** (the original fixture).
- **`ios/`** — native **SwiftUI** app, XcodeGen targets → **IPA** (see [`ios/README.md`](ios/README.md)).

## The 8 rules × 10 builds

Each rule ships as its own single-issue build (strips the other screens, distinct bundle id, so all
install side-by-side and a scan targets one rule), plus `full` and `allViolations`:

| Build (flavor / scheme) | Demonstrates |
|---|---|
| **full** | All 8 rules + home nav + quick-jump + combined screen |
| **allViolations** | All 8 rules, one auto-scrolling screen (one violation per step) |
| imagesText | Images with text |
| imageviewLabel | Meaningful a11y label for image |
| interactiveLabel | Interactive element a11y label |
| readingOrder | Meaningful reading order |
| visualOrder | Meaningful visual order |
| missingHeading | Missing heading |
| incorrectHeading | Incorrect heading |
| linkTextPurpose | Link text purpose |

## Download

Every release is published on the **[GitHub Releases](../../releases)** page with all 20 artifacts
attached (each build as both `.apk` and `.ipa`). Filenames:

```
ai-app-a11y-detection-v<version>.apk            ai-app-a11y-detection-v<version>.ipa            (full)
ai-app-a11y-detection-<flavor>-v<version>.apk   ai-app-a11y-detection-<flavor>-v<version>.ipa   (single-issue)
```

Direct download pattern:

```
https://github.com/SumanReddy18/ai_a11y_test_apps/releases/download/v<version>/ai-app-a11y-detection[-<flavor>]-v<version>.{apk,ipa}
```

> iOS `.ipa`s are **unsigned** — fine for BrowserStack (it re-signs on upload); they won't sideload
> directly onto a physical iPhone without your own signing.

## Cutting a release (CI)

Both platforms build on GitHub Actions — [`.github/workflows/release.yml`](.github/workflows/release.yml).

- **Auto (patch bump):** push to `main`. It bumps the version, builds all APKs + IPAs, publishes a
  GitHub Release, and commits the bump back with `[skip ci]`. Put `skip ci` in a commit message to
  land it without releasing.
- **Fixed version / refresh:** Actions tab → **Build & Release** → *Run workflow* → set `version`
  (e.g. `1.2.0`). A fixed-version run replaces that release in place and does **not** rewrite the
  source version — used to keep serving the same `v1.2.0` URLs with refreshed bytes.
  CLI: `gh workflow run release.yml -f version=1.2.0`.

## Build locally

**Android** (needs JDK 17 + Android SDK — see [`CLAUDE.md`](CLAUDE.md) for the toolchain env):

```bash
cd android
./gradlew assembleDebug                    # all 10 flavors
./gradlew assembleImagesTextDebug          # one flavor
# override version: -PappVersionName=1.4.0 -PappVersionCode=6
# -> android/app/build/outputs/apk/<flavor>/debug/ai-app-a11y-detection[-<flavor>]-v<version>.apk
```

**iOS** — built on CI only (no local iOS SDK here). To build on a Mac with Xcode, see
[`ios/README.md`](ios/README.md) (`xcodegen generate` + `xcodebuild`).

## Install (Android)

```bash
adb install -r ai-app-a11y-detection-v<version>.apk                 # full
adb install -r ai-app-a11y-detection-linktextpurpose-v<version>.apk  # one rule
```

Distinct application IDs mean each flavor installs alongside the others.
