#!/bin/bash
set -e

# ============================================================
# 🚀 TVSmiles Submodule Auto-Updater (triggered by HyBid CI)
# ============================================================
# This script:
#   1. Clones the TVSmiles repo
#   2. Updates internal/hybid-private-pods submodule
#   3. Pushes a new branch like internal/hybid-private-3.7.0-build.8462
# ============================================================

TVSMILES_REPO="git@github.com:pubnative/tvsmiles-app-ios.git"
BASE_BRANCH="develop"
HYBID_VERSION="${HYBID_PRIVATE_REPO_RELEASE_TAG:-unknown}"
RELEASE_BRANCH="internal/hybid-private-${HYBID_VERSION}"

echo "🚀 Preparing to update TVSmiles submodule for HyBid $HYBID_VERSION"

# --- Clone TVSmiles ---
git clone "$TVSMILES_REPO"
cd tvsmiles-app-ios

# 🧩 Set explicit commit author identity (local to TVSmiles clone)
git config --local user.name "CircleCI Bot"
git config --local user.email "ci-bot@pubnative.net"

# Prevent inheriting previous Git author info
git config --local user.useConfigOnly true
git config --global --add safe.directory "$(pwd)"

# --- Fetch and checkout develop ---
echo "🔄 Checking out base branch: $BASE_BRANCH"
git fetch origin "$BASE_BRANCH"
git checkout "$BASE_BRANCH"
git pull origin "$BASE_BRANCH"

# ============================================================

# --- Create release branch ---
echo "🌿 Creating release branch: $RELEASE_BRANCH"
git checkout -b "$RELEASE_BRANCH" || git checkout "$RELEASE_BRANCH"

# --- Update submodule ---
if [ -d "internal/hybid-private-pods" ]; then
  echo "✅ Updating submodule internal/hybid-private-pods..."

  # ✅ Ensure submodule is initialized and synced correctly
  git submodule update --init --recursive internal/hybid-private-pods
  git submodule sync --recursive internal/hybid-private-pods

  cd internal/hybid-private-pods

  # Re-add remote if missing (common in fresh CI clones)
  if ! git remote get-url origin &>/dev/null; then
    echo "⚙️  Adding missing remote origin..."
    git remote add origin git@github.com:vervegroup/hybid-ios-sdk-private-pods.git
  fi

  git fetch origin main
  git checkout main
  git pull origin main

  cd ../..
else
  echo "❌ Submodule folder missing — did you add it to TVSmiles?"
  exit 1
fi

# --- Commit & push release branch ---
git add internal/hybid-private-pods
git commit -m "🔄 Update HyBid private pods to ${HYBID_VERSION}" || echo "ℹ️ Nothing to commit"
git push origin "$RELEASE_BRANCH" || echo "⚠️ Push skipped or branch already exists"

echo "✅ Created and pushed branch: $RELEASE_BRANCH"
echo "✅ TVSmiles submodule updated successfully"
