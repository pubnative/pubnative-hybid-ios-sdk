#!/bin/bash
set -euo pipefail

# ========================================
# 🏗 Generate HyBid.xcframework for Distribution
# ========================================
# Builds iOS and Simulator frameworks, merges them into an .xcframework,
# strips redundant Swift interface references, and prepares it for packaging.
#
# 📦 Output:
#   - HyBid.xcframework  (copied to the repo root for packaging)
#
# 💻 Usage:
#   ./PubnativeLite/Scripts/generate.sh
#   ./PubnativeLite/Scripts/generate.sh HyBid   (optional product name)
#   HYBID_MIN_IOS=12.0 ./PubnativeLite/Scripts/generate.sh   (override the minimum iOS, default 13.0)
#
# 🧩 Notes:
#   - Must run before package-private-framework.sh.
#   - Uses a temp artifacts dir that works locally and on GitHub Actions.
#   - Minimum iOS: Xcode 16+ rejects IPHONEOS_DEPLOYMENT_TARGET values below its SDK floor
#     (15.0 on Xcode 26/27), although its compilers and linker still target older iOS.
#     When HYBID_MIN_IOS is below that floor, the build passes the floor as
#     IPHONEOS_DEPLOYMENT_TARGET (to satisfy Xcode's check) and sets the compile/link
#     target with LLVM_TARGET_TRIPLE_OS_VERSION. Afterwards it rewrites each framework's
#     MinimumOSVersion and verifies the minos recorded in every slice.
#     LLVM_TARGET_TRIPLE_OS_VERSION is an undocumented Xcode build setting; re-check on each
#     new Xcode. Builds below the floor can't be run on simulators/devices from Xcode 16+,
#     so test them on real hardware.
# ========================================

# Accept SCHEME + PRODUCT_NAME as arguments
SCHEME=${1:-HyBid}             # Build scheme (must exist in workspace)
PRODUCT_NAME=${2:-$SCHEME}     # Output framework/module name (e.g. Smaato_HyBid)

export LIBXML2_CFLAGS=$(xml2-config --cflags)
export LIBXML2_LIBS=$(xml2-config --libs)

# -------------------------------
# 📂 Resolve paths
# -------------------------------
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SDK_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
DEST_DIR="$SDK_ROOT"

# -------------------------------
# 📦 Artifacts dir
# -------------------------------
if [ "${GITHUB_ACTIONS:-}" = "true" ] && [ -n "${RUNNER_TEMP:-}" ]; then
  BASE_DIR="${RUNNER_TEMP}/hybid-artifacts"
else
  BASE_DIR="/tmp/hybid-artifacts"
fi

DERIVED_DATA_PATH="${BASE_DIR}/DerivedData"

FRAMEWORK_NAME=$PRODUCT_NAME.framework
FRAMEWORK_DSYM_NAME=$FRAMEWORK_NAME.dSYM
XCFRAMEWORK_NAME=$PRODUCT_NAME.xcframework
XCFRAMEWORK=$BASE_DIR/$XCFRAMEWORK_NAME
IPHONEOS_PATH=$BASE_DIR/iphoneos
IPHONEOS_FRAMEWORK=$IPHONEOS_PATH/$FRAMEWORK_NAME
IPHONESIMULATOR_PATH=$BASE_DIR/iphonesimulator
IPHONESIMULATOR_FRAMEWORK=$IPHONESIMULATOR_PATH/$FRAMEWORK_NAME
IPHONEOS_DSYM=$IPHONEOS_PATH/$FRAMEWORK_DSYM_NAME
IPHONESIMULATOR_DSYM=$IPHONESIMULATOR_PATH/$FRAMEWORK_DSYM_NAME
IPHONE_BCSYMBOLMAP_PATHS=$IPHONEOS_PATH/*

# -------------------------------
# 📱 Minimum iOS version
# -------------------------------
MIN_IOS="${HYBID_MIN_IOS:-13.0}"
echo "$MIN_IOS" | grep -Eq '^[0-9]+\.[0-9]+$' || { echo "❌ HYBID_MIN_IOS must look like 12.0 (got '$MIN_IOS')"; exit 1; }

# "12.0" → 1200, "14.5" → 1405 (major.minor only, enough for deployment targets)
ios_version_number() { echo "$1" | awk -F. '{ printf "%d", ($1 * 100) + ($2 + 0) }'; }

SDK_FLOOR="$(plutil -extract SupportedTargets.iphoneos.MinimumDeploymentTarget raw \
  "$(xcrun --sdk iphoneos --show-sdk-path)/SDKSettings.plist" 2>/dev/null || true)"
SDK_FLOOR="${SDK_FLOOR:-$MIN_IOS}"

if [ "$(ios_version_number "$MIN_IOS")" -lt "$(ios_version_number "$SDK_FLOOR")" ]; then
  # Below Xcode's floor: satisfy the build-system check, force the compiler/linker target.
  DEPLOYMENT_SETTINGS=(IPHONEOS_DEPLOYMENT_TARGET="$SDK_FLOOR" LLVM_TARGET_TRIPLE_OS_VERSION="ios$MIN_IOS")
  echo "📱 Minimum iOS: $MIN_IOS (below this Xcode's floor of $SDK_FLOOR → using LLVM_TARGET_TRIPLE_OS_VERSION)"
else
  DEPLOYMENT_SETTINGS=(IPHONEOS_DEPLOYMENT_TARGET="$MIN_IOS")
  echo "📱 Minimum iOS: $MIN_IOS"
fi

# -------------------------------
# 🚫 No code-coverage instrumentation in release binaries
# -------------------------------
# The HyBid scheme enables code coverage for its Test action, and xcodebuild carries that into
# `-scheme HyBid build` (ENABLE_CODE_COVERAGE=YES, CLANG_COVERAGE_MAPPING=YES), which compiles
# Swift with -profile-generate and links libclang_rt.profile. Force it off for distribution builds.
#
# ⚡ Optimisation: standard Release levels, stated explicitly. (Until 3.9.3 this script
# forced GCC_OPTIMIZATION_LEVEL=0 / SWIFT_OPTIMIZATION_LEVEL=-Onone, shipping unoptimised
# binaries; the project's own Release configuration never asked for that.)
RELEASE_SETTINGS=(
  ENABLE_CODE_COVERAGE=NO CLANG_ENABLE_CODE_COVERAGE=NO CLANG_COVERAGE_MAPPING=NO
  GCC_OPTIMIZATION_LEVEL=s SWIFT_OPTIMIZATION_LEVEL=-O SWIFT_COMPILATION_MODE=wholemodule
)

echo "📍 Script directory: $SCRIPT_DIR"
echo "📦 SDK root directory: $SDK_ROOT"
echo "📤 Framework destination: $DEST_DIR"
echo "🗂 Artifacts directory: $BASE_DIR"

mkdir -p "$BASE_DIR" "$IPHONEOS_PATH" "$IPHONESIMULATOR_PATH"

# Ensure clean output before building new XCFramework
rm -rf "$XCFRAMEWORK"
rm -rf "$DERIVED_DATA_PATH"

# -------------------------------
# ⚙️ Build iPhoneOS framework
# -------------------------------
echo "⚙️ Building iPhoneOS framework..."
xcodebuild -workspace HyBid.xcworkspace \
  -scheme "$SCHEME" \
  -sdk iphoneos \
  -destination 'generic/platform=iOS' \
  -derivedDataPath "$DERIVED_DATA_PATH" \
  -configuration Release \
  build \
  CODE_SIGN_IDENTITY="" \
  CODE_SIGNING_REQUIRED=NO \
  CONFIGURATION_BUILD_DIR="$IPHONEOS_PATH" \
  "${DEPLOYMENT_SETTINGS[@]}" \
  "${RELEASE_SETTINGS[@]}" \
  ENABLE_STRICT_OBJC_MSGSEND=NO \
  CLANG_ENABLE_OBJC_ARC=YES \
  OTHER_LDFLAGS="-ObjC -all_load -weak_framework Foundation -weak_framework UIKit" \
  OTHER_CFLAGS="-fobjc-arc" \
  VALIDATE_PRODUCT=NO \
  -UseModernBuildSystem=YES | bundle exec xcpretty -c

# -------------------------------
# ⚙️ Build iPhoneSimulator framework
# -------------------------------
echo "⚙️ Building iPhoneSimulator framework..."
xcodebuild -workspace HyBid.xcworkspace \
  -scheme "$SCHEME" \
  -sdk iphonesimulator \
  -destination 'generic/platform=iOS Simulator' \
  -derivedDataPath "$DERIVED_DATA_PATH" \
  -configuration Release \
  build \
  CONFIGURATION_BUILD_DIR="$IPHONESIMULATOR_PATH" \
  "${DEPLOYMENT_SETTINGS[@]}" \
  "${RELEASE_SETTINGS[@]}" \
  ENABLE_STRICT_OBJC_MSGSEND=NO \
  CLANG_ENABLE_OBJC_ARC=YES \
  OTHER_LDFLAGS="-ObjC -all_load -weak_framework Foundation -weak_framework UIKit" \
  OTHER_CFLAGS="-fobjc-arc" \
  VALIDATE_PRODUCT=NO \
  -UseModernBuildSystem=YES | bundle exec xcpretty -c

# -------------------------------
# 🔍 Collect .bcsymbolmap files
# -------------------------------
echo "🔍 Collecting .bcsymbolmap files..."
IPHONE_BCSYMBOLMAP_COMMANDS=""
for path in $IPHONE_BCSYMBOLMAP_PATHS; do
  if [[ ${path} =~ ".bcsymbolmap" ]]; then
    IPHONE_BCSYMBOLMAP_COMMANDS="$IPHONE_BCSYMBOLMAP_COMMANDS -debug-symbols $path "
  fi
done

# -------------------------------
# 🏗 Create XCFramework
# -------------------------------
echo "🏗 Creating XCFramework..."
xcodebuild -create-xcframework \
  -framework "$IPHONEOS_FRAMEWORK" -debug-symbols "$IPHONEOS_DSYM" $IPHONE_BCSYMBOLMAP_COMMANDS \
  -framework "$IPHONESIMULATOR_FRAMEWORK" -debug-symbols "$IPHONESIMULATOR_DSYM" \
  -output "$XCFRAMEWORK"

# -------------------------------
# 📱 Enforce and verify the minimum iOS version
# -------------------------------
# MinimumOSVersion in Info.plist follows IPHONEOS_DEPLOYMENT_TARGET (the Xcode floor when
# HYBID_MIN_IOS is lower). App Store validation compares it with the host app's minimum,
# so it must match the minos actually compiled into the binary.
echo "📱 Setting MinimumOSVersion=$MIN_IOS and verifying binaries..."
MIN_IOS_NUM="$(ios_version_number "$MIN_IOS")"
for SLICE_DIR in "$XCFRAMEWORK"/ios-*; do
  SLICE="$(basename "$SLICE_DIR")"
  FW_PLIST="$SLICE_DIR/$FRAMEWORK_NAME/Info.plist"
  FW_BINARY="$SLICE_DIR/$FRAMEWORK_NAME/$PRODUCT_NAME"
  plutil -replace MinimumOSVersion -string "$MIN_IOS" "$FW_PLIST"

  for ARCH in $(lipo -archs "$FW_BINARY"); do
    # arm64 simulators only exist from iOS 14, so the linker records max(MIN_IOS, 14.0) there.
    EXPECTED_NUM="$MIN_IOS_NUM"
    case "$SLICE:$ARCH" in
      *simulator:arm64) [ "$EXPECTED_NUM" -lt 1400 ] && EXPECTED_NUM=1400 ;;
    esac
    FOUND="$(otool -arch "$ARCH" -l "$FW_BINARY" | awk '/LC_BUILD_VERSION/{f=1} f && $1=="minos"{print $2; exit}')"
    if [ -z "$FOUND" ] || [ "$(ios_version_number "$FOUND")" -ne "$EXPECTED_NUM" ]; then
      echo "❌ $SLICE/$ARCH: minos is '${FOUND:-missing}', expected $(echo "$EXPECTED_NUM" | awk '{printf "%d.%d", $1/100, $1%100}')"
      exit 1
    fi
    # Coverage instrumentation leaves __llvm_prf_* sections (and the profile runtime) behind.
    if otool -arch "$ARCH" -l "$FW_BINARY" | grep -q '__llvm_prf'; then
      echo "❌ $SLICE/$ARCH: binary contains code-coverage instrumentation (__llvm_prf_* sections)"
      exit 1
    fi
    echo "   ✅ $SLICE/$ARCH: minos $FOUND, no coverage instrumentation"
  done
done

# -------------------------------
# 🧹 Clean Swift interfaces
# -------------------------------
echo "🧹 Cleaning Swift interface imports..."
cd "$BASE_DIR"
find . -name "*.swiftinterface" -exec sed -i '' "s/${PRODUCT_NAME}\.//g" {} \;

# Debug: check result
echo "🔍 Searching for ${PRODUCT_NAME}.xcframework after build..."
find "$BASE_DIR" -type d -name "${PRODUCT_NAME}.xcframework" || echo "❌ ${PRODUCT_NAME}.xcframework not found after generation"

# -------------------------------
# 📦 Copy to SDK root (for packaging step)
# -------------------------------
FINAL_XCFRAMEWORK_PATH=$(find "$BASE_DIR" -type d -name "${PRODUCT_NAME}.xcframework" | head -n 1)
if [ -d "$FINAL_XCFRAMEWORK_PATH" ]; then
  echo "📦 Copying ${PRODUCT_NAME}.xcframework to destination: $DEST_DIR"
  mkdir -p "$DEST_DIR"
  rm -rf "$DEST_DIR/${PRODUCT_NAME}.xcframework"
  cp -R "$FINAL_XCFRAMEWORK_PATH" "$DEST_DIR/"
  echo "✅ Copied to: $DEST_DIR/${PRODUCT_NAME}.xcframework"
  # Sanitize embedded build paths in .abi.json and .swiftinterface so audit passes (no pubnative/hybid in paths)
  if [ -f "$SCRIPT_DIR/sanitize_xcframework_paths.sh" ]; then
    bash "$SCRIPT_DIR/sanitize_xcframework_paths.sh" "$DEST_DIR/${PRODUCT_NAME}.xcframework" && echo "✅ Sanitized embedded paths in xcframework." || true
  fi
else
  echo "❌ ${PRODUCT_NAME}.xcframework not found after generation — packaging will fail."
  exit 1
fi

echo "🎉 Framework generation complete."
