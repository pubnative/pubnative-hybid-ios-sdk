#!/bin/bash
set -euo pipefail

# ========================================
# 📦 Package HyBid binaries for Swift Package Manager
# ========================================
# SPM's .binaryTarget expects ONE .xcframework at the root of each zip.
# The private-pod packaging (package-private-framework.sh) bundles LICENSE,
# HyBid.xcframework and OMSDK_Pubnativenet/ into a single zip, which SPM
# cannot consume. This script produces one zip per xcframework, computes the
# SPM checksums, and (optionally) rewrites the managed lines in Package.swift.
#
# Run after generate.sh. Compatible with macOS /bin/bash 3.2.
#
# 💻 Usage:
#   ./package-spm-binaries.sh --version 3.9.3 \
#       [--hybid   <path/HyBid.xcframework>]            (default: <SDK_ROOT>/HyBid.xcframework)
#       [--omsdk   <path/OMSDK_*.xcframework>]           (default: OMSDK_Pubnativenet, or OMSDK_Smaato for
#                                                         a Smaato_* --hybid, found under <SDK_ROOT>/PubnativeLite)
#       [--out     <dir>]                                (default: <SDK_ROOT>/spm-artifacts)
#       [--manifest <path/Package.swift>]                (rewrite version + checksums in place)
#       [--local]                                        (also copy zips to <manifest dir>/Artifacts for
#                                                         HYBID_SPM_LOCAL_ARTIFACTS=1 verification)
#
#   Code signing (Xcode 15+ verifies xcframework signatures and warns on unsigned ones):
#       [--sign-identity <name|SHA-1>]   sign the HyBid xcframework (env: HYBID_CODESIGN_IDENTITY).
#                                        Use "Apple Distribution: …" or "Developer ID Application: …".
#       [--keychain <path>]              keychain holding the identity (CI)  (env: HYBID_CODESIGN_KEYCHAIN)
#       [--sign-omsdk]                   also sign the OMSDK xcframework (off by default: it is a
#                                        third-party binary; re-signing replaces the vendor's identity)
#       [--no-timestamp]                 skip the secure timestamp (offline/local tests only)
#       [--require-signature]            fail instead of warning when no identity is given (release CI)
#
#   Smaato flavour: --hybid .../Smaato_HyBid.xcframework  (OMSDK_Smaato is picked automatically).
#   Run once per flavour with the same --version; each run updates only its own checksums.
#
# 📤 Output (in --out):
#   <HyBidName>.xcframework.zip, <OMSDKName>.xcframework.zip, checksums.txt
#   (signing happens on the staged copies BEFORE zipping, so checksums cover the signature)
# ========================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SDK_ROOT="${SDK_ROOT:-$(cd "$SCRIPT_DIR/../.." && pwd)}"

VERSION=""
HYBID_XCF=""
OMSDK_XCF=""
OUT_DIR=""
MANIFEST=""
LOCAL_COPY=0
SIGN_IDENTITY="${HYBID_CODESIGN_IDENTITY:-}"
SIGN_KEYCHAIN="${HYBID_CODESIGN_KEYCHAIN:-}"
SIGN_OMSDK=0
SIGN_TIMESTAMP=1
REQUIRE_SIGNATURE=0

die() { echo "❌ $*" >&2; exit 1; }

while [ $# -gt 0 ]; do
  case "$1" in
    --version)  VERSION="${2:-}"; shift 2 ;;
    --hybid)    HYBID_XCF="${2:-}"; shift 2 ;;
    --omsdk)    OMSDK_XCF="${2:-}"; shift 2 ;;
    --out)      OUT_DIR="${2:-}"; shift 2 ;;
    --manifest) MANIFEST="${2:-}"; shift 2 ;;
    --local)    LOCAL_COPY=1; shift ;;
    --sign-identity)     SIGN_IDENTITY="${2:-}"; shift 2 ;;
    --keychain)          SIGN_KEYCHAIN="${2:-}"; shift 2 ;;
    --sign-omsdk)        SIGN_OMSDK=1; shift ;;
    --no-timestamp)      SIGN_TIMESTAMP=0; shift ;;
    --require-signature) REQUIRE_SIGNATURE=1; shift ;;
    -h|--help)  sed -n '4,40p' "$0"; exit 0 ;;
    *) die "Unknown argument: $1" ;;
  esac
done

[ -n "$VERSION" ] || die "--version is required (e.g. 3.9.3)"
echo "$VERSION" | grep -Eq '^[0-9]+\.[0-9]+\.[0-9]+(-[A-Za-z0-9.]+)?$' || die "Invalid version: $VERSION"

HYBID_XCF="${HYBID_XCF:-$SDK_ROOT/HyBid.xcframework}"
if [ -z "$OMSDK_XCF" ]; then
  # Default OMSDK follows the HyBid flavour (Smaato_HyBid ships with OMSDK_Smaato).
  case "$(basename "$HYBID_XCF")" in
    Smaato_*) OMSDK_DEFAULT_NAME=OMSDK_Smaato.xcframework ;;
    *)        OMSDK_DEFAULT_NAME=OMSDK_Pubnativenet.xcframework ;;
  esac
  OMSDK_XCF="$(find "$SDK_ROOT/PubnativeLite" -type d -name "$OMSDK_DEFAULT_NAME" -prune | head -n 1 || true)"
  [ -n "$OMSDK_XCF" ] || die "Could not find $OMSDK_DEFAULT_NAME under $SDK_ROOT/PubnativeLite; pass --omsdk"
fi
OUT_DIR="${OUT_DIR:-$SDK_ROOT/spm-artifacts}"

# -------------------------------
# 🔏 Validate signing options
# -------------------------------
if [ -z "$SIGN_IDENTITY" ]; then
  [ "$REQUIRE_SIGNATURE" = "0" ] || die "--require-signature set but no --sign-identity / HYBID_CODESIGN_IDENTITY given"
  [ "$SIGN_OMSDK" = "0" ] || die "--sign-omsdk needs --sign-identity"
else
  command -v codesign >/dev/null || die "codesign not found"
  if [ -n "$SIGN_KEYCHAIN" ]; then
    [ -f "$SIGN_KEYCHAIN" ] || die "Keychain not found: $SIGN_KEYCHAIN"
  fi
  if [ "$SIGN_IDENTITY" = "-" ]; then
    echo "⚠️  Ad-hoc signing ('-'): fine for tests, but Xcode will not show a trusted publisher." >&2
  else
    # Fail early (before any work) if the identity is not usable for code signing.
    if [ -n "$SIGN_KEYCHAIN" ]; then
      IDENTITIES="$(security find-identity -v -p codesigning "$SIGN_KEYCHAIN" 2>/dev/null || true)"
    else
      IDENTITIES="$(security find-identity -v -p codesigning 2>/dev/null || true)"
    fi
    MATCHES="$(echo "$IDENTITIES" | grep -F -- "$SIGN_IDENTITY" | grep -v 'CSSMERR_' || true)"
    [ -n "$MATCHES" ] || die "No valid code-signing identity matching '$SIGN_IDENTITY'"
    [ "$(echo "$MATCHES" | wc -l | tr -d ' ')" = "1" ] \
      || die "'$SIGN_IDENTITY' matches several identities; pass the SHA-1 hash instead"
    case "$MATCHES" in
      *Development*) echo "⚠️  $(echo "$MATCHES" | sed -E 's/.*"(.*)".*/\1/') is a development certificate; release builds should use Apple Distribution or Developer ID Application." >&2 ;;
    esac
    # Sign by SHA-1: codesign also considers revoked/expired certs with the same name and
    # would otherwise fail with "ambiguous".
    SIGN_IDENTITY="$(echo "$MATCHES" | awk '{print $2}')"
  fi
fi

# -------------------------------
# 🔎 Validate inputs
# -------------------------------
validate_xcframework() {
  local xcf="$1"
  [ -d "$xcf" ] || die "xcframework not found: $xcf"
  case "$xcf" in *.xcframework) ;; *) die "Not an .xcframework: $xcf" ;; esac
  [ -f "$xcf/Info.plist" ] || die "Missing Info.plist in $xcf"
  local ids
  ids="$(plutil -extract AvailableLibraries json -o - "$xcf/Info.plist" 2>/dev/null || true)"
  echo "$ids" | grep -q '"ios-arm64"' || die "$xcf has no ios-arm64 (device) slice"
  echo "$ids" | grep -q 'ios-arm64[^"]*-simulator' || die "$xcf has no iOS simulator slice"
  if ! find "$xcf" -name 'PrivacyInfo.xcprivacy' | grep -q .; then
    echo "⚠️  $(basename "$xcf") contains no PrivacyInfo.xcprivacy" >&2
  fi
}

validate_xcframework "$HYBID_XCF"
validate_xcframework "$OMSDK_XCF"

HYBID_NAME="$(basename "$HYBID_XCF" .xcframework)"
OMSDK_NAME="$(basename "$OMSDK_XCF" .xcframework)"

echo "📦 Version:   $VERSION"
echo "📦 HyBid:     $HYBID_XCF"
echo "📦 OMSDK:     $OMSDK_XCF"
echo "📤 Output:    $OUT_DIR"

# -------------------------------
# 🧹 Stage copies (never modify the inputs)
# -------------------------------
STAGE_DIR="$(mktemp -d "${TMPDIR:-/tmp}/hybid-spm.XXXXXX")"
trap 'rm -rf "$STAGE_DIR"' EXIT

ditto "$HYBID_XCF" "$STAGE_DIR/$HYBID_NAME.xcframework"
ditto "$OMSDK_XCF" "$STAGE_DIR/$OMSDK_NAME.xcframework"

# Same rule as package-private-framework.sh: App Store validation rejects
# pre-release suffixes in CFBundleShortVersionString (e.g. 3.9.3-beta1 → 3.9.3).
find "$STAGE_DIR/$HYBID_NAME.xcframework" -path '*.framework/Info.plist' | while read -r plist; do
  current="$(/usr/libexec/PlistBuddy -c 'Print CFBundleShortVersionString' "$plist" 2>/dev/null || true)"
  case "$current" in
    *-*) plutil -replace CFBundleShortVersionString -string "${current%%-*}" "$plist"
         echo "🔧 $plist: $current → ${current%%-*}" ;;
  esac
done

# Drop Finder/AppleDouble metadata so checksums are reproducible.
# (Must happen before signing: removing files afterwards would break the seal.)
find "$STAGE_DIR" \( -name '.DS_Store' -o -name '._*' \) -delete

# -------------------------------
# 🔏 Code signing (staged copies, before zipping)
# -------------------------------
is_signed() { codesign -d "$1" >/dev/null 2>&1; }

sign_xcframework() {
  local xcf="$1"
  set -- --force --sign "$SIGN_IDENTITY"
  [ "$SIGN_TIMESTAMP" = "1" ] && set -- "$@" --timestamp
  [ -n "$SIGN_KEYCHAIN" ] && set -- "$@" --keychain "$SIGN_KEYCHAIN"
  codesign "$@" "$xcf" || die "codesign failed for $(basename "$xcf")"
  codesign --verify --strict --verbose=2 "$xcf" >/dev/null 2>&1 \
    || die "Signature verification failed for $(basename "$xcf")"
  local info signer team stamp
  info="$(codesign -dvv "$xcf" 2>&1)"
  signer="$(echo "$info" | sed -nE 's/^Authority=(.*)/\1/p' | head -n 1)"
  team="$(echo "$info" | sed -nE 's/^TeamIdentifier=(.*)/\1/p')"
  stamp="$(echo "$info" | sed -nE 's/^Timestamp=(.*)/\1/p')"
  echo "🔏 Signed $(basename "$xcf"): ${signer:-ad-hoc}, team ${team:-none}, timestamp ${stamp:-none}" >&2
}

check_existing_signature() {
  # A signature carried over from the input must still be valid on the staged copy
  # (the CFBundleShortVersionString fix-up above invalidates it).
  local xcf="$1"
  if is_signed "$xcf" && ! codesign --verify --strict "$xcf" >/dev/null 2>&1; then
    die "$(basename "$xcf") was signed, but the staged copy no longer verifies (modified during packaging). Re-sign with --sign-identity."
  fi
}

if [ -n "$SIGN_IDENTITY" ]; then
  sign_xcframework "$STAGE_DIR/$HYBID_NAME.xcframework"
  if [ "$SIGN_OMSDK" = "1" ]; then
    sign_xcframework "$STAGE_DIR/$OMSDK_NAME.xcframework"
  else
    check_existing_signature "$STAGE_DIR/$OMSDK_NAME.xcframework"
    is_signed "$STAGE_DIR/$OMSDK_NAME.xcframework" \
      || echo "⚠️  $OMSDK_NAME.xcframework is unsigned (vendor binary left as-is; use --sign-omsdk to sign it)." >&2
  fi
else
  for xcf in "$STAGE_DIR/$HYBID_NAME.xcframework" "$STAGE_DIR/$OMSDK_NAME.xcframework"; do
    check_existing_signature "$xcf"
    is_signed "$xcf" || echo "⚠️  $(basename "$xcf") is unsigned; Xcode will warn integrators. Pass --sign-identity." >&2
  done
fi

# -------------------------------
# 🗜 Zip (one xcframework at the root of each archive)
# -------------------------------
mkdir -p "$OUT_DIR"
CHECKSUMS="$OUT_DIR/checksums.txt"
# Keep entries for the other flavour when both are packaged into the same --out dir.
touch "$CHECKSUMS"
grep -vE "^($HYBID_NAME|$OMSDK_NAME) " "$CHECKSUMS" > "$CHECKSUMS.tmp" || true
mv "$CHECKSUMS.tmp" "$CHECKSUMS"

zip_and_hash() {
  local name="$1" zip="$OUT_DIR/$1.xcframework.zip" sum
  rm -f "$zip"
  # -y keeps symlinks (framework bundles may contain them), -X drops extra attrs.
  (cd "$STAGE_DIR" && zip -qryX "$zip" "$name.xcframework")
  # SPM's checksum is the SHA-256 of the archive (== `swift package compute-checksum`).
  sum="$(shasum -a 256 "$zip" | awk '{print $1}')"
  echo "$name $sum" >> "$CHECKSUMS"
  echo "✅ $(basename "$zip")  $(du -h "$zip" | awk '{print $1}')  sha256=$sum" >&2
  echo "$sum"
}

HYBID_SUM="$(zip_and_hash "$HYBID_NAME")"
OMSDK_SUM="$(zip_and_hash "$OMSDK_NAME")"

# -------------------------------
# ✍️ Update Package.swift (optional)
# -------------------------------
if [ -n "$MANIFEST" ]; then
  [ -f "$MANIFEST" ] || die "Manifest not found: $MANIFEST"
  # Map the flavour to its managed checksum lines in Package.swift.
  if [ "$HYBID_NAME" = "HyBid" ] && [ "$OMSDK_NAME" = "OMSDK_Pubnativenet" ]; then
    HYBID_KEY=hybidChecksum;       OMSDK_KEY=omsdkChecksum
    OTHER_KEYS="smaatoHybidChecksum omsdkSmaatoChecksum"
  elif [ "$HYBID_NAME" = "Smaato_HyBid" ] && [ "$OMSDK_NAME" = "OMSDK_Smaato" ]; then
    HYBID_KEY=smaatoHybidChecksum; OMSDK_KEY=omsdkSmaatoChecksum
    OTHER_KEYS="hybidChecksum omsdkChecksum"
  else
    die "--manifest supports HyBid + OMSDK_Pubnativenet or Smaato_HyBid + OMSDK_Smaato (got $HYBID_NAME + $OMSDK_NAME)"
  fi
  for key in hybidVersion $HYBID_KEY $OMSDK_KEY; do
    [ "$(grep -c "^let $key *= *\".*\" *// managed" "$MANIFEST")" = "1" ] \
      || die "Manifest must contain exactly one managed 'let $key = \"…\" // managed' line"
  done

  # Both flavours are served from the same release (hybidVersion). Changing the version
  # invalidates the other flavour's checksums until it is packaged for this version too.
  OLD_VERSION="$(sed -nE 's|^let hybidVersion *= *"([^"]*)".*|\1|p' "$MANIFEST")"
  if [ "$OLD_VERSION" != "$VERSION" ]; then
    echo "⚠️  Version $OLD_VERSION → $VERSION: also package the other flavour for $VERSION" >&2
    echo "    ($OTHER_KEYS still point at $OLD_VERSION artifacts)." >&2
  fi

  sed -i '' -E \
    -e "s|^(let hybidVersion *= *)\"[^\"]*\"|\1\"$VERSION\"|" \
    -e "s|^(let $HYBID_KEY *= *)\"[^\"]*\"|\1\"$HYBID_SUM\"|" \
    -e "s|^(let $OMSDK_KEY *= *)\"[^\"]*\"|\1\"$OMSDK_SUM\"|" \
    "$MANIFEST"
  echo "✍️  Updated $MANIFEST"
  grep -E "^let (hybidVersion|$HYBID_KEY|$OMSDK_KEY) " "$MANIFEST"

  if [ "$LOCAL_COPY" = "1" ]; then
    ART_DIR="$(cd "$(dirname "$MANIFEST")" && pwd)/Artifacts"
    mkdir -p "$ART_DIR"
    cp "$OUT_DIR/$HYBID_NAME.xcframework.zip" "$OUT_DIR/$OMSDK_NAME.xcframework.zip" "$ART_DIR/"
    echo "📁 Copied zips to $ART_DIR (use HYBID_SPM_LOCAL_ARTIFACTS=1 to resolve against them)"
  fi
fi

echo "🎉 Done. Upload $HYBID_NAME.xcframework.zip and $OMSDK_NAME.xcframework.zip to release $VERSION,"
echo "   then commit Package.swift and tag $VERSION."
