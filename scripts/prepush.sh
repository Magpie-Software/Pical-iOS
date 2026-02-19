#!/bin/zsh
set -euo pipefail

if ! command -v xcodebuild >/dev/null 2>&1; then
  echo "warning: xcodebuild not available; skipping build check" >&2
  exit 0
fi

xcodebuild -project Pical.xcodeproj \
  -scheme Pical \
  -sdk iphonesimulator \
  -configuration Debug \
  CODE_SIGNING_ALLOWED=NO \
  build >/tmp/pical-prepush.log && rm /tmp/pical-prepush.log
