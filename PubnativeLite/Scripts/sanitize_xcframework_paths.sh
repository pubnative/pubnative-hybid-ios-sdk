#!/bin/bash
# Sanitize embedded build paths in xcframework so audit does not flag HyBid/Pubnative.
# Swift compiler embeds source paths in .abi.json and .swiftinterface; replace
# rebranding-sensitive segments so the distributed xcframework passes the conformity audit.
#
# Usage: ./sanitize_xcframework_paths.sh [path-to-.xcframework]
# Default: ../NGSDK.xcframework relative to script dir.

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
XCFRAMEWORK="${1:-$SCRIPT_DIR/../NGSDK.xcframework}"

if [ ! -d "$XCFRAMEWORK" ]; then
  echo "sanitize_xcframework_paths: path not found or not a directory: $XCFRAMEWORK"
  exit 1
fi

echo "🧹 Sanitizing embedded paths in: $XCFRAMEWORK"

# Replace in .abi.json and .swiftinterface only (order: more specific first).
# Use temp file so sed is portable on both macOS and Linux (CI).
replace_in_file() {
  local f="$1"
  local tmp
  tmp=$(mktemp)
  sed -e 's/pubnative-hybid-ios-sdk-private/ngsdk-ios-sdk/g' \
      -e 's/PubnativeLite/NGSDK/g' \
      -e 's/Pubnativenet/NGSDK/g' \
      -e 's/pubnative/ngsdk/g' \
      -e 's/hybid/ngsdk/g' \
      "$f" > "$tmp" && mv "$tmp" "$f"
}

count=0
while IFS= read -r -d '' f; do
  replace_in_file "$f"
  count=$((count + 1))
done < <(find "$XCFRAMEWORK" -type f \( -name "*.abi.json" -o -name "*.swiftinterface" \) -print0 2>/dev/null)

echo "✅ Sanitized $count file(s) (.abi.json, .swiftinterface)."
