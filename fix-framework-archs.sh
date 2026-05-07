#!/usr/bin/env bash

set -euo pipefail

strip_arch_if_present() {
  local binary="$1"
  local arch="$2"
  local temp_file

  if [ ! -f "$binary" ]; then
    return 0
  fi

  if ! lipo -info "$binary" | grep -q "$arch"; then
    return 0
  fi

  temp_file="${binary}.tmp"
  lipo -remove "$arch" "$binary" -output "$temp_file"
  mv "$temp_file" "$binary"
}

for framework_binary in \
  "Dependencies/ios_system/Frameworks/openssl.framework/openssl" \
  "Dependencies/ios_system/Frameworks/libssh2.framework/libssh2"
do
  strip_arch_if_present "$framework_binary" "i386"
  strip_arch_if_present "$framework_binary" "x86_64"
done
