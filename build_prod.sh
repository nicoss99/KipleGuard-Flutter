#!/usr/bin/env bash
# Production API (lib/main_prod.dart) — matches kipleHomev2 build_prod.sh.
# Usage: ./build_prod.sh [apk|appbundle|ios]
#
# Same release production APK without this script (PowerShell, one line):
#   flutter build apk -t lib/main_prod.dart --flavor prod --release --target-platform android-arm,android-arm64 --obfuscate --split-debug-info=build/app/outputs/apk/prod/release
#
# Output: build/app/outputs/flutter-apk/app-prod-release.apk

set -e
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

ENTRY="lib/main_prod.dart"

build_apk() {
  flutter build apk -t "$ENTRY" \
    --flavor prod \
    --release \
    --target-platform android-arm,android-arm64 \
    --obfuscate \
    --split-debug-info=build/app/outputs/apk/prod/release \
    "$@"
}

build_appbundle() {
  flutter build appbundle -t "$ENTRY" --flavor prod --release "$@"
}

build_ios() {
  flutter build ios -t "$ENTRY" --release "$@"
}

case "${1:-appbundle}" in
  apk)         build_apk "${@:2}" ;;
  appbundle)   build_appbundle "${@:2}" ;;
  ios)         build_ios "${@:2}" ;;
  *)           echo "Usage: $0 [apk|appbundle|ios] [extra flutter args...]"; exit 1 ;;
esac
