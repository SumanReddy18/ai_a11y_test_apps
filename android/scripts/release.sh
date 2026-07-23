#!/usr/bin/env bash
# Build all 8 flavor APKs (1 full + 7 single-issue), drop them under
# releases/v<version>/, and stub a CHANGELOG entry.
#
# Usage:
#   scripts/release.sh                 # builds with the current versionName
#   scripts/release.sh 1.2.0           # bumps versionName to 1.2.0 (and versionCode +1) first
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

echo "Building all flavors for v${VERSION_NAME} (code ${VERSION_CODE})..."
export ANDROID_HOME="${ANDROID_HOME:-/opt/homebrew/share/android-commandlinetools}"
export ANDROID_SDK_ROOT="${ANDROID_SDK_ROOT:-$ANDROID_HOME}"
./gradlew assembleDebug

mkdir -p "$RELEASE_DIR"

# Each flavor's debug APK is at app/build/outputs/apk/<flavor>/debug/<file>.apk
FOUND=0
for apk in app/build/outputs/apk/*/debug/*.apk; do
    [[ -e "$apk" ]] || continue
    cp "$apk" "$RELEASE_DIR/"
    echo "  -> $RELEASE_DIR/$(basename "$apk")"
    FOUND=$((FOUND + 1))
done

if [[ $FOUND -eq 0 ]]; then
    echo "ERROR: No APKs found under app/build/outputs/apk/*/debug/" >&2
    exit 1
fi

echo "Copied $FOUND APK(s) into $RELEASE_DIR"

CHANGELOG="releases/CHANGELOG.md"
if ! grep -q "^## v${VERSION_NAME} " "$CHANGELOG" 2>/dev/null; then
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

echo ""
echo "Done. Edit ${CHANGELOG}, then commit:"
echo "  git add ${RELEASE_DIR} ${CHANGELOG} ${GRADLE_FILE}"
echo "  git commit -m \"Release v${VERSION_NAME}\""
echo "  git tag v${VERSION_NAME} && git push --follow-tags"
