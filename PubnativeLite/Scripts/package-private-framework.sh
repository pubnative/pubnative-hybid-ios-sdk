#!/bin/bash
set -e

# ========================================
# 📦 Package HyBid SDK for Private Distribution
# ========================================
# Inputs:
#   - HyBid.xcframework (already built and copied to repo root)
#   - OMSDK in repo:  PubnativeLite/**/OMSDK_*/OMSDK_Pubnativenet.xcframework
#   - LICENSE in repo root
# Output:
#   - <repo-root>/HyBid.xcframework.zip
#     (contains LICENSE, HyBid.xcframework, OMSDK_Pubnativenet/)
# ========================================

trap 'rm -rf "$STAGE_DIR"' EXIT

# 🧭 Resolve paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SDK_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
STAGE_DIR="$SDK_ROOT/.private_pkg_tmp"
FINAL_ZIP="$SDK_ROOT/HyBid.xcframework.zip"

echo "🏗 Packaging HyBid SDK for private distribution..."
echo "📦 SDK root: $SDK_ROOT"
echo "📤 Final zip will be: $FINAL_ZIP"

# 🧹 Prepare staging area
rm -rf "$STAGE_DIR"
mkdir -p "$STAGE_DIR"

# 🧱 Ensure HyBid.xcframework exists in repo root
if [ ! -d "$SDK_ROOT/HyBid.xcframework" ]; then
  echo "❌ HyBid.xcframework not found in repo root — build first with generate.sh"
  exit 1
fi
cp -R "$SDK_ROOT/HyBid.xcframework" "$STAGE_DIR/"
echo "✅ Copied HyBid.xcframework into staging."

# 🩹 Fix: Ensure CFBundleShortVersionString is numeric (App Store safe)
echo "🩹 Removing prerelease suffixes from CFBundleShortVersionString inside HyBid.xcframework for App Store compliance..."
find "$STAGE_DIR/HyBid.xcframework" -name "Info.plist" | while read -r plist; do
  current_version=$(/usr/libexec/PlistBuddy -c "Print CFBundleShortVersionString" "$plist" 2>/dev/null || true)
  if [[ "$current_version" == *"-"* ]]; then
    clean_version=$(echo "$current_version" | sed 's/-.*//')
    if ! plutil -replace CFBundleShortVersionString -string "$clean_version" "$plist"; then
      echo "❌ Failed to update CFBundleShortVersionString in $plist"
      exit 1
    fi
    echo "✅ Fixed $plist → $clean_version (was $current_version)"
  else
    echo "ℹ️  $plist already valid → $current_version"
  fi
done

# 🔍 Locate OMSDK in repo
echo "🔍 Searching for OMSDK_Pubnativenet.xcframework..."
OMSDK_PATH="$(find "$SDK_ROOT/PubnativeLite" -type d -name 'OMSDK_Pubnativenet.xcframework' | head -n 1 || true)"
if [ -z "$OMSDK_PATH" ]; then
  echo "❌ OMSDK_Pubnativenet.xcframework not found in PubnativeLite/"
  find "$SDK_ROOT/PubnativeLite" -maxdepth 3 -type d -name "OMSDK_*" || true
  exit 1
fi
echo "✅ Found OMSDK at: $OMSDK_PATH"

# 📂 Place OMSDK under required folder name
mkdir -p "$STAGE_DIR/OMSDK_Pubnativenet"
cp -R "$OMSDK_PATH" "$STAGE_DIR/OMSDK_Pubnativenet/"
echo "✅ Copied OMSDK_Pubnativenet.xcframework into staging."

# 📄 Copy LICENSE
if [ -f "$SDK_ROOT/LICENSE" ]; then
  cp "$SDK_ROOT/LICENSE" "$STAGE_DIR/"
  echo "✅ LICENSE copied into staging."
else
  echo "⚠️ LICENSE file missing — skipping (ensure included in repo)."
fi

# 🧪 Sanity check
echo "🧪 Verifying staging contents..."
ls -la "$STAGE_DIR"
test -d "$STAGE_DIR/HyBid.xcframework" || (echo "❌ Missing HyBid.xcframework in staging." && exit 1)
test -d "$STAGE_DIR/OMSDK_Pubnativenet/OMSDK_Pubnativenet.xcframework" || (echo "❌ Missing OMSDK in staging." && exit 1)

# 🗜 Create final zip
echo "🗜 Creating final HyBid.xcframework.zip..."
rm -f "$FINAL_ZIP"
(
  cd "$STAGE_DIR"
  zip -r "$FINAL_ZIP" LICENSE HyBid.xcframework OMSDK_Pubnativenet >/dev/null
)
echo "✅ Created: $FINAL_ZIP"
ls -lh "$FINAL_ZIP"

# ✅ Copy zip to SDK root (for commit script)
if [ -f "$FINAL_ZIP" ]; then
  echo "📦 HyBid.xcframework.zip ready for commit script."
else
  echo "❌ Failed to create final zip."
  exit 1
fi

# 🧹 Cleanup
rm -rf "$STAGE_DIR"
echo "🧹 Cleaned staging."
echo "🎉 Done."
