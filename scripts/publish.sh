OPTIONS_PLIST=$CIRCLE_ARTIFACTS/options.plist
ARCHIVE_PATH=$CIRCLE_ARTIFACTS/archive.xcarchive
OUTPUT_FOLDER=$CIRCLE_ARTIFACTS/archive
IPA_PATH=$OUTPUT_FOLDER/PubnativeLiteDemo.ipa
# CLEAN
rm $OPTIONS_PLIST
rm -rf $ARCHIVE_PATH
rm -rf $OUTPUT_FOLDER
#GENERATE PLIST
PLIST='{"compileBitcode":false,"method":"enterprise"}'
echo $PLIST | plutil -convert xml1 -o $OPTIONS_PLIST -

cd PubnativeLiteDemo
agvtool -noscm new-marketing-version "$(agvtool what-marketing-version -terse1)-${CIRCLE_BRANCH}.${CIRCLE_BUILD_NUM}"
agvtool new-version -all $CIRCLE_BUILD_NUM
cd ..
#GENERATE ARCHIVE
fastlane gym    --include_bitcode true \
                --include_symbols true \
                --clean \
                --workspace PubnativeLite.xcworkspace \
                --scheme PubnativeLiteDemo \
                --archive_path $ARCHIVE_PATH \
                --output_directory $OUTPUT_FOLDER \
                --export_options $OPTIONS_PLIST
