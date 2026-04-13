#!/bin/bash
set -euo pipefail

# ===========================================
# 🚀 HyBid dSYM Upload to Firebase Crashlytics
# ===========================================
# Safe for CI and local use. Uploads dSYMs to Firebase
# with clear warnings but no fallback copies.
# ===========================================

BUILD_DIR=${1:-"./build"}
SYMBOLS_DIR="$BUILD_DIR/symbols"
FIREBASE_GSP_PATH=${FIREBASE_GSP_PATH:-"./PubnativeLite/PubnativeLiteDemo/GoogleService-Info.plist"}
UPLOAD_SCRIPT="./Pods/FirebaseCrashlytics/upload-symbols"

mkdir -p "$SYMBOLS_DIR"

echo "🔍 Searching for HyBid dSYM files in $BUILD_DIR and HyBid.xcframework ..."
DSYM_FOUND=$(find "$BUILD_DIR" "$PWD/HyBid.xcframework" -type d -name "HyBid.framework.dSYM" 2>/dev/null | head -n 1 || true)

if [ -z "$DSYM_FOUND" ]; then
  echo "⚠️  No HyBid dSYM found in $BUILD_DIR or HyBid.xcframework — skipping symbol upload."
  exit 0
else
  echo "✅ Found dSYM at: $DSYM_FOUND"
fi

# Zip all found dSYMs
echo "📦 Zipping dSYM files..."
find "$BUILD_DIR" "$PWD/HyBid.xcframework" -type d -name "HyBid.framework.dSYM" -exec zip -r "$SYMBOLS_DIR/HyBid.framework.dSYM.zip" {} + >/dev/null

if [ ! -f "$SYMBOLS_DIR/HyBid.framework.dSYM.zip" ]; then
  echo "❌ Failed to create dSYM zip — aborting upload."
  exit 0
fi

# --- Safety checks ---
if [ ! -f "$FIREBASE_GSP_PATH" ]; then
  echo "⚠️  Missing GoogleService-Info.plist at: $FIREBASE_GSP_PATH"
  echo "💡  Verify Firebase config path or set FIREBASE_GSP_PATH env var."
  exit 0
fi

if [ ! -x "$UPLOAD_SCRIPT" ]; then
  echo "⚠️  Firebase upload-symbols tool not found."
  echo "💡  Run 'pod install' before executing this script."
  exit 0
fi

if [ -z "${FIREBASE_SERVICE_ACCOUNT_JSON:-}" ]; then
  echo "⚠️  FIREBASE_SERVICE_ACCOUNT_JSON not set — skipping Firebase upload."
  exit 0
fi

# --- Perform upload ---
echo "🚀 Uploading dSYM to Firebase Crashlytics..."
set +e
$UPLOAD_SCRIPT -gsp "$FIREBASE_GSP_PATH" -p ios "$SYMBOLS_DIR/HyBid.framework.dSYM.zip"
UPLOAD_EXIT=$?
set -e

if [ $UPLOAD_EXIT -ne 0 ]; then
  echo "⚠️  Firebase Crashlytics upload failed (exit code $UPLOAD_EXIT)"
  echo "💡  The build will continue, but symbols for this version may not appear in Firebase."
else
  echo "✅ Firebase Crashlytics symbol upload completed successfully."
fi

# --- Manifest for traceability ---
cat <<EOF > "$SYMBOLS_DIR/manifest.json"
{
  "version": "${HYBID_PRIVATE_REPO_RELEASE_TAG:-unknown}",
  "branch": "${CIRCLE_BRANCH:-unknown}",
  "commit": "$(git rev-parse HEAD 2>/dev/null || echo 'unknown')",
  "build_num": "${CIRCLE_BUILD_NUM:-local}",
  "upload_exit_code": "$UPLOAD_EXIT",
  "created_at": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
}
EOF

echo "🧾 Manifest written to $SYMBOLS_DIR/manifest.json"
echo "✅ dSYM upload script finished."
