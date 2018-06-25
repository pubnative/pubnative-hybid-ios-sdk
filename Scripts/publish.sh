BASE_FOLDER=/tmp/circleci-artifacts
OPTIONS_PLIST=$BASE_FOLDER/options.plist
ARCHIVE_PATH=$BASE_FOLDER/archive.xcarchive
OUTPUT_FOLDER=$BASE_FOLDER/ipa
# CLEAN
rm $OPTIONS_PLIST
rm -rf $ARCHIVE_PATH
rm -rf $OUTPUT_FOLDER
#GENERATE PLIST
PLIST='{"compileBitcode":false,"method":"enterprise","signingStyle": "manual","provisioningProfiles":{"net.pubnative.PubnativeLite.demo":"PNLiteDemoAdHoc"}}'
echo $PLIST | plutil -convert xml1 -o $OPTIONS_PLIST -
#GENERATE ARCHIVE
cd PubnativeLite
agvtool -noscm new-marketing-version "$(agvtool what-marketing-version -terse1)-${CIRCLE_BRANCH}.${CIRCLE_BUILD_NUM}"
agvtool new-version -all $CIRCLE_BUILD_NUM
cd ..
fastlane gym --verbose --skip_profile_detection true --include_bitcode true --include_symbols true --clean --workspace PubnativeLite.xcworkspace --scheme PubnativeLiteDemo --archive_path $ARCHIVE_PATH --output_directory $OUTPUT_FOLDER --export_options $OPTIONS_PLIST

# Upload generated IPA to Fabric
./scripts/submit $FABRIC_API_KEY $FABRIC_API_SECRET -ipaPath $OUTPUT_FOLDER/PubnativeLiteDemo.ipa
