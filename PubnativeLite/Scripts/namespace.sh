#!/bin/bash

set -e

# Namespace Variable
NAMESPACE="Smaato"
PROJECT_FILE="../HyBid.xcodeproj/project.pbxproj"
GENERATE_SCRIPT="PubnativeLite/Scripts/generate.sh"

# API URL Variables
if [ "$NAMESPACE" = "Smaato" ]; then
    BASE_API_URL="https://api.nextgen.verve.net"
    BASE_API_PRIVACY_URL="https://server.nextgen.verve.net"
else
    BASE_API_URL="https://api.pubnative.net"
    BASE_API_PRIVACY_URL="https://server.pubnative.net"
fi

echo "🔧 Using BASE_API_URL: $BASE_API_URL"
echo "🔧 Using BASE_API_PRIVACY_URL: $BASE_API_PRIVACY_URL"


# Base directory
BASE_DIR=$(dirname "$0")/../PubnativeLite

echo "🔍 Checking if PubnativeLite directory exists..."
if [ ! -d "$BASE_DIR" ]; then
    echo "❌ Error: PubnativeLite directory not found!"
    exit 1
fi

echo "🔄 Renaming all files except Info.plist, .js, .xcframework, .xcprivacy, OMSDK, Pods, Swift files, and system libraries..."
find "$BASE_DIR" -type f ! -path "*/Pods/*" ! -path "*/OMSDK*" ! -name "Info.plist" \
    ! -name "*.js" ! -name "*.xcframework" !  -name "*.framework" ! -name "*.xcprivacy" ! -name "*.swift" ! -name "*.tbd" | while read -r FILE; do
    FILE_NAME=$(basename "$FILE")
    DIR_PATH=$(dirname "$FILE")

    # Ensure it does not rename system libraries
    if [[ "$FILE_NAME" != ${NAMESPACE}_* ]]; then
        NEW_FILE_NAME="${NAMESPACE}_${FILE_NAME}"
        NEW_FILE_PATH="$DIR_PATH/$NEW_FILE_NAME"

        mv "$FILE" "$NEW_FILE_PATH"
        echo "✅ Renamed: $FILE → $NEW_FILE_PATH"
    fi
done

echo "📝 Updating file contents (Class Names, Imports, etc.), excluding system frameworks..."
find "$BASE_DIR" -type f \( -name "*.h" -o -name "*.m" -o -name "*.mm" -o -name "*.swiftinterface" -o -name "*.swift" -o -name "*.xcprivacy" \) ! -path "*/Pods/*" ! -path "*/OMSDK*" ! -name "Info.plist" ! -name "*.js" ! -name "*.tbd" !  -name "*.xcframework" !  -name "*.framework" -print0 |
while IFS= read -r -d '' file; do
    echo "✏️ Processing: $file"

    # Handle Objective-C / interface files
    if [[ "$file" != *.swift && "$file" != *.xcprivacy ]]; then
        SYSTEM_FRAMEWORKS="(Foundation|UIKit|SwiftUI|AVFoundation|AppTrackingTransparency|CoreTelephony|SystemConfiguration|AdSupport|CoreData|UIDevice|UIScreen|UIApplication|UITraitCollectionCombine|CoreGraphics|CoreLocation|CryptoKit|Dispatch|MapKit|Metal|OSLog|SceneKit|SpriteKit|Vision|WebKit|Network|CoreBluetooth|CoreMotion|UserNotifications)"

        # Prefix only project-specific imports, skipping system frameworks
        sed -i '' -E "s/^import ([A-Za-z_][A-Za-z0-9_]*)$/import ${NAMESPACE}_\1/g" "$file"
        sed -i '' -E "s/^import ${NAMESPACE}_(${SYSTEM_FRAMEWORKS})$/import \1/g" "$file"

        # Prefix local project headers but not system headers
        sed -i '' -E "s/#import \"([A-Za-z_][A-Za-z0-9_]*\.h)\"/#import \"${NAMESPACE}_\1\"/g" "$file"

        # Replace BuildConfig references
        sed -i '' -E "s/HyBidBuildConfig/${NAMESPACE}_BuildConfig/g" "$file"

        # Fix bridging headers and category imports
        sed -i '' -E "s|#import <HyBid/HyBid-Swift.h>|#import <Smaato_HyBid/Smaato_HyBid-Swift.h>|g" "$file"
        sed -i '' -E "s|#import \"HyBid-Swift.h\"|#import \"Smaato_HyBid-Swift.h\"|g" "$file"
        sed -i '' -E "s|#if __has_include\(<HyBid/HyBid-Swift.h>\)|#if __has_include(<Smaato_HyBid/Smaato_HyBid.h>)|g" "$file"
        sed -i '' -E "s|#if __has_include\(\"(HyBid[A-Za-z0-9_]+\.h)\"\)|#if __has_include(\"Smaato_\1\")|g" "$file"
        sed -i '' -E "s|#import \"([A-Za-z0-9_]+)\+([A-Za-z0-9_]+)\.h\"|#import \"${NAMESPACE}_\1+\2.h\"|g" "$file"
    fi

    # Handle .xcprivacy files - only process URL replacements
    if [[ "$file" == *.xcprivacy ]]; then
        echo "🔒 Processing privacy file: $file"
        # Replace privacy tracking domains
        sed -i '' -E "s@server\.pubnative\.net@${BASE_API_PRIVACY_URL#https://}@g" "$file"
    fi

    # ✅ Fallback: namespace hardcoded image/nib/view references in ALL file types
    if [[ "$file" != *.xcprivacy ]]; then
        for name in \
        VerveContentInfo \
        PNLiteExternalLink \
        PNLiteExternalLink1 \
        PNLiteFullScreen \
        PNLitePlay \
        PNLiteSkip \
        sound-off \
        sound-on \
        close \
        skip \
        PNLiteVASTPlayerViewController \
        PNLiteVASTPlayerFullScreenViewController \
        PNLiteVASTPlayerInterstitialViewController \
        PNLiteVASTPlayerRewardedViewController \
        HyBidMRAIDCloseCardView \
        HyBidCustomCTAView \
        InternalWebBrowser
        do
        sed -i '' -E "s@\"${name}\"@\"${NAMESPACE}_${name}\"@g" "$file"
        done
    fi

    # Replace API URLs
    sed -i '' -E "s@https://api\.pubnative\.net@${BASE_API_URL}@g" "$file"
    sed -i '' -E "s@https://server\.pubnative\.net@${BASE_API_PRIVACY_URL}@g" "$file"

done


echo "🔄 Running Xcode project update..."
ruby PubnativeLite/Scripts/namespace_xcodeproj.rb

echo "✅ Namespace replacement completed!"

if [ -f "$GENERATE_SCRIPT" ]; then
    echo "🚀 Running generate.sh..."
    bash "$GENERATE_SCRIPT" "${NAMESPACE}_HyBid"
    echo "✅ generate.sh completed!"
else
    echo "⚠️ Warning: generate.sh not found. Skipping..."
fi
