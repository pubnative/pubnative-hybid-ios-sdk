#!/bin/bash
set -e

# ========================================
# 🪄 HyBid Private Podspec Commit Script
# ========================================
# Commits podspec + binary into:
#   👉 https://github.com/vervegroup/hybid-ios-sdk-private-pods
# Also updates the specs repo automatically:
#   👉 https://github.com/vervegroup/hybid-ios-sdk-private-pods-specs
# Never commits to the source SDK repo.
#
# Inputs (env):
#   - HYBID_PRIVATE_REPO_RELEASE_TAG  (required) ex: 3.7.0-beta4-local.build.20
#   - GITHUB_TOKEN                    (optional for local, required on CI for releases)
#
# Flags:
#   --commit   : push + create release
#   --force    : overwrite existing tag/version folders
#
# Output:
#   - Commit/tag in hybid-ios-sdk-private-pods
#   - GitHub Release (assets: .zip + .podspec)
#   - Specs repo version folder with .podspec
# ========================================

PODSPEC_FILE="HyBid-private.podspec"
ZIP_FILE="HyBid.xcframework.zip"
TARGET_REPO_NAME="hybid-ios-sdk-private-pods"
TARGET_REPO_URL="https://github.com/vervegroup/${TARGET_REPO_NAME}.git"
TARGET_REPO_DIR="../${TARGET_REPO_NAME}"
SPECS_REPO_NAME="hybid-ios-sdk-private-pods-specs"
SPECS_REPO_URL="https://github.com/vervegroup/${SPECS_REPO_NAME}.git"
SPECS_REPO_DIR="../${SPECS_REPO_NAME}"
AUTO_COMMIT=false
FORCE_UPDATE=false

# 🔐 Helper: make GH CLI authenticated in CI (no-op locally)
ensure_gh_auth() {
  if [ "$AUTO_COMMIT" = true ] && command -v gh >/dev/null 2>&1; then
    if gh auth status >/dev/null 2>&1; then
      echo "🔑 gh already authenticated"
    elif [ -n "${GITHUB_TOKEN:-}" ]; then
      echo "🔑 Authenticating gh with GITHUB_TOKEN…"
      echo "$GITHUB_TOKEN" | gh auth login --with-token || true
    else
      echo "⚠️  GITHUB_TOKEN not set — gh release step will be skipped"
    fi
  fi
}

# --------------------------------
# 📂 Resolve SDK and script paths
# --------------------------------
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SDK_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
echo "📍 Script directory: $SCRIPT_DIR"
echo "📦 SDK root directory: $SDK_ROOT"

# 🧩 Load version tag
echo "🏷 Using release version from .hybid-version: $HYBID_PRIVATE_REPO_RELEASE_TAG"
HYBID_PRIVATE_REPO_RELEASE_TAG="${HYBID_PRIVATE_REPO_RELEASE_TAG:-unknown-version}"

# -------------------------------
# 🔧 Parse arguments
# -------------------------------
for arg in "$@"; do
  case "$arg" in
    --commit)
      AUTO_COMMIT=true
      echo "🟢 Auto-commit mode (CI)"
      ;;
    --force)
      FORCE_UPDATE=true
      echo "⚡ Force update enabled — will overwrite existing version if found!"
      ;;
    *)
      echo "ℹ️ Unknown argument: $arg"
      ;;
  esac
done

if [ "$AUTO_COMMIT" = false ]; then
  echo "🧩 Local mode (no push)"
fi

# -------------------------------
# 🧩 Validate environment
# -------------------------------
if [ -z "$HYBID_PRIVATE_REPO_RELEASE_TAG" ]; then
  echo "❌ HYBID_PRIVATE_REPO_RELEASE_TAG not set."
  echo "👉 export HYBID_PRIVATE_REPO_RELEASE_TAG=3.7.0-beta4-build.110"
  exit 1
fi

# ✅ NEW: Validate zip exists before continuing
if [ ! -f "$SDK_ROOT/$ZIP_FILE" ]; then
  echo "❌ Missing $ZIP_FILE — aborting to avoid incomplete release."
  ls -lah "$SDK_ROOT" || true
  exit 1
fi

for file in "$PODSPEC_FILE" "$ZIP_FILE"; do
  if [ ! -f "$file" ] && [ ! -f "$SDK_ROOT/$file" ]; then
    echo "❌ Missing required file: $file"
    exit 1
  fi
done

# -------------------------------
# 📦 Ensure private pods repo clone exists
# -------------------------------
if [ ! -d "$TARGET_REPO_DIR/.git" ]; then
  echo "📥 Cloning $TARGET_REPO_NAME..."
  git clone "$TARGET_REPO_URL" "$TARGET_REPO_DIR"
else
  echo "📁 Using existing clone of $TARGET_REPO_NAME"
fi

cd "$TARGET_REPO_DIR"

# -------------------------------
# 🧭 Ensure main branch
# -------------------------------
git fetch origin main
git checkout main || git switch main
git pull origin main || echo "⚠️ Could not pull latest main"

# -------------------------------
# 🪄 Copy generated artifacts
# -------------------------------
echo "📦 Copying generated files into repo..."
cp -v "${SDK_ROOT}/${PODSPEC_FILE}" "./${PODSPEC_FILE}"
cp -v "${SDK_ROOT}/${ZIP_FILE}" "./${ZIP_FILE}"

# -------------------------------
# 🧩 Commit & tag
# -------------------------------
if git diff --quiet "$PODSPEC_FILE" "$ZIP_FILE"; then
  echo "ℹ️ No changes to commit."
else
  git add "$PODSPEC_FILE" "$ZIP_FILE"
  git commit -m "🧩 Add HyBid-private.podspec & binary for $HYBID_PRIVATE_REPO_RELEASE_TAG"
  echo "✅ Committed files to $TARGET_REPO_NAME"
fi

if git tag -l | grep -q "^${HYBID_PRIVATE_REPO_RELEASE_TAG}$"; then
  if [ "$FORCE_UPDATE" = true ]; then
    echo "⚡ Tag ${HYBID_PRIVATE_REPO_RELEASE_TAG} already exists — force re-tagging!"
    git tag -d "$HYBID_PRIVATE_REPO_RELEASE_TAG"
    git tag "$HYBID_PRIVATE_REPO_RELEASE_TAG"
  else
    echo "ℹ️ Tag ${HYBID_PRIVATE_REPO_RELEASE_TAG} already exists."
  fi
else
  git tag "$HYBID_PRIVATE_REPO_RELEASE_TAG"
  echo "🏷 Created tag ${HYBID_PRIVATE_REPO_RELEASE_TAG}"
fi

# =====================================================
# 🪶 NEW: Create lightweight tag in source SDK repo
# =====================================================
SOURCE_REPO_DIR="${SDK_ROOT}"  # assumes this script runs from pubnative-hybid-ios-sdk-private
SOURCE_REPO_NAME="pubnative-hybid-ios-sdk-private"

if [ -d "$SOURCE_REPO_DIR/.git" ]; then
  echo "🔖 Creating matching lightweight tag in ${SOURCE_REPO_NAME}..."

  pushd "$SOURCE_REPO_DIR" >/dev/null

  # Detect branch name safely (works in CI or local)
  if [ "${CIRCLE_BRANCH:-}" != "" ]; then
    CURRENT_BRANCH="${CIRCLE_BRANCH}"
  else
    CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "HEAD")
  fi

  # Get current commit SHA
  CURRENT_COMMIT=$(git rev-parse HEAD 2>/dev/null || echo "unknown")

  echo "📍 Working branch: ${CURRENT_BRANCH}"
  echo "🔹 Current commit: ${CURRENT_COMMIT}"

  # Pull only if branch exists remotely
  if git ls-remote --exit-code origin "${CURRENT_BRANCH}" &>/dev/null; then
    git fetch origin "${CURRENT_BRANCH}" || true
    git pull origin "${CURRENT_BRANCH}" || true
  else
    echo "⚠️  Branch ${CURRENT_BRANCH} not found on remote — skipping pull."
  fi

  # Tag current commit (avoid duplicates)
  if git tag -l | grep -q "^${HYBID_PRIVATE_REPO_RELEASE_TAG}$"; then
    echo "ℹ️ Tag ${HYBID_PRIVATE_REPO_RELEASE_TAG} already exists in ${SOURCE_REPO_NAME}."
  else
    git tag -a "${HYBID_PRIVATE_REPO_RELEASE_TAG}" \
      -m "Auto-tagged for private release ${HYBID_PRIVATE_REPO_RELEASE_TAG} from ${CURRENT_BRANCH} (${CURRENT_COMMIT})"
    echo "🏷 Created tag ${HYBID_PRIVATE_REPO_RELEASE_TAG} on ${CURRENT_BRANCH}"
    if [ "$AUTO_COMMIT" = true ]; then
      git push origin "${HYBID_PRIVATE_REPO_RELEASE_TAG}" || echo "⚠️ Could not push tag to ${SOURCE_REPO_NAME}"
    else
      echo "ℹ️ Local mode — tag not pushed to remote."
    fi
  fi

  popd >/dev/null
else
  echo "⚠️ Source repo not found at ${SOURCE_REPO_DIR} — skipping source tagging."
fi

# -------------------------------
# 🚀 Push + release (if CI)
# -------------------------------
if [ "$AUTO_COMMIT" = true ]; then
  echo "🚀 Pushing to remote..."
  git push origin main --tags --force
  echo "✅ Pushed commit & tag to $TARGET_REPO_URL"

  ensure_gh_auth

  if command -v gh >/dev/null 2>&1 && gh auth status >/dev/null 2>&1; then
    echo "🪄 Creating GitHub release..."
    gh release create "$HYBID_PRIVATE_REPO_RELEASE_TAG" \
      "$ZIP_FILE" "$PODSPEC_FILE" \
      --repo vervegroup/${TARGET_REPO_NAME} \
      --title "v: ${HYBID_PRIVATE_REPO_RELEASE_TAG}" \
      --notes "HyBid private binary pod version: ${HYBID_PRIVATE_REPO_RELEASE_TAG}" \
      --verify-tag || echo "⚠️ Release creation skipped (exists or API error)"
    echo "🎉 GitHub release created successfully!"
  else
    echo "⚠️ GitHub CLI not installed or not authenticated — skipping release creation."
  fi
else
  echo "🧪 Local test: skipping push and release."
fi

# ==========================================================
# 📚 Update specs repo
# ==========================================================
echo ""
echo "📚 Syncing podspec to ${SPECS_REPO_NAME}..."

# Clone specs repo if missing
if [ ! -d "$SPECS_REPO_DIR/.git" ]; then
  echo "📥 Cloning $SPECS_REPO_NAME..."
  git clone "$SPECS_REPO_URL" "$SPECS_REPO_DIR"
else
  echo "📁 Using existing clone of $SPECS_REPO_NAME"
fi

cd "$SPECS_REPO_DIR"
git fetch origin main
git checkout main || git switch main
git pull origin main || echo "⚠️ Could not pull latest specs main"

DEST_DIR="HyBid-private/${HYBID_PRIVATE_REPO_RELEASE_TAG}"

# 🛡️ Skip if version already exists (unless forced)
if [ -d "$DEST_DIR" ] && [ "$FORCE_UPDATE" = false ]; then
  echo "⚠️ Version ${HYBID_PRIVATE_REPO_RELEASE_TAG} already exists in specs repo. Skipping update to avoid duplicates."
  echo "✅ Specs repo is already up to date."
  exit 0
fi

if [ -d "$DEST_DIR" ] && [ "$FORCE_UPDATE" = true ]; then
  echo "⚡ Force update: removing existing version folder..."
  rm -rf "$DEST_DIR"
fi

mkdir -p "$DEST_DIR"
cp -v "${SDK_ROOT}/${PODSPEC_FILE}" "${DEST_DIR}/${PODSPEC_FILE}"

git add "${DEST_DIR}/${PODSPEC_FILE}"
if git diff --cached --quiet && [ "$FORCE_UPDATE" = false ]; then
  echo "ℹ️ No new changes detected in specs repo for ${HYBID_PRIVATE_REPO_RELEASE_TAG}."
else
  git commit -m "📦 Add HyBid-private ${HYBID_PRIVATE_REPO_RELEASE_TAG} to specs repo"
  git push origin main --force
  echo "✅ Specs repo updated with version ${HYBID_PRIVATE_REPO_RELEASE_TAG}"
fi

# -------------------------------
# ✅ Summary
# -------------------------------
echo ""
echo "🎉 Done!"
echo "────────────────────────────"
echo "Version:  $HYBID_PRIVATE_REPO_RELEASE_TAG"
echo "Binary:   $TARGET_REPO_URL"
echo "Specs:    $SPECS_REPO_URL"
echo "Force:    $FORCE_UPDATE"
echo "────────────────────────────"
