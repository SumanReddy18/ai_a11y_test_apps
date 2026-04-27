# app_apk — BrowserStack Issue Detection Agent demo

A native Android app that deliberately violates each of the 5 AI-enhanced
accessibility rules from the [BrowserStack App Accessibility Issue Detection Agent](https://www.browserstack.com/docs/app-accessibility/ai-powered-testing/issue-detection-agent).

Every release produces **6 APKs**:

| Variant | Purpose | Application ID |
|---|---|---|
| **full** | All 5 violations + home, quick-jump nav, and a combined "all on one page" screen | `com.browserstack.a11ydemo` |
| **imagestext** | Only the "Images with text" violation screen | `com.browserstack.a11ydemo.imagestext` |
| **imageviewlabel** | Only the "ImageView accessibility label" violation screen | `com.browserstack.a11ydemo.imageviewlabel` |
| **interactivelabel** | Only the "Interactive element accessibility label" violation screen | `com.browserstack.a11ydemo.interactivelabel` |
| **readingorder** | Only the "Meaningful reading order" violation screen | `com.browserstack.a11ydemo.readingorder` |
| **visualorder** | Only the "Meaningful visual order" violation screen | `com.browserstack.a11ydemo.visualorder` |

Each single-issue APK strips the other activities from its manifest, so a
BrowserStack scan can target one rule at a time. Distinct application IDs
mean all six can install side-by-side on a single device.

## Download

Pre-built APKs are committed under `releases/v<version>/`. Latest:

- **v1.1.0** — [`releases/v1.1.0/`](releases/v1.1.0/)
- **v1.0.0** — [`releases/v1.0.0/`](releases/v1.0.0/)

See [`releases/CHANGELOG.md`](releases/CHANGELOG.md) for release notes.

## Cutting a new release

```bash
# Bump versionName + versionCode, build all 6 flavors, copy each APK,
# and stub a changelog entry:
scripts/release.sh 1.2.0

# Then edit releases/CHANGELOG.md and commit:
git add releases/v1.2.0 releases/CHANGELOG.md app/build.gradle
git commit -m "Release v1.2.0"
git tag v1.2.0
git push --follow-tags
```

To rebuild without bumping the version, run `scripts/release.sh` with no arguments.

## Build manually

```bash
./gradlew assembleDebug
# -> app/build/outputs/apk/<flavor>/debug/ai-app-a11y-detection[-<flavor>]-v<version>.apk
```

To build a single flavor only, e.g. just the "Images with text" APK:

```bash
./gradlew assembleImagesTextDebug
```

## Install

```bash
# Full bundle:
adb install -r releases/v1.1.0/ai-app-a11y-detection-v1.1.0.apk

# Just the "Images with text" violation:
adb install -r releases/v1.1.0/ai-app-a11y-detection-imagestext-v1.1.0.apk
```
