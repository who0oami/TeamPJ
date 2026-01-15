#!/usr/bin/env bash
set -euo pipefail

apps=("flutter/guardian" "flutter/student" "flutter/teacher")
fail=0

for app in "${apps[@]}"; do
  root="$app/android/build.gradle.kts"
  appg="$app/android/app/build.gradle.kts"
  settings="$app/android/settings.gradle.kts"

  if [[ -f "$settings" ]] && grep -q 'dev\.flutter\.flutter-plugin-loader' "$settings"; then
    if [[ -f "$root" ]] && grep -q 'dev\.flutter\.flutter-gradle-plugin' "$root"; then
      echo "❌ [$app] root build.gradle.kts에 flutter-gradle-plugin 중복"
      fail=1
    fi
    if [[ -f "$appg" ]] && ! grep -q 'dev\.flutter\.flutter-gradle-plugin' "$appg"; then
      echo "❌ [$app] app build.gradle.kts에 flutter-gradle-plugin 없음"
      fail=1
    fi
  fi
done

if [[ $fail -eq 1 ]]; then
  echo "FAILED"
  exit 1
fi

echo "PASSED"
