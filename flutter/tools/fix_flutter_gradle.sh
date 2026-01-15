#!/usr/bin/env bash
set -euo pipefail

apps=("flutter/guardian" "flutter/student" "flutter/teacher")

for app in "${apps[@]}"; do
  root="$app/android/build.gradle.kts"
  if [[ -f "$root" ]]; then
    perl -i -pe 's/^\s*id\("dev\.flutter\.flutter-gradle-plugin"\)\s*\n//g' "$root"
    echo "fixed: $root"
  fi
done

echo "Done"
