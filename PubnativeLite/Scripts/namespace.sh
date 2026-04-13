#!/bin/bash
set -e

# Namespace can be passed as first argument, defaults to NGSDK
NAMESPACE="${1:-NGSDK}"
echo "🔧 Using NAMESPACE: ${NAMESPACE}"

# Base directory - only process SDK source code (PubnativeLite/PubnativeLite folder)
BASE_DIR="$(cd "$(dirname "$0")/../PubnativeLite" && pwd)"
GENERATE_SCRIPT="$(dirname "$0")/generate.sh"

BASE_API_URL="https://api.nextgen.verve.net"
BASE_API_PRIVACY_URL="https://server.nextgen.verve.net"
BASE_API_DSP_URL="https://dsp.nextgen.verve.net"

echo "📂 Processing files in: $BASE_DIR"

# Step 1: Rename files (SDK only — exclude Demo and Tests apps)
echo "🔄 Renaming files (SDK only)..."
find "$BASE_DIR" -depth -type f \( -name "HyBid*" -o -name "PNLite*" -o -name "*+HyBid*" -o -name "*+PNLite*" \) \
    ! -path "*/Pods/*" ! -path "*/OMSDK*" ! -path "*/PubnativeLiteDemo/*" ! -path "*/PubnativeLiteTests/*" \
    ! -name "*.xcframework" ! -name "*.framework" ! -name "*.xcprivacy" | while read -r file; do
    dir=$(dirname "$file")
    name=$(basename "$file")
    
    # Replace HyBid and PNLite in filename
    newname=$(echo "$name" | sed -E "s/HyBid/${NAMESPACE}/g" | sed -E "s/PNLite/${NAMESPACE}/g")
    
    if [ "$name" != "$newname" ]; then
        mv "$file" "$dir/$newname"
        echo "✅ Renamed: $name → $newname"
    fi
done

# Step 1b: Rename hybid*.js → ngsdk*.js (SDK only)
find "$BASE_DIR" -depth -type f -name "hybid*.js" ! -path "*/Pods/*" ! -path "*/OMSDK*" ! -path "*/PubnativeLiteDemo/*" ! -path "*/PubnativeLiteTests/*" | while read -r file; do
    dir=$(dirname "$file")
    name=$(basename "$file")
    newname=$(echo "$name" | sed -E "s/hybid/ngsdk/g")
    if [ "$name" != "$newname" ]; then
        mv "$file" "$dir/$newname"
        echo "✅ Renamed: $name → $newname"
    fi
done

# Step 2: Update file contents (SDK source only: .h, .m, .mm, .swift — exclude Demo and Tests)
# Order matters: replace macros/symbols/selectors first, then class names, then bundle IDs
echo "📝 Updating file contents (SDK source only)..."
find "$BASE_DIR" -type f \( -name "*.h" -o -name "*.m" -o -name "*.mm" -o -name "*.swift" \) \
    ! -path "*/Pods/*" ! -path "*/OMSDK*" ! -path "*/PubnativeLiteDemo/*" ! -path "*/PubnativeLiteTests/*" | while read -r file; do
    
    # Remove obsolete license URL line (repo does not exist; remove completely)
    sed -i '' '/github\.com\/.*hybid-ios-sdk\/blob\/main\/LICENSE/d' "$file"
    
    # Macros and C symbols (before HyBid so we don't double-touch)
    sed -i '' -E "s/HYBID_/${NAMESPACE}_/g" "$file"
    sed -i '' -E "s/hybid_/ngsdk_/g" "$file"
    # ObjC selectors / camelCase (e.g. hyBidNoFill → ngsdkNoFill)
    sed -i '' -E "s/hyBid/ngsdk/g" "$file"
    # Class/product names
    sed -i '' -E "s/HyBid/${NAMESPACE}/g" "$file"
    sed -i '' -E "s/PNLite/${NAMESPACE}/g" "$file"
    sed -i '' -E "s/PubnativeLite/${NAMESPACE}/g" "$file"
    # Copyright and remaining pubnative references (after PubnativeLite so we don't double-replace)
    sed -i '' -E 's/PubNative/NextGen/g' "$file"
    sed -i '' -E 's/pubnative/ngsdk/g' "$file"
    # Bundle ID for SDK only (dSYM plist, error domain) — do not change Tests/Demo bundle IDs
    sed -i '' -E "s/net\.pubnative\.PubnativeLite/net.nextgen.${NAMESPACE}/g" "$file"

    # Replace API URLs
    sed -i '' -E "s@https://api\.pubnative\.net@${BASE_API_URL}@g" "$file"
    sed -i '' -E "s@https://server\.pubnative\.net@${BASE_API_PRIVACY_URL}@g" "$file"
    sed -i '' -E "s@https://dsp\.pubnative\.net@${BASE_API_DSP_URL}@g" "$file"

    # JS file base names (files are renamed hybid*.js → ngsdk*.js in Step 1b; code must reference new names)
    sed -i '' -E 's/hybidmraidscaling/ngsdkmraidscaling/g' "$file"
    sed -i '' -E 's/hybidscaling/ngsdkscaling/g' "$file"
    # MRAID/scaling: element id and selectors (hybid-ad → ngsdk-ad) used in .js and in ObjC HTML strings
    sed -i '' -E 's/hybid-ad/ngsdk-ad/g' "$file"
    # OMSDK partner identifier string (so built binary does not expose "Pubnativenet")
    sed -i '' -E 's/"Pubnativenet"/"NGSDK"/g' "$file"
    # DispatchQueue label and UserDefaults key value (remove hybid references)
    sed -i '' -E 's/hybid\.network\.monitor/ngsdk.network.monitor/g' "$file"
    sed -i '' -E 's/com\.pubnative\.hybid-ios-sdk/net.nextgen.ngsdk/g' "$file"
    # Remove wiki setup sentence from log messages (Setup-HyBid or Setup-NGSDK)
    sed -i '' -E 's/ Check out https:\/\/github\.com\/pubnative\/pubnative-hybid-ios-sdk\/wiki\/Setup-[^"]* for the setup process\.//g' "$file"
done

# Step 2a: Same replacements in SDK .js, .plist, .xib, .storyboard only
echo "📝 Updating file contents (SDK .js, .plist, .xib, .storyboard)..."
find "$BASE_DIR" -type f \( -name "*.js" -o -name "*.plist" -o -name "*.xib" -o -name "*.storyboard" \) \
    ! -path "*/Pods/*" ! -path "*/OMSDK*" ! -path "*/PubnativeLiteDemo/*" ! -path "*/PubnativeLiteTests/*" | while read -r file; do
    sed -i '' -E "s/HYBID_/${NAMESPACE}_/g" "$file"
    sed -i '' -E "s/hybid_/ngsdk_/g" "$file"
    sed -i '' -E "s/hyBid/ngsdk/g" "$file"
    sed -i '' -E "s/HyBid/${NAMESPACE}/g" "$file"
    sed -i '' -E "s/PNLite/${NAMESPACE}/g" "$file"
    sed -i '' -E "s/PubnativeLite/${NAMESPACE}/g" "$file"
    sed -i '' -E "s/net\.pubnative\.PubnativeLite/net.nextgen.${NAMESPACE}/g" "$file"
    # Copyright and remaining pubnative (e.g. in .js strings/comments)
    sed -i '' -E 's/PubNative/NextGen/g' "$file"
    sed -i '' -E 's/pubnative/ngsdk/g' "$file"
    # MRAID/scaling script content: element id (hybid-ad → ngsdk-ad)
    sed -i '' -E 's/hybid-ad/ngsdk-ad/g' "$file"
done

# Step 2b: Viewability — keep only OMSDK Smaato (remove OMSDK Pubnative so it can be dropped from framework)
echo "📐 Keeping only integration type Smaato in viewability..."
if ruby "$(dirname "$0")/namespace_omsdk_smaato_only.rb" "${BASE_DIR}"; then
    echo "✅ OMSDK Smaato-only applied."
else
    echo "⚠️ namespace_omsdk_smaato_only.rb failed (non-fatal)."
fi

# Step 3: Update Xcode project
echo "🔄 Updating Xcode project..."
ruby "$(dirname "$0")/namespace_xcodeproj.rb" "${NAMESPACE}"

echo "✅ Namespace replacement completed!"

# Step 4: Run generate script if it exists
if [ -f "$GENERATE_SCRIPT" ]; then
    echo "🚀 Running generate.sh..."
    bash "$GENERATE_SCRIPT" "${NAMESPACE}"
else
    echo "⚠️ Warning: generate.sh not found. Skipping..."
fi
