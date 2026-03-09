#!/usr/bin/env bash
# Release build: zet version op builddatum en bouw app bundle (en optioneel APK).
# Gebruik: ./scripts/build_release.sh
#         ./scripts/build_release.sh --apk
#         ./scripts/build_release.sh --skip-version

set -e
cd "$(dirname "$0")/.."

SKIP_VERSION=false
APK=false
for arg in "$@"; do
  case $arg in
    --skip-version) SKIP_VERSION=true ;;
    --apk)         APK=true ;;
  esac
done

if [ "$SKIP_VERSION" = false ]; then
  echo "Version bijwerken naar builddatum..."
  dart run tool/update_version_to_date.dart
fi

echo "Release build starten (app bundle)..."
flutter build appbundle

if [ "$APK" = true ]; then
  echo "Release APK bouwen..."
  flutter build apk --release
fi

echo "Release build voltooid. Output o.a. in build/app/outputs/bundle/release/"
