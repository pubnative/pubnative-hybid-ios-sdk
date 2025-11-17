#!/bin/bash
set -e

# ========================================
# 🏗 Generate HyBid.xcframework for Distribution
# ========================================
# Builds iOS and Simulator frameworks, merges them into an .xcframework,
# strips redundant Swift interface references, and prepares it for packaging.
#
# 📦 Output:
#   - HyBid.xcframework  (copied to the repo root for packaging)
#   - HyBid.xcframework.zip (in /private/tmp/circleci-artifacts)
#
# 💻 Usage:
#   ./PubnativeLite/Scripts/generate.sh
#
# 🧩 Notes:
#   - Must run before package-private-framework.sh.
#   - Uses the same working directory locally and on CircleCI.
# ========================================

# Accept PRODUCT_NAME as an argument
PRODUCT_NAME=${1:-HyBid} # Default to "HyBid" if no argument is provided

export LIBXML2_CFLAGS=$(xml2-config --cflags)
export LIBXML2_LIBS=$(xml2-config --libs)

# Variable Declarations
BASE_DIR=/private/tmp/circleci-artifacts
FRAMEWORK_NAME=$PRODUCT_NAME.framework
FRAMEWORK_DSYM_NAME=$FRAMEWORK_NAME.dSYM
XCFRAMEWORK_NAME=$PRODUCT_NAME.xcframework
XCFRAMEWORK=$BASE_DIR/$XCFRAMEWORK_NAME
XCFRAMEWORK_ZIP_PATH=$BASE_DIR/$PRODUCT_NAME.xcframework.zip
IPHONEOS_PATH=$BASE_DIR/iphoneos
IPHONEOS_FRAMEWORK=$IPHONEOS_PATH/$FRAMEWORK_NAME
IPHONESIMULATOR_PATH=$BASE_DIR/iphonesimulator
IPHONESIMULATOR_FRAMEWORK=$IPHONESIMULATOR_PATH/$FRAMEWORK_NAME
IPHONEOS_DSYM=$IPHONEOS_PATH/$FRAMEWORK_DSYM_NAME
IPHONESIMULATOR_DSYM=$IPHONESIMULATOR_PATH/$FRAMEWORK_DSYM_NAME
IPHONE_BCSYMBOLMAP_PATHS=$IPHONEOS_PATH/*

# 🧭 Resolve absolute paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SDK_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
DEST_DIR="$SDK_ROOT"
echo "📍 Script directory: $SCRIPT_DIR"
echo "📦 SDK root directory: $SDK_ROOT"
echo "📤 Framework destination (expanded): $DEST_DIR"

# Generate Frameworks
echo "⚙️ Building iPhoneOS framework..."
# Ensure clean output before building new XCFramework
rm -rf "$XCFRAMEWORK"

xcodebuild -workspace HyBid.xcworkspace \
  -scheme HyBid \
  -sdk iphoneos \
  -configuration Release \
  clean build \
  CODE_SIGN_IDENTITY="" \
  CODE_SIGNING_REQUIRED=NO \
  CONFIGURATION_BUILD_DIR=$IPHONEOS_PATH \
  GCC_OPTIMIZATION_LEVEL=0 \
  SWIFT_OPTIMIZATION_LEVEL=-Onone \
  ENABLE_STRICT_OBJC_MSGSEND=NO \
  CLANG_ENABLE_OBJC_ARC=YES \
  OTHER_LDFLAGS="-ObjC -all_load -weak_framework Foundation -weak_framework UIKit" \
  OTHER_CFLAGS="-fobjc-arc" \
  VALIDATE_PRODUCT=NO \
  -UseModernBuildSystem=YES | xcpretty -c

echo "⚙️ Building iPhoneSimulator framework..."
xcodebuild -workspace HyBid.xcworkspace \
  -scheme HyBid \
  -sdk iphonesimulator \
  -configuration Release \
  clean build \
  CONFIGURATION_BUILD_DIR=$IPHONESIMULATOR_PATH \
  GCC_OPTIMIZATION_LEVEL=0 \
  SWIFT_OPTIMIZATION_LEVEL=-Onone \
  ENABLE_STRICT_OBJC_MSGSEND=NO \
  CLANG_ENABLE_OBJC_ARC=YES \
  OTHER_LDFLAGS="-ObjC -all_load -weak_framework Foundation -weak_framework UIKit" \
  OTHER_CFLAGS="-fobjc-arc" \
  VALIDATE_PRODUCT=NO \
  -UseModernBuildSystem=YES | xcpretty -c

# Collect .bcsymbolmap files
echo "🔍 Collecting .bcsymbolmap files..."
IPHONE_BCSYMBOLMAP_COMMANDS=""
for path in $IPHONE_BCSYMBOLMAP_PATHS; do
    if [[ ${path} =~ ".bcsymbolmap" ]]; then
        IPHONE_BCSYMBOLMAP_COMMANDS="$IPHONE_BCSYMBOLMAP_COMMANDS -debug-symbols $path "
    fi
done

# Generate XCFramework
echo "🏗 Creating XCFramework..."
xcodebuild -create-xcframework \
  -framework $IPHONEOS_FRAMEWORK -debug-symbols $IPHONEOS_DSYM $IPHONE_BCSYMBOLMAP_COMMANDS \
  -framework $IPHONESIMULATOR_FRAMEWORK -debug-symbols $IPHONESIMULATOR_DSYM \
  -output $XCFRAMEWORK

# Clean Swift interfaces
echo "🧹 Cleaning Swift interface imports..."
cd $BASE_DIR
find . -name "*.swiftinterface" -exec sed -i -e "s/${PRODUCT_NAME}\.//g" {} \;

# Debug: check result
echo "🔍 Searching for HyBid.xcframework after build..."
find "$BASE_DIR" -type d -name "HyBid.xcframework" || echo "❌ HyBid.xcframework not found after generation"

# 🧱 Copy to SDK root (for packaging step)
FINAL_XCFRAMEWORK_PATH=$(find "$BASE_DIR" -type d -name "HyBid.xcframework" | head -n 1)
if [ -d "$FINAL_XCFRAMEWORK_PATH" ]; then
  echo "📦 Copying HyBid.xcframework to destination: $DEST_DIR"
  mkdir -p "$DEST_DIR"
  cp -R "$FINAL_XCFRAMEWORK_PATH" "$DEST_DIR/"
  echo "✅ Copied to: $DEST_DIR/HyBid.xcframework"
else
  echo "❌ HyBid.xcframework not found after generation — packaging will fail."
  exit 1
fi

echo "🎉 Framework generation complete."
