#!/bin/bash
set -e

# ========================================
# 🧩 Generate HyBid-private.podspec
# ========================================
# Dynamically generates a podspec file for the private HyBid SDK
# referencing the binary hosted in the private release repo.
#
# 🧰 Inputs:
#   - HYBID_PRIVATE_REPO_RELEASE_TAG (optional; computed if missing)
#   - HyBid.xcframework.zip (binary to reference)
#
# 📦 Outputs:
#   - HyBid-private.podspec in project root
#   - Exports HYBID_PRIVATE_REPO_RELEASE_TAG to $BASH_ENV (on CI)
#
# 💻 Usage:
#   ./Scripts/generate-private-podspec.sh
#
# 🧩 Notes:
#   - Must be run before commit-private-podspec.sh.
#   - Works locally and on CI (adds tag env var for downstream steps).
# ========================================

GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

echo "🧩 Generating HyBid-private.podspec from HyBid.podspec..."

if [ ! -f "HyBid.podspec" ]; then
  echo -e "${RED}❌ Error: HyBid.podspec not found in current directory.${NC}"
  exit 1
fi

# -----------------------------------------
# 🔍 Extract version from HyBid.podspec
# -----------------------------------------
BASE_VERSION=$(grep -E 's.version\s*=' HyBid.podspec | sed -E 's/.*=[[:space:]]*["'\'']([^"'\'']+)["'\''].*/\1/')
if [ -z "$BASE_VERSION" ]; then
  echo -e "${RED}❌ Could not detect version in HyBid.podspec.${NC}"
  exit 1
fi
echo -e "${GREEN}✅ Detected base version from HyBid.podspec: ${BASE_VERSION}${NC}"

# -----------------------------------------
# 🧠 Determine build type and version postfix
# -----------------------------------------
if [ -n "$CIRCLE_BUILD_NUM" ]; then
  POSTFIX="build.${CIRCLE_BUILD_NUM}"
  echo -e "${GREEN}🤖 Running in CI — using build number ${CIRCLE_BUILD_NUM}${NC}"
else
  COUNTER_FILE=".local_build_number"
  if [ -f "$COUNTER_FILE" ]; then
    BUILD_NUM=$(cat "$COUNTER_FILE")
  else
    BUILD_NUM=0
  fi
  BUILD_NUM=$((BUILD_NUM + 1))
  echo "$BUILD_NUM" > "$COUNTER_FILE"
  POSTFIX="local.build.${BUILD_NUM}"
  echo -e "${GREEN}🖥️  Running locally — incremented local build counter: ${BUILD_NUM}${NC}"
fi

VERSION="${BASE_VERSION}-${POSTFIX}"
echo -e "${GREEN}📦 Final version: ${VERSION}${NC}"

# -----------------------------------------
# 🔍 Fetch ATOM-Standalone-Private from private specs repo
# -----------------------------------------

ATOM_NAME="ATOM-Standalone-Private"

# Ensure the private specs repo is added
if ! pod repo list | grep -q "specs-private"; then
  echo -e "${GREEN}📦 Adding private specs repo...${NC}"
  pod repo add specs-private git@github.com:vervegroup/specs-private.git || true
else
  echo -e "${GREEN}✅ Private specs repo already added.${NC}"
fi

# Fetch the latest version of ATOM-Standalone-Private from the specs repo
ATOM_VERSION=$(pod spec cat ${ATOM_NAME} 2>/dev/null | grep -E "s\.version\s*=" | head -1 | sed -E "s/.*=[[:space:]]*['\"]([^'\"]+)['\"].*/\1/" || echo "")

# -----------------------------------------
# 📝 Generate HyBid-private.podspec
# -----------------------------------------
cat > HyBid-private.podspec <<EOF
Pod::Spec.new do |s|
  s.name         = "HyBid-private"
  s.module_name  = "HyBid"
  s.version      = '${VERSION}'
  s.summary      = "This is the iOS SDK of HyBid. You can read more about it at https://pubnative.net."
  s.description = <<-DESC
                     HyBid leverages first-look prebid technology to maximize yield for the publishers across
                     their current monetization suit. Access to the unique demand across different formats allows
                     publishers to immediately benefit with additional revenues on top of their current yield. Prebid technology
                     allows getting a competitive bid before executing your regular waterfall logic, and then
                     participate in the relevant auctions in the cascade.
                   DESC
  s.homepage     = "https://github.com/pubnative/pubnative-hybid-ios-sdk"
  s.documentation_url = "https://developers.verve.com/v3.0/docs/hybid"
  s.license             = { :type => "Custom", :text => <<-LICENSE
      HyBid SDK License Terms ("License Terms")
    LICENSE
    }

  s.authors      = { "Can Soykarafakili" => "can.soykarafakili@pubnative.net", "Eros Garcia Ponte" => "eros.ponte@pubnative.net", "Fares Benhamouda" => "fares.benhamouda@pubnative.net", "Orkhan Alizada" => "orkhan.alizada@pubnative.net", "Jose Contreras" => "jose.contreras@verve.com", "Aysel Abdullayeva" => "aysel.abdullayeva@verve.com"  }
  s.platform     = :ios

  s.ios.deployment_target = "12.0"
  s.source       = { :git => "https://github.com/pubnative/pubnative-hybid-ios-sdk-private.git", :branch => "feature/PoC-HyBid-JS-Interface" }
  s.resource_bundle = {
    "#{s.module_name}Resources" => "PubnativeLite/PubnativeLite/PrivacyInfo.xcprivacy"
  }
  s.xcconfig = {
    'OTHER_LDFLAGS' => '-framework OMSDK_Pubnativenet'
  }

  s.swift_version = '5.0'
  s.pod_target_xcconfig = {
    'OTHER_SWIFT_FLAGS' => '-Xcc -Wno-incomplete-umbrella'
  }

  s.subspec 'Core' do |core|
    core.source_files          = 'PubnativeLite/PubnativeLite/Core/**/*.{swift,h,m}'
    core.resources            =  ['PubnativeLite/PubnativeLite/Resources/**/*', 'PubnativeLite/PubnativeLite/OMSDK-1.6.3/*.js', 'PubnativeLite/PubnativeLite/Core/MRAID/*.js']
    core.exclude_files         = 'PubnativeLite/PubnativeLite/Core/Public/HyBidStatic.{swift,h,m}'
    core.vendored_frameworks   = ['PubnativeLite/PubnativeLite/OMSDK-1.6.3/*.{xcframework}']
    core.pod_target_xcconfig = { 'HEADER_SEARCH_PATHS' => '$(PODS_ROOT)/HyBid/module' }
    core.xcconfig = { 'HEADER_SEARCH_PATHS' => '$(SDKROOT)/usr/include/libxml2 $(PODS_ROOT)/HyBid/module' }
    core.public_header_files = ['PubnativeLite/PubnativeLite/Core/Public/*.h', 'PubnativeLite/PubnativeLite/Core/Viewability/Public/*.h' , 'PubnativeLite/PubnativeLite/Core/Consent/Public/*.h', 'PubnativeLite/PubnativeLite/Core/Ad Model/Public/*.h', 'PubnativeLite/PubnativeLite/Core/Ad Request/Public/*.h', 'PubnativeLite/PubnativeLite/Core/Ad Cache/Public/*.h', 'PubnativeLite/PubnativeLite/Core/Ad Presenter/Public/*.h', 'PubnativeLite/PubnativeLite/Core/MRAID/Public/*.h', 'PubnativeLite/PubnativeLite/Core/Remote Config/Public/*.h', 'PubnativeLite/PubnativeLite/Core/Auction/Public/*.h', 'PubnativeLite/PubnativeLite/Core/Utils/Public/*.h', 'PubnativeLite/PubnativeLite/Core/VAST/Public/*.h', 'PubnativeLite/PubnativeLite/Core/Analytics/Public/*.h']

  end

  s.subspec 'Banner' do |banner|
    banner.dependency           'HyBid-private/Core'
    banner.source_files         = ['PubnativeLite/PubnativeLite/Banner/**/*.{swift,h,m}']
    banner.public_header_files = ['PubnativeLite/PubnativeLite/Banner/**/*.h']
  end

  s.subspec 'Native' do |native|
    native.dependency           'HyBid-private/Core'
    native.source_files     = ['PubnativeLite/PubnativeLite/Native/**/*.{swift,h,m}']
    native.public_header_files = ['PubnativeLite/PubnativeLite/Native/**/*.h']
  end

  s.subspec 'FullScreen' do |fullscreen|
    fullscreen.dependency       'HyBid-private/Core'
    fullscreen.source_files     = ['PubnativeLite/PubnativeLite/FullScreen/**/*.{swift,h,m}']
    fullscreen.public_header_files = ['PubnativeLite/PubnativeLite/FullScreen/Public/*.h']
  end

  s.subspec 'RewardedVideo' do |rewarded|
    rewarded.dependency         'HyBid-private/Core'
    rewarded.source_files       = ['PubnativeLite/PubnativeLite/Rewarded/**/*.{swift,h,m}']
    rewarded.public_header_files = ['PubnativeLite/PubnativeLite/Rewarded/Public/*.h']
  end

  s.subspec 'ATOM' do |atom|
    atom.dependency 'HyBid-private/Core'
    atom.dependency 'ATOM-Standalone-Private', '${ATOM_VERSION}'
  end

  s.default_subspecs = ['Core', 'Banner', 'Native', 'FullScreen', 'RewardedVideo', 'ATOM']
  
end
EOF

echo -e "${GREEN}🎉 Successfully generated HyBid-private.podspec (v${VERSION})${NC}"
