#!/usr/bin/env bash

set -euo pipefail

IDENTITY="${EXPANDED_CODE_SIGN_IDENTITY:-${CODE_SIGN_IDENTITY:-${1:-}}}"

if [ -z "$IDENTITY" ]; then
  echo "No code signing identity provided; skipping framework resign."
  exit 0
fi

sign_framework() {
  local framework_path="$1"

  if [ -d "$framework_path" ]; then
    codesign -f -s "$IDENTITY" "$framework_path"
  fi
}

sign_framework "Dependencies/ios_system/Frameworks/openssl.framework"
sign_framework "Dependencies/ios_system/Frameworks/libssh2.framework"
