export LIBXML2_CFLAGS=`xml2-config --cflags`
export LIBXML2_LIBS=`xml2-config --libs`

# Variable Declarations
BASE_DIR=/tmp/circleci-artifacts
PRODUCT_NAME=HyBid
FRAMEWORK_NAME=$PRODUCT_NAME.framework
FRAMEWORK_DSYM_NAME=$FRAMEWORK_NAME.dSYM
XCFRAMEWORK_NAME=$PRODUCT_NAME.xcframework
XCFRAMEWORK=$BASE_DIR/$XCFRAMEWORK_NAME
XCFRAMEWORK_ZIP_PATH=$BASE_DIR/HyBid.xcframework.zip
IPHONEOS_PATH=$BASE_DIR/iphoneos
IPHONEOS_ARCH=$IPHONEOS_PATH/arch
IPHONEOS_FRAMEWORK=$IPHONEOS_PATH/$FRAMEWORK_NAME
IPHONESIMULATOR_PATH=$BASE_DIR/iphonesimulator
IPHONESIMULATOR_FRAMEWORK=$IPHONESIMULATOR_PATH/$FRAMEWORK_NAME
IPHONEOS_DSYM=$IPHONEOS_PATH/$FRAMEWORK_DSYM_NAME
IPHONESIMULATOR_DSYM=$IPHONESIMULATOR_PATH/$FRAMEWORK_DSYM_NAME
IPHONE_BCSYMBOLMAP_PATHS=$IPHONEOS_PATH/*

# Generate Frameworks
echo "Generating framework iphoneos"
xcodebuild -workspace HyBid.xcworkspace -scheme HyBid -sdk iphoneos -configuration Release clean build CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED=NO CONFIGURATION_BUILD_DIR=$IPHONEOS_PATH | xcpretty -c
echo "Generating framework iphonesimulator"
xcodebuild -workspace HyBid.xcworkspace -scheme HyBid -sdk iphonesimulator -configuration Release clean build CONFIGURATION_BUILD_DIR=$IPHONESIMULATOR_PATH | xcpretty -c

echo "Generating IPHONE BCSymbolMap paths"
IPHONE_BCSYMBOLMAP_COMMANDS=""
for path in $IPHONE_BCSYMBOLMAP_PATHS; do
    if [[ ${path} =~ ".bcsymbolmap" ]]; then
        IPHONE_BCSYMBOLMAP_COMMANDS="$IPHONE_BCSYMBOLMAP_COMMANDS -debug-symbols $path "
    fi
    echo $IPHONE_BCSYMBOLMAP_COMMANDS
done

# Generate XCFramework
echo "Generating xcframework"
xcodebuild -create-xcframework -framework $IPHONEOS_FRAMEWORK -debug-symbols $IPHONEOS_DSYM $IPHONE_BCSYMBOLMAP_COMMANDS -framework $IPHONESIMULATOR_FRAMEWORK -debug-symbols $IPHONESIMULATOR_DSYM -output $XCFRAMEWORK

# Create a .zip xcframework
echo "Create a .zip xcframework"
zip -r $XCFRAMEWORK_ZIP_PATH $XCFRAMEWORK

# Generate Static framework + bundle resrource. a zip file will be generated at /tmp/circle-ci-artifact
#xcodebuild -workspace HyBid.xcworkspace -scheme HybidFramework -sdk iphoneos -destination generic/platform=iOS -configuration Release clean build | xcpretty -c
