#!/usr/bin/env bash
# Build a debug APK, drop it under releases/v<version>/, and append a changelog stub.
# Usage:
#   scripts/release.sh                 # builds with the current versionName from app/build.gradle
#   scripts/release.sh 1.1.0           # bumps versionName to 1.1.0, increments versionCode, builds
set -euo pipefail

cd "$(dirname "$0")/.."

GRADLE_FILE="app/build.gradle"

current_version_name() {
    grep -oE 'versionName "[^"]+"' "$GRADLE_FILE" | head -1 | sed -E 's/versionName "([^"]+)"/\1/'
}
current_version_code() {
    grep -oE 'versionCode [0-9]+' "$GRADLE_FILE" | head -1 | awk '{print $2}'
}

if [[ $# -ge 1 ]]; then
    NEW_NAME="$1"
    OLD_CODE="$(current_version_code)"
    NEW_CODE=$((OLD_CODE + 1))
    OLD_NAME="$(current_version_name)"
    sed -i '' -E "s/versionName \"$OLD_NAME\"/versionName \"$NEW_NAME\"/" "$GRADLE_FILE"
    sed -i '' -E "s/versionCode $OLD_CODE/versionCode $NEW_CODE/" "$GRADLE_FILE"
    echo "Bumped: $OLD_NAME (code $OLD_CODE) -> $NEW_NAME (code $NEW_CODE)"
fi

VERSION_NAME="$(current_version_name)"
VERSION_CODE="$(current_version_code)"
RELEASE_DIR="releases/v${VERSION_NAME}"
APK_NAME="ai-app-a11y-detection-v${VERSION_NAME}.apk"

echo "Building v${VERSION_NAME} (code ${VERSION_CODE})..."
export ANDROID_HOME="${ANDROID_HOME:-/opt/homebrew/share/android-commandlinetools}"
export ANDROID_SDK_ROOT="${ANDROID_SDK_ROOT:-$ANDROID_HOME}"
./gradlew assembleDebug

mkdir -p "$RELEASE_DIR"
cp "app/build/outputs/apk/debug/${APK_NAME}" "${RELEASE_DIR}/"
echo "Copied -> ${RELEASE_DIR}/${APK_NAME}"

CHANGELOG="releases/CHANGELOG.md"
if ! grep -q "^## v${VERSION_NAME}" "$CHANGELOG" 2>/dev/null; then
    {
        echo "## v${VERSION_NAME} (code ${VERSION_CODE}) — $(date +%Y-%m-%d)"
        echo ""
        echo "- _describe changes here_"
        echo ""
        if [[ -f "$CHANGELOG" ]]; then
            cat "$CHANGELOG"
        fi
    } > "${CHANGELOG}.tmp"
    mv "${CHANGELOG}.tmp" "$CHANGELOG"
    echo "Added stub entry to ${CHANGELOG}"
fi

echo "Done. Edit ${CHANGELOG}, then commit:"
echo "  git add ${RELEASE_DIR} ${CHANGELOG} ${GRADLE_FILE}"
echo "  git commit -m \"Release v${VERSION_NAME}\""
echo "  git tag v${VERSION_NAME} && git push --follow-tags"
