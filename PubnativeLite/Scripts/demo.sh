# Variable Declarations
BASE_DIR=/tmp/circleci-artifacts
PRODUCT_NAME=HyBidDemo
HYBID_DEMO_APP_NAME=$PRODUCT_NAME.app
HYBID_DEMO_APP_PATH=$BASE_DIR/$PRODUCT_NAME
HYBID_DEMO_APP=$HYBID_DEMO_APP_PATH/$HYBID_DEMO_APP_NAME
HYBID_DEMO_APP_ZIP_PATH=$BASE_DIR/HyBidDemo.app.zip

# Show Current Versions
xcodebuild -showsdks

# Generate HyBid Demo App
xcodebuild -arch x86_64 -sdk iphonesimulator -workspace HyBid.xcworkspace -scheme HyBidDemo CONFIGURATION_BUILD_DIR=$HYBID_DEMO_APP_PATH

# Create a .zip HyBid Demo App
zip -r $HYBID_DEMO_APP_ZIP_PATH $HYBID_DEMO_APP
