# Variable Declarations
BASE_FOLDER=/tmp/circleci-artifacts
ARCHIVE_PATH=$BASE_FOLDER/archive.xcarchive
OUTPUT_FOLDER=$BASE_FOLDER/ipa
# Clean
rm -rf $ARCHIVE_PATH
rm -rf $OUTPUT_FOLDER

#Generate Archive
cd PubnativeLite
agvtool -noscm new-marketing-version "$(agvtool what-marketing-version -terse1)"
agvtool new-version -all $CIRCLE_BUILD_NUM

xcodebuild -workspace ../HyBid.xcworkspace -list
bundle exec fastlane distribute --verbose
