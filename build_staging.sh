#!/usr/bin/env bash
# Staging API (lib/main_dev.dart / AppFlavor.staging) — matches kipleHomev2 build_staging.sh.
# Usage: ./build_staging.sh [apk|appbundle|ios]
# Override: ./build_staging.sh apk --dart-define=API_BASE_URL=https://custom.api.com

set -e
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

ENTRY="lib/main_dev.dart"

build_apk() {
  flutter build apk -t "$ENTRY" \
    --flavor dev \
    --release \
    --target-platform android-arm,android-arm64 \
    --obfuscate \
    --split-debug-info=build/app/outputs/apk/dev/release \
    "$@"
}

build_appbundle() {
  flutter build appbundle -t "$ENTRY" --flavor dev --release "$@"
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
