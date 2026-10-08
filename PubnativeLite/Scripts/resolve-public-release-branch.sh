#!/usr/bin/env bash
# Usage: git tag -l | resolve-public-release-branch.sh <version> <public-main-version>
#
# Prints the public repo branch a release must be synced to:
#   main                      when <version> is newer than or equal to public main
#   release/hybid-X.Y         when <version> is older (hotfix of a previous line),
#                             followed by the newest public release tag older than
#                             <version> to base a new release branch on
set -euo pipefail

VERSION="${1:-}"
MAIN_VERSION="${2:-}"
OFFICIAL='^[0-9]+\.[0-9]+\.[0-9]+$'
TAGS=$(cat)

for value in "$VERSION" "$MAIN_VERSION"; do
  if ! [[ "$value" =~ $OFFICIAL ]]; then
    echo "Expected an X.Y.Z version, got '$value'." >&2
    exit 1
  fi
done

if [ "$(printf '%s\n' "$VERSION" "$MAIN_VERSION" | sort -V | tail -1)" = "$VERSION" ]; then
  echo "main"
  exit 0
fi

BASE_TAG=$({ printf '%s\n' "$TAGS" | grep -E "$OFFICIAL" || true; echo "$VERSION"; } \
  | sort -uV | grep -x -B1 -- "$VERSION" | sed '$d')
if [ -z "$BASE_TAG" ]; then
  echo "No public release tag older than $VERSION to base a release branch on." >&2
  exit 1
fi

echo "release/hybid-${VERSION%.*}"
echo "$BASE_TAG"
