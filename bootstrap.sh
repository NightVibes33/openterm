#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

git submodule update --init --recursive

pushd Dependencies/ios_system
./get_sources.sh
./get_frameworks_fat.sh
popd

pushd Dependencies/network_ios
./get_frameworks.sh
HEADER_URL="https://github.com/holzschu/ios_system/releases/download/v2.1/ios_error.h"
for attempt in 1 2 3 4 5; do
  curl -fL --retry 3 --retry-delay 2 --retry-all-errors "$HEADER_URL" -o ios_error.h
  if grep -q "#define ios_error_h" ios_error.h; then
    break
  fi
  echo "Invalid ios_error.h download on attempt $attempt"
  head -n 5 ios_error.h || true
  sleep 2
done
grep -q "#define ios_error_h" ios_error.h
popd

if command -v pod >/dev/null 2>&1; then
  pod install
fi
