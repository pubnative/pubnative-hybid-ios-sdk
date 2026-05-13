#!/bin/bash
set -euo pipefail

# Variable Declarations
BASE_DIR="${RUNNER_TEMP:-/tmp}"
PRODUCT_NAME=HyBidDemo
HYBID_DEMO_APP_NAME="${PRODUCT_NAME}.app"
DERIVED_DATA_PATH="${BASE_DIR}/${PRODUCT_NAME}-DerivedData"
HYBID_DEMO_APP_ZIP_PATH="${GITHUB_WORKSPACE:-$(pwd)}/build/HyBidDemo.app.zip"

# Show Current Versions
xcodebuild -showsdks

# Install cocoapods dependencies (skipped on CI — already done by the workflow)
if [ "${GITHUB_ACTIONS:-}" != "true" ]; then
  pod install
fi

# Generate HyBid Demo App
# NOTE: We use -derivedDataPath (not CONFIGURATION_BUILD_DIR) so that
# PODS_CONFIGURATION_BUILD_DIR (derived from BUILD_DIR) and the pod targets'
# output directory stay in sync. Using CONFIGURATION_BUILD_DIR alone redirects
# where pods build their products but NOT where the CocoaPods copy-resources
# script looks for them, causing "bundle not found" errors at build time.
xcodebuild \
  -sdk iphonesimulator \
  -destination 'generic/platform=iOS Simulator' \
  -workspace HyBid.xcworkspace \
  -scheme HyBidDemo \
  -derivedDataPath "$DERIVED_DATA_PATH"

# Find .app in derived data
APP_DIR="${DERIVED_DATA_PATH}/Build/Products/Debug-iphonesimulator"
HYBID_DEMO_APP="${APP_DIR}/${HYBID_DEMO_APP_NAME}"

if [ ! -d "$HYBID_DEMO_APP" ]; then
  echo "❌ ${HYBID_DEMO_APP_NAME} not found at: $HYBID_DEMO_APP"
  exit 1
fi

# Create a .zip HyBid Demo App (cd first so zip root contains only HyBidDemo.app)
mkdir -p "$(dirname "$HYBID_DEMO_APP_ZIP_PATH")"
cd "$APP_DIR"
zip -r "$HYBID_DEMO_APP_ZIP_PATH" "$HYBID_DEMO_APP_NAME"
echo "✅ Created: $HYBID_DEMO_APP_ZIP_PATH"
