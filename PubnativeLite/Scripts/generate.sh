export LIBXML2_CFLAGS=`xml2-config --cflags`
export LIBXML2_LIBS=`xml2-config --libs`

# Variable Declarations
BASE_DIR=/tmp/circleci-artifacts
PRODUCT_NAME=HyBid
FRAMEWORK_NAME=$PRODUCT_NAME.framework
FAT_FRAMEWORK=$BASE_DIR/$FRAMEWORK_NAME
FAT_PRODUCT=$FAT_FRAMEWORK/$PRODUCT_NAME
FAT_ZIP_PATH=$BASE_DIR/HyBid.framework.zip
XCFRAMEWORK_NAME=$PRODUCT_NAME.xcframework
FAT_XCFRAMEWORK=$BASE_DIR/$XCFRAMEWORK_NAME
FAT_XC_PRODUCT=$FAT_XCFRAMEWORK/$PRODUCT_NAME
FAT_XC_ZIP_PATH=$BASE_DIR/HyBid.xcframework.zip
IPHONEOS_PATH=$BASE_DIR/iphoneos
IPHONEOS_ARCH=$IPHONEOS_PATH/arch
IPHONEOS_FRAMEWORK=$IPHONEOS_PATH/$FRAMEWORK_NAME
IPHONEOS_PRODUCT=$IPHONEOS_FRAMEWORK/$PRODUCT_NAME
IPHONEOS_ZIP_PATH=$BASE_DIR/HyBid.iphoneos.framework.zip
IPHONESIMULATOR_PATH=$BASE_DIR/iphonesimulator
IPHONESIMULATOR_FRAMEWORK=$IPHONESIMULATOR_PATH/$FRAMEWORK_NAME
IPHONESIMULATOR_PRODUCT=$IPHONESIMULATOR_FRAMEWORK/$PRODUCT_NAME
IPHONESIMULATOR_ZIP_PATH=$BASE_DIR/HyBid.iphonesimulator.framework.zip

# Generate Frameworks
xcodebuild -project PubnativeLite/HyBid.xcodeproj -scheme HyBid -sdk iphoneos -configuration Release clean build CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED=NO CONFIGURATION_BUILD_DIR=$IPHONEOS_PATH | xcpretty -c
xcodebuild -project PubnativeLite/HyBid.xcodeproj -scheme HyBid -sdk iphonesimulator -configuration Release clean build CONFIGURATION_BUILD_DIR=$IPHONESIMULATOR_PATH | xcpretty -c

# Generate XCFramework
xcodebuild -create-xcframework -framework $IPHONEOS_FRAMEWORK -framework $IPHONESIMULATOR_FRAMEWORK -output $FAT_XCFRAMEWORK

# Merge Frameworks and .zip them
cp -rf $IPHONEOS_FRAMEWORK $FAT_FRAMEWORK
rm $FAT_PRODUCT
lipo -create $IPHONEOS_PRODUCT $IPHONESIMULATOR_PRODUCT -output $FAT_PRODUCT
zip -r $FAT_ZIP_PATH $FAT_FRAMEWORK
zip -r $IPHONEOS_ZIP_PATH $IPHONEOS_FRAMEWORK
zip -r $IPHONESIMULATOR_ZIP_PATH $IPHONESIMULATOR_FRAMEWORK

# Create a .zip xcframework
zip -r $FAT_XC_ZIP_PATH $FAT_XCFRAMEWORK

# Generate Static framework + bundle resrource. a zip file will be generated at /tmp/circle-ci-artifact
xcodebuild -workspace HyBid.xcworkspace -scheme HybidFramework -sdk iphoneos -destination generic/platform=iOS -configuration Release clean build | xcpretty -c
