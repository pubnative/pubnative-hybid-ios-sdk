#!/usr/bin/env bash
set -euo pipefail

BASE_VERSION="${1:-}"
if ! [[ "$BASE_VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
  echo "Invalid base version: '$BASE_VERSION'" >&2
  exit 1
fi

PREFIX="${BASE_VERSION}-beta"
MAX=0

while IFS= read -r candidate; do
  [[ "$candidate" == "$PREFIX"* ]] || continue
  suffix="${candidate#"$PREFIX"}"
  [[ "$suffix" =~ ^[0-9]+$ ]] || continue
  number=$((10#$suffix))
  if (( number > MAX )); then
    MAX="$number"
  fi
done

printf '%s-beta%d\n' "$BASE_VERSION" "$((MAX + 1))"
