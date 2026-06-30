#!/bin/bash
set -euo pipefail

# ============================================================
# 🚀 TVSmiles TestFlight Trigger (run from the HyBid release pipeline)
# ============================================================
# Creates an `internal/hybid-private-<version>` branch on
# pubnative/tvsmiles-app-ios. Pushing that branch triggers TVSmiles'
# own CI (.github/workflows/config.yml), which:
#   • derives the HyBid version from the branch name
#   • runs Scripts/update-adapters-for-hybid-private.sh
#     (checks out the HyBid private repo at the matching git tag)
#   • pod install → build_tvsmiles → testflight_tvsmiles (TestFlight upload)
#
# Invoked from config.yml's generate_private_pod job on every private-pod
# build (release branches: beta/development/master). The version passed is the
# private-pod build tag (e.g. 3.9.0-beta1-build.8923), which
# commit-private-podspec.sh has already pushed to the private HyBid repo, so
# TVSmiles' adapter tag-checkout finds it.
#
# Inputs (env):
#   HYBID_PRIVATE_REPO_RELEASE_TAG  (required)  e.g. 3.9.0-beta1-build.8923
#   GH_TOKEN                        (required)  PAT with push access to
#                                               pubnative/tvsmiles-app-ios
# ============================================================

HYBID_VERSION="${HYBID_PRIVATE_REPO_RELEASE_TAG:-}"
if [ -z "$HYBID_VERSION" ]; then
  echo "❌ Missing HYBID_PRIVATE_REPO_RELEASE_TAG (e.g. 3.9.0-beta1)"
  exit 1
fi
if [ -z "${GH_TOKEN:-}" ]; then
  echo "❌ Missing GH_TOKEN (PAT with push access to pubnative/tvsmiles-app-ios)"
  exit 1
fi

TVSMILES_REPO="https://x-access-token:${GH_TOKEN}@github.com/pubnative/tvsmiles-app-ios.git"
BASE_BRANCH="develop"
RELEASE_BRANCH="internal/hybid-private-${HYBID_VERSION}"

# Route any SSH submodule URLs through the token (best-effort — the
# private-pods submodule lives in the vervegroup org and may be
# inaccessible to this token; the branch push is what triggers CI).
git config --global url."https://x-access-token:${GH_TOKEN}@github.com/".insteadOf "git@github.com:"

echo "🚀 Triggering TVSmiles TestFlight for HyBid ${HYBID_VERSION}"

WORKDIR="$(mktemp -d)"
git clone --branch "$BASE_BRANCH" "$TVSMILES_REPO" "$WORKDIR/tvsmiles-app-ios"
cd "$WORKDIR/tvsmiles-app-ios"

git config user.name "verve-release-bot[bot]"
git config user.email "verve-release-bot[bot]@users.noreply.github.com"

# Idempotency: if the branch already exists, the trigger already fired.
if git ls-remote --exit-code --heads origin "$RELEASE_BRANCH" >/dev/null 2>&1; then
  echo "⚠️  Branch $RELEASE_BRANCH already exists on tvsmiles-app-ios — TestFlight already triggered. Skipping."
  exit 0
fi

git checkout -b "$RELEASE_BRANCH"

# Best-effort: bump the private-pods submodule to its latest main.
if [ -f .gitmodules ] && grep -q "internal/hybid-private-pods" .gitmodules; then
  echo "🔄 Updating internal/hybid-private-pods submodule to latest main (best-effort)…"
  if git submodule update --init --recursive internal/hybid-private-pods 2>/dev/null; then
    git -C internal/hybid-private-pods fetch origin main --quiet || true
    git -C internal/hybid-private-pods checkout main --quiet || true
    git -C internal/hybid-private-pods pull origin main --quiet || true
    git add internal/hybid-private-pods || true
  else
    echo "⚠️  Submodule update skipped (token may lack vervegroup access)."
  fi
fi

# Commit so the new branch has a tip. If the submodule did not change, an
# empty commit is fine — pushing a new branch ref still triggers TVSmiles CI.
if git diff --cached --quiet; then
  git commit --allow-empty -m "Trigger TVSmiles TestFlight for HyBid ${HYBID_VERSION}"
else
  git commit -m "Update HyBid private pods to ${HYBID_VERSION}"
fi

git push origin "$RELEASE_BRANCH"
echo "✅ Pushed $RELEASE_BRANCH → TVSmiles CI will build + upload to TestFlight."
