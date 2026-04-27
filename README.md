# app_apk — BrowserStack Issue Detection Agent demo

A native Android app that deliberately violates each of the 5 AI-enhanced
accessibility rules from the [BrowserStack App Accessibility Issue Detection Agent](https://www.browserstack.com/docs/app-accessibility/ai-powered-testing/issue-detection-agent).

## Download

Pre-built APKs are committed under `releases/v<version>/`. Latest:

- **v1.0.0** — [`releases/v1.0.0/ai-app-a11y-detection-v1.0.0.apk`](releases/v1.0.0/ai-app-a11y-detection-v1.0.0.apk)

See [`releases/CHANGELOG.md`](releases/CHANGELOG.md) for release notes.

## Cutting a new release

```bash
# Bump versionName + versionCode, build, copy APK, and stub a changelog entry:
scripts/release.sh 1.1.0

# Then edit releases/CHANGELOG.md and commit:
git add releases/v1.1.0 releases/CHANGELOG.md app/build.gradle
git commit -m "Release v1.1.0"
git tag v1.1.0
git push --follow-tags
```

To rebuild without bumping the version, run `scripts/release.sh` with no arguments.

## Build manually

```bash
./gradlew assembleDebug
# -> app/build/outputs/apk/debug/ai-app-a11y-detection-v<versionName>.apk
```

## Install

```bash
adb install -r releases/v1.0.0/ai-app-a11y-detection-v1.0.0.apk
```
