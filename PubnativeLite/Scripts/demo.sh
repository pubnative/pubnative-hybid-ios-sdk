# Variable Declarations
BASE_DIR=/tmp/circleci-artifacts
PRODUCT_NAME=HyBidDemo
HYBID_DEMO_APP_NAME=$PRODUCT_NAME.app
HYBID_DEMO_APP=$BASE_DIR/$HYBID_DEMO_APP_NAME
HYBID_DEMO_APP_ZIP_PATH=$BASE_DIR/HyBidDemo.app.zip

# Show Current Versions
xcodebuild -showsdks

# Generate HyBid Demo App
xcodebuild -arch x86_64 -sdk iphonesimulator14.0 -workspace HyBid.xcworkspace -scheme HyBidDemo

# Create a .zip HyBid Demo App
zip -r $HYBID_DEMO_APP_ZIP_PATH $HYBID_DEMO_APP
