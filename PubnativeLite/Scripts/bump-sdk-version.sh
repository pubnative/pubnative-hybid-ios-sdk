#!/bin/bash
set -euo pipefail

# ========================================
# 🔢 HyBid SDK Version Bump
# ========================================
# Ensures the SDK version is correctly set in all mandatory locations, then:
#   base branch 'beta' (betas — the only non-main base accepted): creates a
#     release-prep/hybid-X.Y.Z-betaN head branch, commits, pushes, and opens
#     a PR into beta.
#   base branch 'main' (VMI-1719, official release): cuts the release branch
#     release/hybid-X.Y from main, commits the bump DIRECTLY on it and pushes.
#     No PR — release branches never merge back to main. Pushing the X.Y.Z tag
#     on that branch is what triggers the release pipeline.
#
# Usage:
#   ./bump-sdk-version.sh 3.8.0            (official — base branch defaults to main)
#   ./bump-sdk-version.sh 3.8.0-beta2 beta (beta — base branch 'beta' is required)
#
# Requires: gh CLI authenticated (for opening the PR)
#
# Files checked and updated:
#   HyBid.podspec                                           → s.version + :tag
#   HyBid.xcodeproj/project.pbxproj                        → MARKETING_VERSION (all targets)
#   PubnativeLite/.../HyBidConstants.swift                  → HYBID_SDK_VERSION
#   PubnativeLite/.../GAD Adapter/HyBidGADUtils.m           → // v: comment + majorVersion / minorVersion / patchVersion
#   PubnativeLite/.../GAM Adapter/HyBidGAMUtils.m           → // v: comment + majorVersion / minorVersion / patchVersion
#   PubnativeLite/.../ironSourceAdapter/ISVerveCustomAdapter.m         → networkSDKVersion + adapterVersion
#   PubnativeLite/.../MaxAds/AppLovinMediationVerveCustomNetworkAdapter.m → VERVE_ADAPTER_VERSION
# ========================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SDK_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

PODSPEC="$SDK_ROOT/HyBid.podspec"
PBXPROJ="$SDK_ROOT/PubnativeLite/HyBid.xcodeproj/project.pbxproj"
CONSTANTS="$SDK_ROOT/PubnativeLite/PubnativeLite/Core/Swift/HyBidConstants.swift"
GAD_UTILS="$SDK_ROOT/PubnativeLite/PubnativeLiteDemo/Adapters/GAD Adapter/HyBidGADUtils.m"
GAM_UTILS="$SDK_ROOT/PubnativeLite/PubnativeLiteDemo/Adapters/GAM Adapter/HyBidGAMUtils.m"
IS_ADAPTER="$SDK_ROOT/PubnativeLite/PubnativeLiteDemo/Adapters/ironSourceAdapter/ISVerveCustomAdapter.m"
APPLOVIN_ADAPTER="$SDK_ROOT/PubnativeLite/PubnativeLiteDemo/Adapters/MaxAds/AppLovinMediationVerveCustomNetworkAdapter.m"

# ─── Args & validation ────────────────────────────────────────────────────────

NEW_VERSION="${1:-}"
BASE_BRANCH="${2:-main}"
SET_ONLY=0
if [[ "$BASE_BRANCH" == "--set-only" ]]; then
  SET_ONLY=1
fi

if [[ -z "$NEW_VERSION" ]]; then
  echo "❌ Missing version argument."
  echo "   Usage: $0 <version>"
  echo "   Examples: $0 3.8.0  |  $0 3.8.0-beta2 beta  |  $0 3.9.4 --set-only"
  echo "   --set-only: hotfix mode — set the version files on the CURRENT branch"
  echo "   (must be the branch the tag will sit on), no git operations."
  exit 1
fi

if ! [[ "$NEW_VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+(-beta[0-9]+)?$ ]]; then
  echo "❌ Invalid version format: '$NEW_VERSION'"
  echo "   Expected: X.Y.Z or X.Y.Z-betaN (e.g. 3.8.0 or 3.8.0-beta2)"
  exit 1
fi

# Version type must match the base branch — checked up front, before any file
# is modified. Gate 1 accepts a betaN tag only on 'beta' and a bare tag only
# on its release/hybid-X.Y (cut from main), so any other pairing prepares a
# release that can never be tagged.
if [[ "$SET_ONLY" -eq 1 ]]; then
  # Hotfix mode: files are set on the branch that is currently checked out.
  # Mirror Gate 1 containment so the prepared version can actually be tagged:
  # X.Y.Z belongs on release/hybid-X.Y, X.Y.Z-betaN on beta.
  CURRENT_BRANCH="$(git rev-parse --abbrev-ref HEAD)"
  if [[ "$NEW_VERSION" == *-beta* ]]; then
    EXPECTED_BRANCH="beta"
  else
    EXPECTED_BRANCH="release/hybid-${NEW_VERSION%.*}"
  fi
  if [[ "$CURRENT_BRANCH" != "$EXPECTED_BRANCH" ]]; then
    echo "❌ --set-only: current branch is '$CURRENT_BRANCH' but version $NEW_VERSION belongs on '$EXPECTED_BRANCH'."
    echo "   Check out the branch the tag will sit on (Gate 1 containment), then rerun."
    exit 1
  fi
elif [[ "$NEW_VERSION" == *-beta* && "$BASE_BRANCH" != "beta" ]]; then
  echo "❌ Beta versions are prepared from the 'beta' branch, not '$BASE_BRANCH'."
  echo "   Run prepare-sdk-release from 'beta' (or pass 'beta' as the base branch)."
  exit 1
elif [[ "$NEW_VERSION" != *-beta* && "$BASE_BRANCH" != "main" ]]; then
  echo "❌ Production versions are prepared from 'main', not '$BASE_BRANCH'."
  echo "   Run prepare-sdk-release from 'main' (or omit the base branch argument)."
  exit 1
fi

BASE_VERSION="${NEW_VERSION%%-*}"
IFS='.' read -r V_MAJOR V_MINOR V_PATCH <<< "$BASE_VERSION"

MARKETING_VERSION_VALUE="${BASE_VERSION}"

echo "🔢 Target version: $NEW_VERSION"
echo "   SDK root: $SDK_ROOT"
echo ""

# ─── Helpers ─────────────────────────────────────────────────────────────────

sedi() {
  if [[ "$(uname -s)" == "Darwin" ]]; then
    sed -i '' "$@"
  else
    sed -i "$@"
  fi
}

require_file() {
  local file="$1"
  if [[ ! -f "$file" ]]; then
    echo "❌ File not found: $file"
    exit 1
  fi
}

# ─── Pre-flight: files exist ─────────────────────────────────────────────────

require_file "$PODSPEC"
require_file "$PBXPROJ"
require_file "$CONSTANTS"
require_file "$GAD_UTILS"
require_file "$GAM_UTILS"
require_file "$IS_ADAPTER"
require_file "$APPLOVIN_ADAPTER"

echo "✅ All target files found."
echo ""

# ─── Read current values ─────────────────────────────────────────────────────

cur_podspec=$(grep -E 's\.version\s*=' "$PODSPEC" | grep -oE '"[^"]+"' | tr -d '"' || echo "?")
cur_constants=$(grep -E 'HYBID_SDK_VERSION\s*=' "$CONSTANTS" | grep -oE '"[^"]+"' | tr -d '"' || echo "?")
cur_gad=$(grep -E '// v: ' "$GAD_UTILS" | grep -oE '[0-9]+\.[0-9]+\.[0-9]+[^ ]*' || echo "?")
cur_gam=$(grep -E '// v: ' "$GAM_UTILS" | grep -oE '[0-9]+\.[0-9]+\.[0-9]+[^ ]*' || echo "?")
pbxproj_versions=$(grep -E 'MARKETING_VERSION = ' "$PBXPROJ" | sed -E 's/.*MARKETING_VERSION = "?([^";]+)"?;.*/\1/' || true)
if [[ -n "$pbxproj_versions" ]]; then
  cur_pbxproj=$(printf '%s\n' "$pbxproj_versions" | sort -u | paste -sd ',' -)
else
  cur_pbxproj="?"
fi
cur_is_sdk=$(sed -n '/networkSDKVersion/,/\}/{/return @/p;}' "$IS_ADAPTER" | sed 's/.*return @"\([^"]*\)".*/\1/')
cur_is_adapter=$(sed -n '/adapterVersion/,/\}/{/return @/p;}' "$IS_ADAPTER" | tail -1 | sed 's/.*return @"\([^"]*\)".*/\1/')
cur_applovin=$(grep 'VERVE_ADAPTER_VERSION' "$APPLOVIN_ADAPTER" | grep -oE '"[^"]+"' | tr -d '"' || echo "?")

# ─── Check which files need updating ─────────────────────────────────────────

extract_adapter_numeric_version() {
  local file="$1"
  local major minor patch

  major="$(grep -Eo 'majorVersion[[:space:]]*=[[:space:]]*[0-9]+' "$file" | head -1 | grep -Eo '[0-9]+$' || true)"
  minor="$(grep -Eo 'minorVersion[[:space:]]*=[[:space:]]*[0-9]+' "$file" | head -1 | grep -Eo '[0-9]+$' || true)"
  patch="$(grep -Eo 'patchVersion[[:space:]]*=[[:space:]]*[0-9]+' "$file" | head -1 | grep -Eo '[0-9]+$' || true)"

  if [[ -n "$major" && -n "$minor" && -n "$patch" ]]; then
    printf "%s.%s.%s" "$major" "$minor" "$patch"
  fi
}

NEW_VERSION_NUMERIC="${NEW_VERSION%%-*}"
cur_gad_numeric="$(extract_adapter_numeric_version "$GAD_UTILS")"
cur_gam_numeric="$(extract_adapter_numeric_version "$GAM_UTILS")"

MISMATCHES=()

[[ "$cur_podspec" != "$NEW_VERSION" ]] && MISMATCHES+=("HyBid.podspec (s.version, :tag): '$cur_podspec' → '$NEW_VERSION'")
[[ "$cur_constants" != "$NEW_VERSION" ]] && MISMATCHES+=("HyBidConstants.swift (HYBID_SDK_VERSION): '$cur_constants' → '$NEW_VERSION'")
[[ "$cur_gad" != "$NEW_VERSION" || "$cur_gad_numeric" != "$NEW_VERSION_NUMERIC" ]] && MISMATCHES+=("HyBidGADUtils.m (// v:, majorVersion, minorVersion, patchVersion): comment='$cur_gad', numeric='${cur_gad_numeric:-missing}' → '$NEW_VERSION' / '$NEW_VERSION_NUMERIC'")
[[ "$cur_gam" != "$NEW_VERSION" || "$cur_gam_numeric" != "$NEW_VERSION_NUMERIC" ]] && MISMATCHES+=("HyBidGAMUtils.m (// v:, majorVersion, minorVersion, patchVersion): comment='$cur_gam', numeric='${cur_gam_numeric:-missing}' → '$NEW_VERSION' / '$NEW_VERSION_NUMERIC'")
[[ "$cur_pbxproj" != "$NEW_VERSION_NUMERIC" ]] && MISMATCHES+=("project.pbxproj (MARKETING_VERSION): '$cur_pbxproj' → '$NEW_VERSION_NUMERIC'")
[[ "$cur_is_sdk" != "$NEW_VERSION" ]] && MISMATCHES+=("ISVerveCustomAdapter.m (networkSDKVersion): '$cur_is_sdk' → '$NEW_VERSION'")
[[ "$cur_is_adapter" != "${NEW_VERSION_NUMERIC}.0" ]] && MISMATCHES+=("ISVerveCustomAdapter.m (adapterVersion): '$cur_is_adapter' → '${NEW_VERSION_NUMERIC}.0'")
[[ "$cur_applovin" != "${NEW_VERSION_NUMERIC}.0" ]] && MISMATCHES+=("AppLovinMediationVerveCustomNetworkAdapter.m (VERVE_ADAPTER_VERSION): '$cur_applovin' → '${NEW_VERSION_NUMERIC}.0'")

# ─── Prompt if updates needed ─────────────────────────────────────────────────

if [[ "${#MISMATCHES[@]}" -gt 0 ]]; then
  echo "📝 Updating the following locations:"
  for m in "${MISMATCHES[@]}"; do
    echo "   • $m"
  done
  echo ""

  sedi -E "s|(s\.version[[:space:]]*=[[:space:]]*\")[^\"]+(\")|\1${NEW_VERSION}\2|" "$PODSPEC"
  sedi -E "s|(:tag => \")[^\"]+(\")|\1${NEW_VERSION}\2|" "$PODSPEC"
  sedi -E "s|(HYBID_SDK_VERSION[[:space:]]*=[[:space:]]*\")[^\"]+(\"[^\"]*$)|\1${NEW_VERSION}\2|" "$CONSTANTS"
  sedi -E "s|(// v: )[0-9]+\.[0-9]+\.[0-9]+[^[:space:]]*|\1${NEW_VERSION}|" "$GAD_UTILS"
  sedi -E "s|(version\.majorVersion = )[0-9]+(;)|\1${V_MAJOR}\2|g" "$GAD_UTILS"
  sedi -E "s|(version\.minorVersion = )[0-9]+(;)|\1${V_MINOR}\2|g" "$GAD_UTILS"
  sedi -E "s|(version\.patchVersion = )[0-9]+(;)|\1${V_PATCH}\2|g" "$GAD_UTILS"
  sedi -E "s|(// v: )[0-9]+\.[0-9]+\.[0-9]+[^[:space:]]*|\1${NEW_VERSION}|" "$GAM_UTILS"
  sedi -E "s|(version\.majorVersion = )[0-9]+(;)|\1${V_MAJOR}\2|g" "$GAM_UTILS"
  sedi -E "s|(version\.minorVersion = )[0-9]+(;)|\1${V_MINOR}\2|g" "$GAM_UTILS"
  sedi -E "s|(version\.patchVersion = )[0-9]+(;)|\1${V_PATCH}\2|g" "$GAM_UTILS"
  sedi -E "s|(MARKETING_VERSION = )\"?[0-9][^\";]*\"?(;)|\1${MARKETING_VERSION_VALUE}\2|g" "$PBXPROJ"
  sedi '/adapterVersion/,/\}/{s/return @"[^"]*"/return @"'"${NEW_VERSION_NUMERIC}.0"'"/;}' "$IS_ADAPTER"
  sedi '/networkSDKVersion/,/\}/{s/return @"[^"]*"/return @"'"${NEW_VERSION}"'"/;}' "$IS_ADAPTER"
  sedi -E "s|(#define VERVE_ADAPTER_VERSION @\")[^\"]+(\")|\1${NEW_VERSION_NUMERIC}.0\2|" "$APPLOVIN_ADAPTER"

  echo "   Done."
else
  echo "✅ All locations already set to $NEW_VERSION — no changes needed."
fi

echo ""

# ─── Validate all mandatory locations ────────────────────────────────────────

echo "🔍 Validating..."
VALIDATION_ERRORS=0

validate() {
  local pattern="$1"
  local file="$2"
  local label="$3"
  if ! grep -qE "$pattern" "$file"; then
    echo "   ❌ $label"
    VALIDATION_ERRORS=$((VALIDATION_ERRORS + 1))
  else
    echo "   ✅ $label"
  fi
}

validate "s\.version\s*=\s*\"${NEW_VERSION//./\\.}\""              "$PODSPEC"         "HyBid.podspec → s.version"
validate ":tag => \"${NEW_VERSION//./\\.}\""                       "$PODSPEC"         "HyBid.podspec → :tag"
validate "HYBID_SDK_VERSION\s*=\s*\"${NEW_VERSION//./\\.}\""       "$CONSTANTS"       "HyBidConstants.swift → HYBID_SDK_VERSION"
validate "// v: ${NEW_VERSION//./\\.}"                             "$GAD_UTILS"       "HyBidGADUtils.m → // v:"
validate "version\.majorVersion = ${V_MAJOR}"                      "$GAD_UTILS"       "HyBidGADUtils.m → majorVersion"
validate "version\.minorVersion = ${V_MINOR}"                      "$GAD_UTILS"       "HyBidGADUtils.m → minorVersion"
validate "version\.patchVersion = ${V_PATCH}"                      "$GAD_UTILS"       "HyBidGADUtils.m → patchVersion"
validate "// v: ${NEW_VERSION//./\\.}"                             "$GAM_UTILS"       "HyBidGAMUtils.m → // v:"
validate "version\.majorVersion = ${V_MAJOR}"                      "$GAM_UTILS"       "HyBidGAMUtils.m → majorVersion"
validate "version\.minorVersion = ${V_MINOR}"                      "$GAM_UTILS"       "HyBidGAMUtils.m → minorVersion"
validate "version\.patchVersion = ${V_PATCH}"                      "$GAM_UTILS"       "HyBidGAMUtils.m → patchVersion"
total_marketing_version_lines=$(grep -cE 'MARKETING_VERSION = .*;' "$PBXPROJ" || true)
matching_marketing_version_lines=$(grep -cE "MARKETING_VERSION = ${MARKETING_VERSION_VALUE//./\\.};" "$PBXPROJ" || true)
if [[ "$total_marketing_version_lines" -eq 0 || "$matching_marketing_version_lines" -ne "$total_marketing_version_lines" ]]; then
  echo "❌ Validation failed: project.pbxproj → MARKETING_VERSION (expected all ${total_marketing_version_lines} occurrence(s) to be ${MARKETING_VERSION_VALUE}, found ${matching_marketing_version_lines})"
  VALIDATION_ERRORS=$((VALIDATION_ERRORS + 1))
else
  echo "✅ Validated: project.pbxproj → MARKETING_VERSION (${matching_marketing_version_lines}/${total_marketing_version_lines})"
fi
validate "return @\"${NEW_VERSION//./\\.}\""                       "$IS_ADAPTER"      "ISVerveCustomAdapter.m → networkSDKVersion"
validate "return @\"${NEW_VERSION_NUMERIC//./\\.}\.0\""                    "$IS_ADAPTER"      "ISVerveCustomAdapter.m → adapterVersion"
validate "VERVE_ADAPTER_VERSION @\"${NEW_VERSION_NUMERIC//./\\.}\.0\""     "$APPLOVIN_ADAPTER" "AppLovinMediationVerveCustomNetworkAdapter.m → VERVE_ADAPTER_VERSION"

if [[ "$VALIDATION_ERRORS" -gt 0 ]]; then
  echo ""
  echo "❌ $VALIDATION_ERRORS validation check(s) failed — aborting."
  exit 1
fi

echo ""
echo "✅ All locations validated."

if [[ "$SET_ONLY" -eq 1 ]]; then
  echo ""
  echo "🎉 Done — version files set to ${NEW_VERSION} on ${CURRENT_BRANCH} (no git operations)."
  echo "   Next: review the diff, commit it on this branch, wait for CI to build,"
  echo "   then tag the remote branch tip to release:"
  echo "     git fetch origin && git tag -a ${NEW_VERSION} -m \"Release ${NEW_VERSION}\" origin/${CURRENT_BRANCH} && git push origin ${NEW_VERSION}"
  exit 0
fi

# ─── Build PR table rows ──────────────────────────────────────────────────────

# For rows that were updated: show before → after. Already correct: show value only.
was_changed() { local before="$1"; [[ "$before" != "$NEW_VERSION" ]]; }
was_changed_adapter() { local before="$1"; [[ "$before" != "${NEW_VERSION_NUMERIC}.0" ]]; }

podspec_row() {
  if was_changed "$cur_podspec"; then
    echo "| \`HyBid.podspec\` | \`s.version\`, \`:tag\` | \`$cur_podspec\` | \`$NEW_VERSION\` |"
  else
    echo "| \`HyBid.podspec\` | \`s.version\`, \`:tag\` | | \`$NEW_VERSION\` |"
  fi
}
constants_row() {
  if was_changed "$cur_constants"; then
    echo "| \`HyBidConstants.swift\` | \`HYBID_SDK_VERSION\` | \`$cur_constants\` | \`$NEW_VERSION\` |"
  else
    echo "| \`HyBidConstants.swift\` | \`HYBID_SDK_VERSION\` | | \`$NEW_VERSION\` |"
  fi
}
gad_row() {
  if was_changed "$cur_gad" || [[ "$cur_gad_numeric" != "$NEW_VERSION_NUMERIC" ]]; then
    echo "| \`HyBidGADUtils.m\` | \`// v:\`, \`majorVersion\`, \`minorVersion\`, \`patchVersion\` | \`$cur_gad\` | \`$NEW_VERSION\` |"
  else
    echo "| \`HyBidGADUtils.m\` | \`// v:\`, \`majorVersion\`, \`minorVersion\`, \`patchVersion\` | | \`$NEW_VERSION\` |"
  fi
}
gam_row() {
  if was_changed "$cur_gam" || [[ "$cur_gam_numeric" != "$NEW_VERSION_NUMERIC" ]]; then
    echo "| \`HyBidGAMUtils.m\` | \`// v:\`, \`majorVersion\`, \`minorVersion\`, \`patchVersion\` | \`$cur_gam\` | \`$NEW_VERSION\` |"
  else
    echo "| \`HyBidGAMUtils.m\` | \`// v:\`, \`majorVersion\`, \`minorVersion\`, \`patchVersion\` | | \`$NEW_VERSION\` |"
  fi
}
pbxproj_row() {
  if [[ "$cur_pbxproj" != "$MARKETING_VERSION_VALUE" ]]; then
    echo "| \`project.pbxproj\` | \`MARKETING_VERSION\` | \`$cur_pbxproj\` | \`$MARKETING_VERSION_VALUE\` |"
  else
    echo "| \`project.pbxproj\` | \`MARKETING_VERSION\` | | \`$MARKETING_VERSION_VALUE\` |"
  fi
}
is_row() {
  if was_changed "$cur_is_sdk" || was_changed_adapter "$cur_is_adapter"; then
    echo "| \`ISVerveCustomAdapter.m\` | \`networkSDKVersion\`, \`adapterVersion\` | \`$cur_is_sdk\` / \`$cur_is_adapter\` | \`$NEW_VERSION\` / \`${NEW_VERSION_NUMERIC}.0\` |"
  else
    echo "| \`ISVerveCustomAdapter.m\` | \`networkSDKVersion\`, \`adapterVersion\` | | \`$NEW_VERSION\` / \`${NEW_VERSION_NUMERIC}.0\` |"
  fi
}
applovin_row() {
  if was_changed_adapter "$cur_applovin"; then
    echo "| \`AppLovinMediationVerveCustomNetworkAdapter.m\` | \`VERVE_ADAPTER_VERSION\` | \`$cur_applovin\` | \`${NEW_VERSION_NUMERIC}.0\` |"
  else
    echo "| \`AppLovinMediationVerveCustomNetworkAdapter.m\` | \`VERVE_ADAPTER_VERSION\` | | \`${NEW_VERSION_NUMERIC}.0\` |"
  fi
}

PR_TABLE="$(podspec_row)
$(constants_row)
$(gad_row)
$(gam_row)
$(pbxproj_row)
$(is_row)
$(applovin_row)"

# ─── Git: branch, commit, push, PR ───────────────────────────────────────────

# Official release from main (VMI-1719): the bump lands directly on the
# release branch release/hybid-X.Y — no head branch, no PR.
if [[ "${BASE_BRANCH}" == "main" ]]; then
  RELEASE_MODE="branch"
  BRANCH="release/hybid-${NEW_VERSION%.*}"
else
  RELEASE_MODE="pr"
  # NOT release/… — config.yml's publish jobs match release/** (fnmatch, **
  # crosses /), and the head branch of a [release] PR must not publish the
  # beta a second time before the merge into beta does.
  BRANCH="release-prep/hybid-${NEW_VERSION}"
fi
VERSION_FILES=(
  "HyBid.podspec"
  "PubnativeLite/HyBid.xcodeproj/project.pbxproj"
  "PubnativeLite/PubnativeLite/Core/Swift/HyBidConstants.swift"
  "PubnativeLite/PubnativeLiteDemo/Adapters/GAD Adapter/HyBidGADUtils.m"
  "PubnativeLite/PubnativeLiteDemo/Adapters/GAM Adapter/HyBidGAMUtils.m"
  "PubnativeLite/PubnativeLiteDemo/Adapters/ironSourceAdapter/ISVerveCustomAdapter.m"
  "PubnativeLite/PubnativeLiteDemo/Adapters/MaxAds/AppLovinMediationVerveCustomNetworkAdapter.m"
)
VERSION_STASH_NAME="bump-sdk-version-${NEW_VERSION}"
VERSION_STASH_CREATED=0

echo "🌿 Creating branch: $BRANCH (from $BASE_BRANCH)"
cd "$SDK_ROOT"

if ! git diff --quiet -- "${VERSION_FILES[@]}" || ! git diff --cached --quiet -- "${VERSION_FILES[@]}"; then
  git stash push --quiet -m "$VERSION_STASH_NAME" -- "${VERSION_FILES[@]}"
  VERSION_STASH_CREATED=1
fi

if ! git diff --quiet || ! git diff --cached --quiet; then
  echo "❌ Working tree is not clean."
  echo "   Please commit or stash your tracked changes before running this script."
  if [ "$VERSION_STASH_CREATED" -eq 1 ]; then
    git stash pop --quiet
  fi
  exit 1
fi

git fetch origin "$BASE_BRANCH"

if git show-ref --verify --quiet "refs/heads/$BRANCH"; then
  echo "❌ Local branch '$BRANCH' already exists."
  echo "   Please delete it or use a different version before rerunning this script."
  if [ "$VERSION_STASH_CREATED" -eq 1 ]; then
    git stash pop --quiet
  fi
  exit 1
fi

if git ls-remote --exit-code --heads origin "$BRANCH" >/dev/null 2>&1; then
  if [[ "$RELEASE_MODE" == "branch" ]]; then
    # A shipped release line — NEVER suggest deleting it.
    echo "❌ Release line 'origin/$BRANCH' already exists — a ${NEW_VERSION%.*}.x version has already been cut."
    echo "   For a hotfix on that line: check out '$BRANCH', land the fix and the"
    echo "   ${NEW_VERSION} version bump there, then push the ${NEW_VERSION} tag on it."
    echo "   Do not delete a shipped release branch."
  else
    echo "❌ Remote branch 'origin/$BRANCH' already exists."
    echo "   Please delete it or use a different version before rerunning this script."
  fi
  if [ "$VERSION_STASH_CREATED" -eq 1 ]; then
    git stash pop --quiet
  fi
  exit 1
fi
git checkout -b "$BRANCH" "origin/$BASE_BRANCH"

if [ "$VERSION_STASH_CREATED" -eq 1 ]; then
  git stash pop --quiet
fi

git add "${VERSION_FILES[@]}"
if git diff --cached --quiet; then
  if [[ "$RELEASE_MODE" == "branch" ]]; then
    # Expected on every second official release: main was already bumped to
    # X.Y.Z right after the previous release was cut, so there is nothing to
    # commit — but in branch mode the BRANCH ITSELF is the deliverable
    # (Gate 1 requires the tag to sit on release/hybid-X.Y), so it must
    # still be pushed.
    echo "⚠️  No file changes to commit — version was already $NEW_VERSION everywhere."
    echo "   Pushing $BRANCH without a bump commit (the branch is the release signal)."
  else
    echo "❌ No file changes to commit — version was already $NEW_VERSION everywhere."
    echo "   Nothing to put in a [release] PR. Deleting branch and exiting."
    git checkout -
    git branch -d "$BRANCH"
    exit 1
  fi
else
  git commit -m "[release] ${NEW_VERSION}"
fi

echo "🚀 Pushing branch..."
git push origin "$BRANCH"

if [[ "$RELEASE_MODE" == "branch" ]]; then
  echo ""
  echo "🎉 Done — release branch ${BRANCH} cut from ${BASE_BRANCH} with the ${NEW_VERSION} bump."
  echo "   Next steps:"
  echo "   1. Bump ${BASE_BRANCH} to the next version (main must never be stale)."
  echo "   2. Wait for CI to build ${BRANCH}, then push the tag to release"
  echo "      (pinned to the remote branch tip, not your local HEAD):"
  echo "        git fetch origin && git tag -a ${NEW_VERSION} -m \"Release ${NEW_VERSION}\" origin/${BRANCH} && git push origin ${NEW_VERSION}"
  exit 0
fi

echo "📬 Opening PR..."
gh pr create \
  --base "$BASE_BRANCH" \
  --head "$BRANCH" \
  --title "[release] ${NEW_VERSION}" \
  --body "## Release prep — \`${NEW_VERSION}\`

Automated version bump. No logic changes — version references only.

### Version set in

| File | Field | Before | After |
|------|-------|--------|-------|
${PR_TABLE}

> Rows with no **Before** value were already correct.

### How to release

1. Merge this PR into \`${BASE_BRANCH}\` (merging alone releases nothing).
2. Wait for CI to build the merge commit.
3. Push the tag — that starts the release pipeline (VMI-1719):
\`\`\`
git fetch origin && git tag -a ${NEW_VERSION} -m \"Release ${NEW_VERSION}\" origin/${BASE_BRANCH} && git push origin ${NEW_VERSION}
\`\`\`"

# ─── Done ────────────────────────────────────────────────────────────────────

echo ""
echo "🎉 Done — PR opened to ${BASE_BRANCH}."
echo "   Merge it, wait for CI, then push the ${NEW_VERSION} tag to release."
