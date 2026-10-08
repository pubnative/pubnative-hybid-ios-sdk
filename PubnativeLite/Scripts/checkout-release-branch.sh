#!/usr/bin/env bash
# Usage: checkout-release-branch.sh <branch> [base-tag]
#
# Run inside a fresh clone: checks out origin/<branch>, or creates <branch>
# from <base-tag> when origin does not have that branch yet.
set -euo pipefail

if git rev-parse -q --verify "origin/$1" >/dev/null; then
  git checkout -q -B "$1" "origin/$1"
else
  echo "Creating $1 from tag ${2:?no base tag to create $1 from}"
  git checkout -q -b "$1" "$2"
fi
