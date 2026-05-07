#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

git submodule update --init --recursive

pushd Dependencies/ios_system
./get_sources.sh
./get_frameworks.sh

popd

./resign-frameworks.sh
