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
popd

if command -v pod >/dev/null 2>&1; then
  pod install
fi
