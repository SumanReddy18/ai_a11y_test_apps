#!/usr/bin/env bash
# Push every APK and IPA in releases/v<version>/ to the qa-components live-server pod.
#
# Usage:
#   scripts/push-to-qa.sh                                  # auto-discover pod, use defaults below
#   scripts/push-to-qa.sh --build                          # rebuild APKs first (no version bump)
#   scripts/push-to-qa.sh --pod qa-live-server-xxxx-yyyy   # override pod name (skip auto-discovery)
#   POD=... NAMESPACE=... DEST=... scripts/push-to-qa.sh   # override via env
#   VERSION=1.3.1 scripts/push-to-qa.sh                    # push a specific release dir
#
# The version pushed defaults to the versionName currently set in app/build.gradle.
#
# --build only rebuilds the Android APKs (release.sh is Gradle-only; iOS needs CI). To serve the
# iOS builds too, drop the .ipa files into the release dir first:
#   gh release download v<version> --pattern '*.ipa' --dir releases/v<version> --clobber
set -euo pipefail

cd "$(dirname "$0")/.."

POD="${POD:-}"
NAMESPACE="${NAMESPACE:-qa-components}"
DEST="${DEST:-/home/app/qa-components/live_server/files/apps/}"
POD_SELECTOR="${POD_SELECTOR:-browserstack.com/application=qa-live-server}"
DO_BUILD=0

while [[ $# -gt 0 ]]; do
    case "$1" in
        --build) DO_BUILD=1; shift ;;
        --pod) POD="$2"; shift 2 ;;
        --namespace|-n) NAMESPACE="$2"; shift 2 ;;
        --dest) DEST="$2"; shift 2 ;;
        -h|--help)
            sed -n '2,12p' "$0"
            exit 0
            ;;
        *) echo "Unknown arg: $1" >&2; exit 2 ;;
    esac
done

# versionName is CI-overridable — it reads
#   versionName (project.findProperty('appVersionName') ?: "1.3.1")
# so pick the default out of the elvis operator (same expression release.yml uses).
VERSION_NAME="${VERSION:-$(grep -oE '\?:[[:space:]]*"[0-9]+\.[0-9]+\.[0-9]+"' app/build.gradle \
    | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1)}"
if [[ -z "$VERSION_NAME" ]]; then
    echo "ERROR: could not read versionName from app/build.gradle. Pass VERSION=<x.y.z>." >&2
    exit 1
fi
RELEASE_DIR="releases/v${VERSION_NAME}"

if [[ "$DO_BUILD" -eq 1 ]]; then
    echo "Rebuilding v${VERSION_NAME} APKs via scripts/release.sh ..."
    scripts/release.sh
fi

if [[ ! -d "$RELEASE_DIR" ]]; then
    echo "ERROR: $RELEASE_DIR not found. Run with --build, or run scripts/release.sh first." >&2
    exit 1
fi

shopt -s nullglob
BUILDS=( "$RELEASE_DIR"/*.apk "$RELEASE_DIR"/*.ipa )
shopt -u nullglob

if [[ ${#BUILDS[@]} -eq 0 ]]; then
    echo "ERROR: no .apk or .ipa in $RELEASE_DIR" >&2
    exit 1
fi

if ! command -v kubectl >/dev/null 2>&1; then
    echo "ERROR: kubectl not found in PATH" >&2
    exit 1
fi

if [[ -z "$POD" ]]; then
    echo "Auto-discovering live-server pod (-l $POD_SELECTOR, ns $NAMESPACE)..."
    RUNNING_PODS=()
    while IFS= read -r line; do
        [[ -n "$line" ]] && RUNNING_PODS+=("$line")
    done < <(
        kubectl get pods -n "$NAMESPACE" -l "$POD_SELECTOR" \
            -o jsonpath='{range .items[?(@.status.phase=="Running")]}{.metadata.name}{"\n"}{end}'
    )
    if [[ ${#RUNNING_PODS[@]} -eq 0 ]]; then
        echo "ERROR: no Running pod matched -l $POD_SELECTOR in ns $NAMESPACE." >&2
        echo "       Pass --pod <name> or set POD=<name> to override." >&2
        exit 1
    fi
    if [[ ${#RUNNING_PODS[@]} -gt 1 ]]; then
        echo "ERROR: multiple Running pods matched (${RUNNING_PODS[*]}). Pass --pod to disambiguate." >&2
        exit 1
    fi
    POD="${RUNNING_PODS[0]}"
    echo "  -> resolved pod: $POD"
fi

echo "Pushing ${#BUILDS[@]} build(s) from $RELEASE_DIR"
echo "  -> pod:       $POD"
echo "  -> namespace: $NAMESPACE"
echo "  -> dest:      $DEST"
echo

for build in "${BUILDS[@]}"; do
    name="$(basename "$build")"
    echo "kubectl cp $build $POD:$DEST -n $NAMESPACE"
    kubectl cp "$build" "$POD:$DEST" -n "$NAMESPACE"
    echo "  done: $name"
done

echo
echo "Pushed ${#BUILDS[@]} build(s) to $POD:$DEST"
